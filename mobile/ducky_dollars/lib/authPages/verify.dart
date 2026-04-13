import 'package:flutter/material.dart';
import 'package:ducky_dollars/main.dart';
import 'package:ducky_dollars/inAppPages/home.dart';
import 'package:ducky_dollars/services/authStorage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class VerifyPage extends StatefulWidget {
  final String emailPasson;
  const VerifyPage({super.key, required this.emailPasson});

  @override
  State<VerifyPage> createState() => _VerifyPageState();
}

class _VerifyPageState extends State<VerifyPage> {
  final _codeController = TextEditingController();
  String? _errorMessage;
  bool _isLoading = false;

  Future<void> _verify(String email, String code) async {

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Utilize verify api
    try {
      final response = await http.post(
        Uri.parse('http://67.205.159.14:5000/api/auth/verify'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{
          'email': email,
          'code': code,
        })
      );

      print(response.statusCode);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        AuthStorage.saveToken(responseData['token']);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else if (response.statusCode == 400) {
          final responseData = jsonDecode(response.body);
          final error = responseData['error'];

          if (error == 'Invalid email') {
            print('Invalid email address.');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('API Error: Account does not exist')),
            );
          } else if (error == 'Invalid verification code') {
            print('Invalid verification code');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Error: Invalid code')),
            );
          } else if (error == 'Verification code expired') {
            print('Verification code expired.');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Error: Verification code expired.')),
            );
          } else {
            print('Unknown error: $error');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('An unknown error occurred.')),
            );
          }
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
                'Verify Email',
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontWeight: FontWeight.w700,
                  color: ddBarYellow,
                  fontSize: 45.0
                )
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _codeController,
                decoration: const InputDecoration(labelText: 'Verification Code'),
              ),
              const SizedBox(height: 20),
              if (_errorMessage != null)
                Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              if (_isLoading)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: (){
                    final code = _codeController.text.trim();
                    _verify(widget.emailPasson, code);
                  },
                  child: const Text(
                    'Verify',
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}