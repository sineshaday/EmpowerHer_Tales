//import 'package:empowerher_tales_login_and_signup/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';
//import 'login.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  SignUpScreenState createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpScreen> {
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  //final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Firebase sign-up method
  Future<void> _signUp() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      
      if (userCredential.user != null) {
        // Successfully signed up, navigate to Home Screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => EmpowerHerTalesApp()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Sign Up Failed: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset("assets/home1.jpg", height: 150),
            ),
            SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Enter your name",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 15),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Enter your email",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 15),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Create your password",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            TextField(
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 15),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Confirm your password",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            TextField(
              obscureText: !_isConfirmPasswordVisible,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isConfirmPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EmpowerHerTalesApp(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text("Sign Up", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
