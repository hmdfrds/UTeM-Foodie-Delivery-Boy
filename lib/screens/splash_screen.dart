
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:foodir_delivery/screens/home_screen.dart';
import 'package:foodir_delivery/screens/login_screen.dart';





class SplashScreen extends StatefulWidget {
  static const String id = 'splash-screen';

  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override

  // do this when the screen is called
  void initState() {
    // make a timer how long the screen will be shown then navigate to another screen
    Timer(
        const Duration(
          seconds: 3,
        ), () {
      // Get the whether the user is logged in or not
      FirebaseAuth.instance.authStateChanges().listen((User? user) {
        // User is not logged in
        if (user == null) {
          Navigator.pushReplacementNamed(context, LoginScreen.id);
        } else {
          // User is Logged in
          // Navigate to Home Screen
          Navigator.pushReplacementNamed(context, HomeScreen.id);
        }
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Hero(tag: "logo", child: SvgPicture.asset(
          'images/icon re.svg',
         
        ),),
      ),
    );
  }
}
