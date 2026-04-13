import 'package:flutter/material.dart';
import 'authPages/login.dart';
import 'authPages/signup.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const ddWhite = Color(0xfffefeff);
const ddSky = Color(0xffd6efff);
const ddDarkApricot = Color(0xfffed18c);
const ddLightApricot = Color(0xfffed99b);
const ddPink = Color(0xffffbbcd);

const ddBarBlue = Color(0xff87cfeb);
const ddBarYellow = Color(0xfffede2c);

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
                    color: Colors.black.withValues(alpha: 0.3),
                    offset: const Offset(5.0, 5.0)
                  )
                ]
              )
            ),
            Center(
              child: SizedBox(
                width: screenWidth * 0.9,
                child: const Text("Keep your ducks in a row, and your budget too.",
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