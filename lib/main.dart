import 'package:flutter/material.dart';
import 'screens/forum.dart';
import 'home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();  // Ensures Flutter is fully initialized
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,  // Firebase initialization
  );
  
  runApp(const EmpowerHerTalesApp());
}

class EmpowerHerTalesApp extends StatelessWidget {
  const EmpowerHerTalesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/forum.': (context) => const ForumPage(),
      }
          //const HomeScreen(), // Directly setting ForumScreen as the home screen
    );
  }
}
