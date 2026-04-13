import 'package:flutter/material.dart';
import 'package:ducky_dollars/main.dart';
import 'package:ducky_dollars/authPages/login.dart';
import 'package:ducky_dollars/authPages/verify.dart';
import 'package:flutter/gestures.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordVerifyController = TextEditingController();
  String result = '';
  String? _errorMessage;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordVerifyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ddSky,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Sign Up',
              style: TextStyle(
                fontFamily: 'Fredoka',
                fontWeight: FontWeight.w700,
                color: ddBarYellow,
                fontSize: 45.0
              )
            ),

            // First name field
            TextField(
              controller: _firstNameController,
              decoration: const InputDecoration(labelText: 'First Name'),
              keyboardType: TextInputType.name,
            ),

            // Last name field
            TextField(
              controller: _lastNameController,
              decoration: const InputDecoration(labelText: 'Last Name'),
              keyboardType: TextInputType.name,
            ),

            // Email field
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),

            const SizedBox(height: 16),

            // Password field
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),

            // Password field
            TextField(
              controller: _passwordVerifyController,
              decoration: const InputDecoration(labelText: 'Re-type Password'),
              obscureText: true,
            ),

            const SizedBox(height: 32),

            // Sign Up button
            ElevatedButton(
              onPressed: () async {
                final firstName = _firstNameController.text.trim();
                final lastName = _lastNameController.text.trim();
                final email = _emailController.text.trim();
                final password = _passwordController.text.trim();
                final checkPass = _passwordVerifyController.text.trim();

                if (password != checkPass) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Error: Passwords don\'t match')),
                  );
                } else {
                  // Use register api
                  try {
                    final response = await http.post(
                        Uri.parse('http://67.205.159.14:5000/api/auth/register'),
                        headers: {
                          'Content-Type': 'application/json',
                          'Accept': 'application/json',
                        },
                        body: jsonEncode(<String, dynamic>{
                          'First': firstName,
                          'Last' : lastName,
                          'email': email,
                          'password': password,
                        }
                        )
                    );

                    print(response.statusCode);

                    if (response.statusCode == 201) {
                      final responseData = jsonDecode(response.body);
                      result = 'id: ${responseData['id']}\ntoken: ${responseData['token']}\nerror: ${responseData['error']}';
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => VerifyPage(emailPasson: email)),
                      );
                    } else if (response.statusCode == 400) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: RichText(
                          text: TextSpan(
                            children: [
                              const TextSpan(
                                text: 'Email already taken. '
                              ),
                              TextSpan(
                                text: 'Login?',
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const LoginPage(),
                                      ),
                                    );
                                  },
                              )
                            ]
                          )
                        )),
                      );
                    }
                  } catch (e) {
                    setState(() {
                      _errorMessage = 'Unexpected error occurred';
                    });
                  }
                }
              },
              child: const Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}