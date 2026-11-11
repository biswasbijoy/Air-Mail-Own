const express = require('express');
const http = require('http');
const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const cors = require('cors');
const { Server } = require('socket.io');

const PORT = Number(process.env.PORT) || 5000;
const MONGODB_URI = process.env.MONGODB_URI;
const JWT_SECRET = process.env.JWT_SECRET;
const CORS_ORIGIN = process.env.CORS_ORIGIN || '*';
const TOKEN_TTL = process.env.JWT_EXPIRES_IN || '7d';

if (!MONGODB_URI) {
  console.error('MONGODB_URI environment variable is required');
  process.exit(1);
}

if (!JWT_SECRET) {
  console.error('JWT_SECRET environment variable is required');
  process.exit(1);
}

const app = express();
app.set('trust proxy', 1);
app.disable('x-powered-by');
app.use(cors({ origin: CORS_ORIGIN }));
app.use(express.json({ limit: '64kb' }));
app.use((req, res, next) => {
  res.setHeader('X-Content-Type-Options', 'nosniff');
  next();
});

mongoose
  .connect(MONGODB_URI)
  .then(() => {
    console.log('MongoDB connected');
    startServer();
  })
  .catch((err) => {
    console.error('MongoDB connection error:', err.message);
    process.exit(1);
  });

mongoose.connection.on('error', (err) => {
  console.error('MongoDB error:', err.message);
});

const userSchema = new mongoose.Schema(
  {
    name: { type: String, required: true, trim: true, maxlength: 80 },
    email: {
      type: String,
      required: true,
      unique: true,
      trim: true,
      lowercase: true,
      maxlength: 254,
    },
    password: { type: String, required: true },
    createdAt: { type: Date, default: Date.now },
  },
  { versionKey: false }
);

const messageSchema = new mongoose.Schema(
  {
    sender: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    receiver: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    message: { type: String, required: true, trim: true, maxlength: 5000 },
    createdAt: { type: Date, default: Date.now, index: true },
  },
  { versionKey: false }
);

messageSchema.index({ sender: 1, receiver: 1, createdAt: -1 });

const contactSchema = new mongoose.Schema(
  {
    owner: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    contact: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    createdAt: { type: Date, default: Date.now },
  },
  { versionKey: false }
);

contactSchema.index({ owner: 1, contact: 1 }, { unique: true });
contactSchema.index({ owner: 1, createdAt: -1 });

const User = mongoose.model('User', userSchema);
const Message = mongoose.model('Message', messageSchema);
const Contact = mongoose.model('Contact', contactSchema);

const onlineSockets = new Map();

const EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
const PUBLIC_USER_FIELDS = 'name email createdAt';

function publicUser(user) {
  return {
    id: user._id.toString(),
    name: user.name,
    email: user.email,
    online: onlineSockets.has(user._id.toString()),
  };
}

async function getRelatedUserIds(userId) {
  const id = userId.toString();
  const [contacts, messages] = await Promise.all([
    Contact.find({ $or: [{ owner: id }, { contact: id }] })
      .select('owner contact')
      .lean(),
    Message.find({ $or: [{ sender: id }, { receiver: id }] })
      .sort({ createdAt: -1 })
      .limit(500)
      .select('sender receiver')
      .lean(),
  ]);

  const related = new Set();
  for (const contact of contacts) {
    related.add(contact.owner.toString());
    related.add(contact.contact.toString());
  }
  for (const message of messages) {
    related.add(message.sender.toString());
    related.add(message.receiver.toString());
  }
  related.delete(id);
  return related;
}

async function broadcastPresence(userId, online) {
  const related = await getRelatedUserIds(userId);
  if (related.size === 0) return;

  const id = userId.toString();
  if (online !== onlineSockets.has(id)) return;

  let target = io;
  for (const relatedId of related) {
    target = target.to(`user:${relatedId}`);
  }
  target.emit('presence', { userId: id, online });
}

function serializeMessage(doc) {
  return {
    _id: doc._id.toString(),
    sender: doc.sender.toString(),
    receiver: doc.receiver.toString(),
    message: doc.message,
    createdAt: doc.createdAt.toISOString(),
  };
}

function signToken(user) {
  return jwt.sign({ id: user._id.toString() }, JWT_SECRET, { expiresIn: TOKEN_TTL });
}

function auth(req, res, next) {
  const header = req.headers.authorization || '';
  const token = header.startsWith('Bearer ') ? header.slice(7).trim() : null;

  if (!token) {
    return res.status(401).json({ message: 'Authentication required' });
  }

  try {
    const payload = jwt.verify(token, JWT_SECRET);
    if (!payload || !mongoose.isValidObjectId(payload.id)) {
      return res.status(401).json({ message: 'Invalid session' });
    }
    req.userId = payload.id;
    return next();
  } catch (err) {
    return res.status(401).json({ message: 'Session expired. Please sign in again.' });
  }
}

function rateLimit({ windowMs, max }) {
  const hits = new Map();

  const cleanup = setInterval(() => {
    const now = Date.now();
    for (const [key, entry] of hits) {
      if (entry.reset <= now) hits.delete(key);
    }
  }, windowMs);
  if (typeof cleanup.unref === 'function') cleanup.unref();

  return (req, res, next) => {
    const now = Date.now();
    const key = req.ip || 'unknown';
    const entry = hits.get(key);

    if (!entry || entry.reset <= now) {
      hits.set(key, { count: 1, reset: now + windowMs });
      return next();
    }

    entry.count += 1;
    if (entry.count > max) {
      return res.status(429).json({ message: 'Too many requests. Please try again later.' });
    }
    return next();
  };
}

const authLimiter = rateLimit({ windowMs: 15 * 60 * 1000, max: 30 });
const apiLimiter = rateLimit({ windowMs: 60 * 1000, max: 180 });

app.get('/api/health', (req, res) => {
  res.json({ status: 'ok' });
});

app.post('/api/auth/register', authLimiter, async (req, res) => {
  const name = typeof req.body.name === 'string' ? req.body.name.trim() : '';
  const email = typeof req.body.email === 'string' ? req.body.email.trim().toLowerCase() : '';
  const password = typeof req.body.password === 'string' ? req.body.password : '';

  if (name.length < 1 || name.length > 80) {
    return res.status(400).json({ message: 'Name must be between 1 and 80 characters' });
  }
  if (!EMAIL_RE.test(email)) {
    return res.status(400).json({ message: 'Please provide a valid email address' });
  }
  if (password.length < 6 || password.length > 128) {
    return res.status(400).json({ message: 'Password must be between 6 and 128 characters' });
  }

  try {
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(409).json({ message: 'An account with this email already exists' });
    }

    const hashedPassword = await bcrypt.hash(password, 12);
    const user = await User.create({ name, email, password: hashedPassword });

    return res.status(201).json({
      token: signToken(user),
      user: publicUser(user),
    });
  } catch (err) {
    if (err && err.code === 11000) {
      return res.status(409).json({ message: 'An account with this email already exists' });
    }
    console.error('Register error:', err.message);
    return res.status(500).json({ message: 'Server error' });
  }
});

app.post('/api/auth/login', authLimiter, async (req, res) => {
  const email = typeof req.body.email === 'string' ? req.body.email.trim().toLowerCase() : '';
  const password = typeof req.body.password === 'string' ? req.body.password : '';

  if (!EMAIL_RE.test(email) || password.length === 0) {
    return res.status(400).json({ message: 'Invalid credentials' });
  }

  try {
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(400).json({ message: 'Invalid credentials' });
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(400).json({ message: 'Invalid credentials' });
    }

    return res.json({
      token: signToken(user),
      user: publicUser(user),
    });
  } catch (err) {
    console.error('Login error:', err.message);
    return res.status(500).json({ message: 'Server error' });
  }
});

app.get('/api/auth/me', auth, async (req, res) => {
  try {
    const user = await User.findById(req.userId).select(PUBLIC_USER_FIELDS);
    if (!user) {
      return res.status(401).json({ message: 'Account no longer exists' });
    }
    return res.json({ user: publicUser(user) });
  } catch (err) {
    console.error('Me error:', err.message);
    return res.status(500).json({ message: 'Server error' });
  }
});

async function listContacts(req, res) {
  try {
    const docs = await Contact.find({ owner: req.userId })
      .populate('contact', PUBLIC_USER_FIELDS)
      .sort({ createdAt: -1 });

    const contacts = docs
      .map((doc) => doc.contact)
      .filter(Boolean)
      .map(publicUser)
      .sort((a, b) => a.name.localeCompare(b.name));

    return res.json(contacts);
  } catch (err) {
    console.error('Contacts error:', err.message);
    return res.status(500).json({ message: 'Server error' });
  }
}

app.get('/api/users', apiLimiter, auth, listContacts);
app.get('/api/contacts', apiLimiter, auth, listContacts);

app.get('/api/contacts/search', apiLimiter, auth, async (req, res) => {
  const email =
    typeof req.query.email === 'string' ? req.query.email.trim().toLowerCase() : '';

  if (!EMAIL_RE.test(email)) {
    return res.status(400).json({ message: 'Please provide a valid email address' });
  }

  try {
    const user = await User.findOne({ email }).select(PUBLIC_USER_FIELDS);
    if (!user) {
      return res.status(404).json({ message: 'No user found with that email' });
    }
    if (user._id.toString() === req.userId) {
      return res.status(400).json({ message: 'You cannot add yourself' });
    }

    const isContact = await Contact.exists({
      owner: req.userId,
      contact: user._id,
    });

    return res.json({ user: publicUser(user), isContact: Boolean(isContact) });
  } catch (err) {
    console.error('Contact search error:', err.message);
    return res.status(500).json({ message: 'Server error' });
  }
});

app.post('/api/contacts', apiLimiter, auth, async (req, res) => {
  const email =
    typeof req.body.email === 'string' ? req.body.email.trim().toLowerCase() : '';

  if (!EMAIL_RE.test(email)) {
    return res.status(400).json({ message: 'Please provide a valid email address' });
  }

  try {
    const contact = await User.findOne({ email }).select(PUBLIC_USER_FIELDS);
    if (!contact) {
      return res.status(404).json({ message: 'No user found with that email' });
    }
    if (contact._id.toString() === req.userId) {
      return res.status(400).json({ message: 'You cannot add yourself' });
    }

    const existing = await Contact.exists({
      owner: req.userId,
      contact: contact._id,
    });
    if (existing) {
      return res.status(409).json({ message: 'This user is already in your contacts' });
    }

    await Contact.create({ owner: req.userId, contact: contact._id });
    return res.status(201).json(publicUser(contact));
  } catch (err) {
    if (err && err.code === 11000) {
      return res.status(409).json({ message: 'This user is already in your contacts' });
    }
    console.error('Add contact error:', err.message);
    return res.status(500).json({ message: 'Server error' });
  }
});

app.get('/api/chats', apiLimiter, auth, async (req, res) => {
  try {
    const messages = await Message.find({
      $or: [{ sender: req.userId }, { receiver: req.userId }],
    })
      .sort({ createdAt: -1 })
      .limit(500)
      .populate('sender', PUBLIC_USER_FIELDS)
      .populate('receiver', PUBLIC_USER_FIELDS);

    const chats = new Map();

    for (const message of messages) {
      if (!message.sender || !message.receiver) continue;

      const senderId = message.sender._id.toString();
      const receiverId = message.receiver._id.toString();
      const other = senderId === req.userId.toString() ? message.receiver : message.sender;
      const otherId = other._id.toString();

      if (chats.has(otherId)) continue;

      chats.set(otherId, {
        user: publicUser(other),
        lastMessage: message.message,
        lastMessageAt: message.createdAt.toISOString(),
      });
    }

    return res.json([...chats.values()]);
  } catch (err) {
    console.error('Chats error:', err.message);
    return res.status(500).json({ message: 'Server error' });
  }
});

app.post('/api/messages', apiLimiter, auth, async (req, res) => {
  const { receiverId } = req.body;
  const text = typeof req.body.message === 'string' ? req.body.message.trim() : '';

  if (!mongoose.isValidObjectId(receiverId)) {
    return res.status(400).json({ message: 'Invalid recipient' });
  }
  if (receiverId === req.userId.toString()) {
    return res.status(400).json({ message: 'You cannot message yourself' });
  }
  if (text.length < 1 || text.length > 5000) {
    return res.status(400).json({ message: 'Message must be between 1 and 5000 characters' });
  }

  try {
    const receiver = await User.exists({ _id: receiverId });
    if (!receiver) {
      return res.status(404).json({ message: 'Recipient not found' });
    }

    const newMessage = await Message.create({
      sender: req.userId,
      receiver: receiverId,
      message: text,
    });

    const payload = serializeMessage(newMessage);
    broadcastMessage(payload);
    return res.status(201).json(payload);
  } catch (err) {
    console.error('Send message error:', err.message);
    return res.status(500).json({ message: 'Server error' });
  }
});

app.get('/api/messages/:userId', apiLimiter, auth, async (req, res) => {
  const { userId } = req.params;

  if (!mongoose.isValidObjectId(userId)) {
    return res.status(400).json({ message: 'Invalid contact' });
  }

  try {
    const messages = await Message.find({
      $or: [
        { sender: req.userId, receiver: userId },
        { sender: userId, receiver: req.userId },
      ],
    }).sort({ createdAt: 1 });

    return res.json(messages.map(serializeMessage));
  } catch (err) {
    console.error('Messages error:', err.message);
    return res.status(500).json({ message: 'Server error' });
  }
});

app.use((req, res) => {
  res.status(404).json({ message: 'Not found' });
});

app.use((err, req, res, next) => {
  if (res.headersSent) return next(err);

  if (err && err.type === 'entity.too.large') {
    return res.status(413).json({ message: 'Request payload is too large' });
  }
  if (err instanceof SyntaxError) {
    return res.status(400).json({ message: 'Invalid JSON payload' });
  }

  console.error('Unhandled error:', err.message);
  return res.status(500).json({ message: 'Server error' });
});

const server = http.createServer(app);
const io = new Server(server, {
  cors: { origin: CORS_ORIGIN },
});

io.use((socket, next) => {
  const token = socket.handshake.auth && socket.handshake.auth.token;

  if (!token) {
    return next(new Error('Authentication required'));
  }

  try {
    const payload = jwt.verify(token, JWT_SECRET);
    if (!payload || !mongoose.isValidObjectId(payload.id)) {
      return next(new Error('Invalid session'));
    }
    socket.userId = payload.id;
    return next();
  } catch (err) {
    return next(new Error('Invalid session'));
  }
});

io.on('connection', (socket) => {
  const userId = socket.userId.toString();
  socket.join(`user:${userId}`);

  const firstConnection = !onlineSockets.has(userId);
  if (firstConnection) onlineSockets.set(userId, new Set());
  onlineSockets.get(userId).add(socket.id);

  socket.on('disconnect', async () => {
    const sockets = onlineSockets.get(userId);
    if (!sockets) return;

    sockets.delete(socket.id);
    if (sockets.size > 0) return;

    onlineSockets.delete(userId);
    try {
      await broadcastPresence(userId, false);
    } catch (err) {
      console.error('Presence broadcast error:', err.message);
    }
  });

  socket.on('send_message', async (payload, ack) => {
    const body = payload && typeof payload === 'object' ? payload : {};
    const receiverId = body.receiverId;
    const text = typeof body.message === 'string' ? body.message.trim() : '';

    try {
      if (!mongoose.isValidObjectId(receiverId) || receiverId === socket.userId.toString()) {
        throw new Error('Invalid recipient');
      }
      if (text.length < 1 || text.length > 5000) {
        throw new Error('Message must be between 1 and 5000 characters');
      }

      const receiver = await User.exists({ _id: receiverId });
      if (!receiver) throw new Error('Recipient not found');

      const newMessage = await Message.create({
        sender: socket.userId,
        receiver: receiverId,
        message: text,
      });

      const data = serializeMessage(newMessage);
      broadcastMessage(data);

      if (typeof ack === 'function') ack({ ok: true, message: data });
    } catch (err) {
      if (typeof ack === 'function') ack({ ok: false, error: err.message });
    }
  });

  (async () => {
    try {
      const related = await getRelatedUserIds(userId);
      const online = [...related].filter((id) => onlineSockets.has(id));
      socket.emit('presence_state', { online });
    } catch (err) {
      console.error('Presence state error:', err.message);
      socket.emit('presence_state', { online: [] });
    }

    if (firstConnection && onlineSockets.has(userId)) {
      try {
        await broadcastPresence(userId, true);
      } catch (err) {
        console.error('Presence broadcast error:', err.message);
      }
    }
  })();
});

function broadcastMessage(payload) {
  io.to(`user:${payload.receiver}`).to(`user:${payload.sender}`).emit('new_message', payload);
}

function startServer() {
  server.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
  });
}
