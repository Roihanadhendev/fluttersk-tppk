import 'package:flutter/material.dart';
import 'package:kp_tppk/pages/login.dart';
import 'package:kp_tppk/screen/home_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  

  @override
  Widget build(BuildContext context) {

    Future.delayed(Duration(seconds: 3)).then((value) => {
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => LoginPage()), (route) => false)
    });

    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            child: Image.asset('assets/images/splash_screen.png',
            fit: BoxFit.cover,),
          )
        ],
      ),
    );
  }
}
