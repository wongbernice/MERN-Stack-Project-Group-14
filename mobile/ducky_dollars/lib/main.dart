import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'authPages/login.dart';
import 'authPages/signup.dart';
import 'inAppPages/home.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const ddWhite = const Color(0xfffefeff);
const ddSky = const Color(0xffd6efff);
const ddDarkApricot = const Color(0xfffed18c);
const ddLightApricot = const Color(0xfffed99b);
const ddPink = const Color(0xffffbbcd);

const ddBarBlue = const Color(0xff87cfeb);
const ddBarYellow = const Color(0xfffede2c);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ducky Dollars',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
      ),
      home: const MyLandingPage(title: 'Ducky Dollars'),
    );
  }
}

class MyLandingPage extends StatefulWidget {
  const MyLandingPage({super.key, required this.title});

  final String title;

  @override
  State<MyLandingPage> createState() => _MyLandingPage();
}

class _MyLandingPage extends State<MyLandingPage> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: ddBarBlue,
      body: Center(
        child: Column(
          children:[
            Text(
              "DUCKY\nDOLLARS",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'WendyOne',
                color: ddBarYellow,
                fontSize: 50.0,
                shadows: [
                  Shadow(
                    blurRadius: 10.0,
                    color: Colors.black.withOpacity(0.3),
                    offset: Offset(5.0, 5.0)
                  )
                ]
              )
            ),
            Center(
              child: Container(
                width: screenWidth * 0.9,
                child: Text("Keep your ducks in a row, and your budget too.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontFamily: 'Fredoka', fontWeight: FontWeight.w600, fontSize: 19.0)
                )
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                fixedSize: const Size(170, 40)
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              child: const Text('Login')
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                fixedSize: const Size(170, 40)
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignupPage()),
                );
              },
              child: const Text('Sign Up')
            ),
          ]
        )
      )
    );
  }
}