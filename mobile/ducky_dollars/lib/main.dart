import 'package:flutter/material.dart';
import 'authPages/login.dart';
import 'authPages/signup.dart';
import 'services/authStorage.dart';
import 'inAppPages/home.dart';

const ddWhite = Color(0xfffefeff);
const ddSky = Color(0xffd6efff);
const ddDarkApricot = Color(0xfffed18c);
const ddLightApricot = Color(0xfffed99b);
const ddPink = Color(0xffffbbcd);

const ddBarBlue = Color(0xff87cfeb);
const ddBarYellow = Color(0xfffede2c);

void main() async{
  // WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  Future<bool> isLoggedIn() async {
    final token = await AuthStorage.getToken();
    return token != null && token.isNotEmpty && token != 'auth_token';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: isLoggedIn(),
      builder: (context, snapshot) {
        // Loading state
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Decide screen
        if (snapshot.data == true) {
          return const HomePage();
        } else {
          return const MyLandingPage(title: 'Ducky Dollars');
        }
      },
    );
  }
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
      home: AuthGate()
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