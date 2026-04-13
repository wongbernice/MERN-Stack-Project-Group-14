import 'package:ducky_dollars/authPages/signup.dart';
import 'package:flutter/material.dart';
import 'package:ducky_dollars/main.dart';
import 'package:ducky_dollars/inAppPages/home.dart';
import 'package:ducky_dollars/authPages/verify.dart';
import 'package:ducky_dollars/services/authStorage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage;
  bool _isLoading = false;

  Future<void> _login(String email, String password) async {

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Utilize login api
    try {
      final response = await http.post(
        Uri.parse('http://67.205.159.14:5000/api/auth/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{
          'email': email,
          'password': password,
        }
        )
      );

      print(response.statusCode);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final verificationState = responseData['isVerified'];
        if (verificationState == 'False') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => VerifyPage(emailPasson: email)),
          );
        } else {
          AuthStorage.saveToken(responseData['token']);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        }
      } else if (response.statusCode == 401) {
        Error();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Unexpected error occurred';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ddSky,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Welcome Back!',
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontWeight: FontWeight.w700,
                  color: ddBarYellow,
                  fontSize: 45.0
                )
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
              ),
              const SizedBox(height: 20),
              if (_errorMessage != null)
                Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              if (_isLoading)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: (){
                    final email = _emailController.text.trim();
                    final password = _passwordController.text.trim();
                    _login(email, password);
                  },
                  child: const Text(
                    'Login',
                  ),
                ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignupPage()),
                  );
                },
                child: const Text("Don't have an account? Sign up"),
              ),
              /*
              TextButton(
                onPressed: () {
                },
                child: const Text("Forgot password?"),
              ),
               */
            ],
          ),
        ),
      ),
    );
  }
}