import 'package:empowerher_tales/pages/login.dart';
import 'package:empowerher_tales/services/authService.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Text(
              'logged as: ${authService.value.currentUser!.displayName}',
            ),
          ),
          GestureDetector(
            onTap: () async {
              await authService.value.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
            child: Text('logout'),
          ),
        ],
      ),
    );
  }
}
