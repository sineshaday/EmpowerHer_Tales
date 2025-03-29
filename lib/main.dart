import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'story_screen.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_core/firebase_core.dart';
=======
import 'screens/profile_page.dart';

>>>>>>> 513f63d248137ece3b0af12725cb16314b4c7c8a
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
<<<<<<< HEAD
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
          child: const Text('Go to Stories'),
        ),
      ),
    );
  }
}

=======
      home:
          const ProfilePage(), // Directly setting ForumScreen as the home screen
    );
  }
}
>>>>>>> 513f63d248137ece3b0af12725cb16314b4c7c8a
