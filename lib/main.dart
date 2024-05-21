import 'package:kp_tppk/pages/login.dart';
import 'package:kp_tppk/pages/register.dart';
import 'package:kp_tppk/pages/resetpage.dart';
import 'package:kp_tppk/screen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:kp_tppk/screen/splas_screen.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    initialRoute: '/',
    onGenerateRoute: (RouteSettings settings) {
      switch (settings.name) {
        case '/':
          return MaterialPageRoute(builder: (context) => const MyApp());
        case '/home':
          return MaterialPageRoute(builder: (context) => const HomePage());
        case '/resetPassword':
          return MaterialPageRoute(builder: (context) => const ResetPage());
        case '/register':
          return MaterialPageRoute(builder: (context) => const RegisterPage());
        case '/login':
          return MaterialPageRoute(builder: (context) => const LoginPage());
        default:
          return MaterialPageRoute(builder: (context) => MyApp());
      }
    },
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false, home: const SplashScreen());
  }
}
