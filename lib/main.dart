import 'package:flutter/material.dart';
import 'screens/forum.dart';

void main() {
  runApp(const EmpowerHerTalesApp());
}

class EmpowerHerTalesApp extends StatelessWidget {
  const EmpowerHerTalesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home:
          const ForumPage(), // Directly setting ForumScreen as the home screen
    );
  }
}
