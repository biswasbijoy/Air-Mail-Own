import 'package:airmail/Model/chat_model.dart';
import 'package:flutter/material.dart';

class CallScreen extends StatefulWidget {
  const CallScreen({super.key});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final List<ChatModel> calls = [
    ChatModel(
      name: 'Bill Gates',
      icon: 'assets/images/BillGates.jpeg',
      time: '10:00 AM',
      status: 'online',
    ),
    ChatModel(
      name: 'Boris Johnson',
      icon: 'assets/images/BorisJohnson.jpg',
      time: 'Yesterday',
      status: 'online',
    ),
    ChatModel(
      name: 'Donald Trump',
      icon: 'assets/images/DonaldTrump.jpg',
      time: '2d ago',
      status: 'online',
    ),
    ChatModel(
      name: 'Recep Tayyip Erdogan',
      icon: 'assets/images/Erdogan.jpg',
      time: '3d ago',
      status: 'online',
    ),
    ChatModel(
      name: 'Jack Ma',
      icon: 'assets/images/JackMa.jpg',
      time: '4d ago',
      status: 'online',
    ),
    ChatModel(
      name: 'Joe Biden',
      icon: 'assets/images/JoeBiden.jpg',
      time: '5d ago',
      status: 'online',
    ),
    ChatModel(
      name: 'John Abraham',
      icon: 'assets/images/JohnAbraham.jpg',
      time: '6d ago',
      status: 'offline',
    ),
    ChatModel(
      name: 'Steve Jobs',
      icon: 'assets/images/SteveJobs.jpg',
      time: '1w ago',
      status: 'offline',
    ),
    ChatModel(
      name: 'Sundar Pichai',
      icon: 'assets/images/SundorPichai.jpg',
      time: '2w ago',
      status: 'online',
    ),
    ChatModel(
      name: 'Vladimir Putin',
      icon: 'assets/images/VladimirPutin.jpg',
      time: '3w ago',
      status: 'offline',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: calls.length,
      separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
      itemBuilder: (context, index) {
        final call = calls[index];
        final icon = call.icon;

        return ListTile(
          leading: icon != null && icon.isNotEmpty
              ? CircleAvatar(radius: 25, backgroundImage: AssetImage(icon))
              : CircleAvatar(
                  radius: 25,
                  child: Text((call.name ?? '?').substring(0, 1)),
                ),
          title: Text(
            call.name ?? 'Unknown',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: scheme.onSurface,
            ),
          ),
          subtitle: Row(
            children: [
              Icon(
                call.status == 'online'
                    ? Icons.call_received
                    : Icons.call_missed_outgoing,
                color: call.status == 'online' ? scheme.primary : scheme.error,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                call.time ?? '',
                style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
              ),
            ],
          ),
          trailing: IconButton(
            tooltip: 'Call ${call.name ?? ''}',
            icon: Icon(Icons.call, size: 24, color: scheme.primary),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Calling is not available yet.'),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
