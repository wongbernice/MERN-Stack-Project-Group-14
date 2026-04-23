import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

const signupGreen = Color(0xffbde081);
const loginBlue = Color(0xff94d4ed);

const _themeModePreferenceKey = 'theme_mode';
final ValueNotifier<ThemeMode> appThemeModeNotifier =
    ValueNotifier<ThemeMode>(ThemeMode.system);

ThemeData buildLightAppTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: ddBarBlue,
      secondary: ddBarYellow,
      surface: ddWhite,
      onPrimary: ddBarYellow,
      onSecondary: Colors.black,
      onSurface: Colors.black,
    ),
  );
}

ThemeData buildDarkAppTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(
      primary: ddBarBlue,
      secondary: ddBarYellow,
      surface: Color(0xff121821),
      onPrimary: Colors.black,
      onSecondary: Colors.black,
      onSurface: Colors.white,
    ),
  );
}

ThemeMode _themeModeFromString(String? value) {
  switch (value) {
    case 'light':
      return ThemeMode.light;
    case 'dark':
      return ThemeMode.dark;
    case 'system':
    default:
      return ThemeMode.system;
  }
}

String _themeModeToString(ThemeMode mode) {
  switch (mode) {
    case ThemeMode.light:
      return 'light';
    case ThemeMode.dark:
      return 'dark';
    case ThemeMode.system:
      return 'system';
  }
}

Future<void> loadAppThemeMode() async {
  final preferences = await SharedPreferences.getInstance();
  appThemeModeNotifier.value =
      _themeModeFromString(preferences.getString(_themeModePreferenceKey));
}

Future<void> setAppThemeMode(ThemeMode mode) async {
  appThemeModeNotifier.value = mode;
  final preferences = await SharedPreferences.getInstance();
  await preferences.setString(
      _themeModePreferenceKey, _themeModeToString(mode));
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadAppThemeMode();
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
      theme: buildLightAppTheme(),
      themeMode: ThemeMode.light,
      home: const AuthGate(),
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

    return Theme(
      data: buildLightAppTheme(),
      child: Scaffold(
          body: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/summer_background_47_a.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                    SizedBox(
                      width: screenWidth * 0.72,
                      child: Image.asset(
                        'assets/Logo-Mobile-1.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    Center(
                      child: SizedBox(
                          width: screenWidth * 0.7,
                          child: const Text(
                              "Keep your ducks in a row, and your budget too.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontFamily: 'Fredoka',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 19.0))),
                    ),
                    const SizedBox(height: 10),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                fixedSize: const Size(170, 40),
                                backgroundColor: ddBarYellow,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5))),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Theme(
                                          data: buildLightAppTheme(),
                                          child: const LoginPage(),
                                        )),
                              );
                            },
                            child: const Text('Login')),
                        const SizedBox(height: 10),
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                fixedSize: const Size(170, 40),
                                backgroundColor: signupGreen,
                                foregroundColor: Colors.black,
                                side:
                                    BorderSide(color: ddBarYellow, width: 1.5),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5))),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Theme(
                                          data: buildLightAppTheme(),
                                          child: const SignupPage(),
                                        )),
                              );
                            },
                            child: const Text('Sign Up')),
                      ],
                    )
                  ])))),
    );
  }
}
