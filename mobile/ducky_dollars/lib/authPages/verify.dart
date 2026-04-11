import 'package:ducky_dollars/authPages/signup.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ducky_dollars/main.dart';
import 'package:ducky_dollars/authPages/signup.dart';
import 'package:ducky_dollars/inAppPages/home.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class VerifyPage extends StatefulWidget {
  const VerifyPage({super.key});

  @override
  State<VerifyPage> createState() => _VerifyPageState();
}

class _VerifyPageState extends State<VerifyPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String result = '';
  String? _errorMessage;
  bool _isLoading = false;

  Future<void> _verify(String email, String password) async {

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Login api
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
        result = 'id: ${responseData['id']}\nisVerified: ${responseData['isVerified']}\nemail: ${responseData['email']}\nerror: ${responseData['error']}';
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
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