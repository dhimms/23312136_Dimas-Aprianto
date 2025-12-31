import 'package:flutter/material.dart';
import 'screens/gym_chat_screen.dart'; // Import screen dari folder screens

void main() {
  runApp(const IronCoachApp());
}

class IronCoachApp extends StatelessWidget {
  const IronCoachApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IronDims AI',
      debugShowCheckedModeBanner: false,
      // TEMA APLIKASI: Dark Mode dengan Aksen Neon Green
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212), // Hitam pekat
        primaryColor: Colors.lightGreenAccent,
        colorScheme: const ColorScheme.dark(
          primary: Colors.lightGreenAccent,
          secondary: Colors.tealAccent,
          surface: Color(0xFF1E1E1E),
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF121212),
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.lightGreenAccent,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ),
      home: const GymChatScreen(),
    );
  }
}
