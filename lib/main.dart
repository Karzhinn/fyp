import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/Services/auth.provider.dart';
import 'package:graduation_project/constants/colors.dart';
import 'package:graduation_project/Screens/HomeScreen.dart';
import 'package:graduation_project/Screens/splash_screen.dart';
import 'package:graduation_project/Screens/LoginScreen.dart';
import 'package:graduation_project/Screens/ProfilePage.dart';
import 'package:graduation_project/Screens/SignupScreen.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with the generated options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppAuthProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Graduation Project',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          background: AppColors.background,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(color: AppColors.textPrimary),
          bodyLarge: TextStyle(color: AppColors.textPrimary),
          bodyMedium: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
          ),
          titleMedium: TextStyle(color: AppColors.textPrimary),
          labelLarge: TextStyle(color: AppColors.textSecondary),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          titleTextStyle: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.primary),
          ),
          labelStyle: TextStyle(color: AppColors.textSecondary),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
      ),

      // Show splash immediately:
      home: const SplashScreen(),

      // Named routes for auth flow:
      routes: {
        '/login': (context) => const Loginscreen(),
        '/signup': (context) => const Signupscreen(),
        '/home': (context) => const HomeScreen(),
        '/profile': (context) => const ProfilePage()
      },
    );
  }
}
