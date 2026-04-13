import 'package:flutter/material.dart';
import 'package:ducky_dollars/main.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ducky_dollars/services/authStorage.dart';
import 'package:cristalyse/cristalyse.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Create new category
  Future<void> _newCategory(String name, budgetLimit) async{
    try {
      final token = await AuthStorage.getToken();
      final response = await http.post(
          Uri.parse('http://67.205.159.14:5000/api/categories'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token'
          },
          body: jsonEncode(<String, dynamic>{
            'name': name,
            'budgetLimit': budgetLimit,
          }
          )
      );

      print(response.statusCode);

      if (response.statusCode == 200) {
        /*
        final responseData = jsonDecode(response.body);
        final verificationState = responseData['isVerified'];
        result = 'id: ${responseData['id']}\nisVerified: ${responseData['isVerified']}\nemail: ${responseData['email']}\nerror: ${responseData['error']}';
        if (verificationState == 'False') {
        } else {
        }
        */
      } else if (response.statusCode == 401) {
        Error();
      }
    } catch (e) {
      setState(() {
        // _errorMessage = 'Unexpected error occurred';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ddSky,
      body: Column(
        children: [
          Text(
            "This is where we would keep the graphs...if we had any",
            style: TextStyle(color: Colors.black.withValues(alpha: 0.4)),
            textAlign: TextAlign.center
          ),
          ElevatedButton(
            child: const Text(
              "Logout"
            ), onPressed: () async {
              await AuthStorage.deleteToken();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MyLandingPage(title: 'Ducky Dollars')),
              );
          },
          ),
          ElevatedButton(
            child: const Text(
                "Test"
            ), onPressed: () async {
            _newCategory('Test', 450);
          },
          )
        ])
    );
  }
}