import 'package:flutter/material.dart';
import 'package:graduation_project/SignupScreen.dart';
import 'dart:async';
import 'package:graduation_project/splash_screen.dart';
import 'package:device_preview/device_preview.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(), // Splash screen widget
    );
  }
}

// class MyWidget extends StatefulWidget {
//   const MyWidget({super.key});

//   @override
//   _MyWidgetState createState() => _MyWidgetState();
// }

// class _MyWidgetState extends State<MyWidget> {
//   @override
//   void initState() {
//     super.initState();
//     // Set a delay of 3 seconds before navigating to the main screen
//     Future.delayed(Duration(seconds: 3), () {
//       // Navigate to HomeScreen after the delay
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => Signupscreen()),
//       );
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color(0xff3E3F5B),  // Optional, adjust according to your theme
//       body: Center(
      
//       ),
//     );
//   }
// }

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text("Welcome to the Home Screen")),
    );
  }
}