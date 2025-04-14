import 'package:flutter/material.dart';
import 'package:graduation_project/LoginScreen.dart'; 

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Add a delay of 3 seconds before navigating to the login screen
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Loginscreen()), // Navigate to LoginScreen
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff3E3F5B),
      body: SizedBox(
        width: double.infinity,
        child: Center(
          // child: Image.asset("assets/splash_logo.png"),
        ),
      ),
    );
  }
}
