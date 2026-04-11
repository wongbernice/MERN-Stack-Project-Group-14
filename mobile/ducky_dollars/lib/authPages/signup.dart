import 'package:flutter/material.dart';
import 'package:ducky_dollars/main.dart';
import 'package:go_router/go_router.dart';
import 'package:ducky_dollars/authPages/login.dart';
import 'package:ducky_dollars/inAppPages/home.dart';
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
                // TODO: Get correct url
                final url = Uri.parse('http://67.205.159.14:5000/');

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
                  try {
                    /*
                    final response = await Supabase.instance.client.auth.signUp(
                      email: email,
                      password: password,
                    );

                    if (response.user != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Signed up successfully!')),
                      );
                      dispose();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const HomePage()),
                      );
                    }
                     */
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Signup failed: ${e.toString()}')),
                    );
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