import 'package:flutter/material.dart';
import 'story_screen.dart';

void main() {
  runApp(const EmpowerHerTalesApp());
}

class EmpowerHerTalesApp extends StatelessWidget {
  const EmpowerHerTalesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Women Empowerment App',
      theme: ThemeData(
        primaryColor: const Color(0xFFFFC0CB),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFFC0CB),
          primary: const Color(0xFFFFC0CB),
        ),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Women Empowerment App'),
        backgroundColor: const Color(0xFFFFC0CB),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const StoryScreen(),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 238, 217, 227),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Go to Stories'),
        ),
      ),
    );
  }
}

