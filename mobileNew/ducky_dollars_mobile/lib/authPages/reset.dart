import 'package:flutter/material.dart';
import 'package:ducky_dollars_mobile/main.dart';
import 'package:ducky_dollars_mobile/authPages/login.dart';
import 'package:ducky_dollars_mobile/authPages/signup.dart';
import 'package:flutter/gestures.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ResetPage extends StatefulWidget {
  const ResetPage({super.key});

  @override
  State<ResetPage> createState() => _ResetPageState();
}

class _ResetPageState extends State<ResetPage> {
  final _verifyController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordVerifyController = TextEditingController();
  String result = '';
  String? _errorMessage;

  @override
  void dispose() {
    _verifyController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordVerifyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: ddSky,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Reset Password',
              style: TextStyle(
                fontFamily: 'Fredoka',
                fontWeight: FontWeight.w700,
                fontSize: 45.0
              )
            ),

            // Email field
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                labelText: 'Email',
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            // Get Verification Code button
            ElevatedButton(
              onPressed: () async {
                final email = _emailController.text.trim();

                if (email == Null || email == "") {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Error: Email Required')),
                  );
                } else {
                  // Use verification code api
                  try {
                    final response = await http.post(
                      Uri.parse('http://67.205.159.14:5000/api/auth/resetpassword'),
                      headers: {
                        'Content-Type': 'application/json',
                        'Accept': 'application/json',
                      },
                      body: jsonEncode(<String, dynamic>{
                        'email': email,
                      })
                    );

                    print(response.statusCode);

                    if (response.statusCode == 200) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Reset code sent to email.')),
                      );
                    } else if (response.statusCode == 400) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: RichText(
                          text: TextSpan(
                            children: [
                              const TextSpan(
                                text: 'Account with email does not exist. '
                              ),
                              TextSpan(
                                text: 'Sign up?',
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const SignupPage(),
                                      ),
                                    );
                                  },
                              )
                            ]
                          )
                        )),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('An unexpected error occurred.')),
                      );
                    }
                  } catch (e) {
                    setState(() {
                      _errorMessage = 'Unexpected error occurred';
                    });
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                fixedSize: const Size(170, 40),
                backgroundColor: loginBlue,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)
                )
              ),
              child: const Text('Get Code'),
            ),

            const SizedBox(height: 32),

            // Code field
            TextField(
              controller: _verifyController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                labelText: 'Code'
              ),
            ),
            const SizedBox(height: 10),
            // Password field
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                labelText: 'New Password'
              ),
              obscureText: true,
            ),
            const SizedBox(height: 10),
            // Password field
            TextField(
              controller: _passwordVerifyController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                labelText: 'Verify New Password'
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            // Set New Password button
            ElevatedButton(
              onPressed: () async {
                final email = _emailController.text.trim();
                final code = _verifyController.text.trim();
                final password = _passwordController.text.trim();
                final checkPass = _passwordVerifyController.text.trim();

                if (password != checkPass) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Error: Passwords don\'t match')),
                  );
                } else {
                  // Use verify reset api
                  try {
                    final response = await http.post(
                      Uri.parse('http://67.205.159.14:5000/api/auth/verifyreset'),
                      headers: {
                        'Content-Type': 'application/json',
                        'Accept': 'application/json',
                      },
                      body: jsonEncode(<String, dynamic>{
                        'email': email,
                        'code': code,
                        'password': password,
                      })
                    );

                    print(response.statusCode);

                    if (response.statusCode == 200) {
                      final responseData = jsonDecode(response.body);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    } else if (response.statusCode == 400) {
                      final responseData = jsonDecode(response.body);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(responseData['error'])),
                      );
                    }
                  } catch (e) {
                    setState(() {
                      _errorMessage = 'Unexpected error occurred';
                    });
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                fixedSize: const Size(170, 40),
                backgroundColor: loginBlue,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)
                )
              ),
              child: const Text('Reset Password'),
            ),
          ],
        ),
      ),
    );
  }
}