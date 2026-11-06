import 'dart:convert';
import 'package:airmail/DesignUI/button_card.dart';
import 'package:airmail/Model/chat_model.dart';
import 'package:airmail/Screens/homeScreen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  LoginScreen({Key? key}) : super(key: key);
  static String routeName = "/login";

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late ChatModel sourceChat;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;
  String? _token;
  String? _userId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Continue as"),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0x0f0f1a),
                Color(0x1a1a2e),
                Color(0x25253b),
              ],
              begin: Alignment.bottomRight,
              end: Alignment.topLeft,
            ),
          ),
        ),
        elevation: 4,
      ),
      backgroundColor: const Color(0x08080c),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App logo/title
                    const Icon(
                      Icons.message,
                      size: 80,
                      color: Color(0x00d4aa),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _isLogin ? 'Sign In' : 'Register',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Name field (only for registration)
                    if (!_isLogin)
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Full Name',
                          hintText: 'Enter your name',
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0x55ffffff)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0x00d4aa)),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                    const SizedBox(height: 15),

                    // Email field
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        hintText: 'Enter your email',
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0x55ffffff)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0x00d4aa)),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an email';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),

                    // Password field
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Enter your password',
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0x55ffffff)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0x00d4aa)),
                        ),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 25),

                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            setState(() => _isLoading = true);
                            _authenticate();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0x00d4aa),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.black,
                              )
                            : Text(
                                _isLogin ? 'Sign In' : 'Register',
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Toggle login/register
                    TextButton(
                      onPressed: () {
                        setState(() => _isLogin = !_isLogin);
                        _emailController.clear();
                        _passwordController.clear();
                        _nameController.clear();
                      },
                      child: Text(
                        _isLogin
                            ? 'Create a new account'
                            : 'Have an account? Sign in',
                        style: const TextStyle(
                          color: Color(0x88ffffff),
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _authenticate() async {
    final String url = 'https://airmail-backend.onrender.com/api/auth/${_isLogin ? 'login' : 'register'}';

    try {
      final Map<String, dynamic> requestBody;
      if (_isLogin) {
        requestBody = {
          'email': _emailController.text,
          'password': _passwordController.text,
        };
      } else {
        requestBody = {
          'name': _nameController.text,
          'email': _emailController.text,
          'password': _passwordController.text,
        };
      }

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          _token = responseData['token'];
          _userId = responseData['user']['id'];
        });

        // Navigate to home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (builder) => HomeScreen(
              chatmodels: [],
              sourceChat: ChatModel(
                name: _isLogin ? responseData['user']['email'] : _nameController.text,
                id: DateTime.now().millisecondsSinceEpoch,
                email: _emailController.text,
              ),
            ),
          ),
        );
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'] ?? 'Authentication failed')),
        );
      }
    } catch (error) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connection error. Please try again.')),
      );
    }
  }
}