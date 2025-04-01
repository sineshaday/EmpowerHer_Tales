import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  User? _user;
  bool _loading = true;
  bool _updating = false;
  String _name = "Guest User";
  String _email = "guest@example.com";
  String _photoURL = "assets/profile_pic.png";
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    setState(() => _loading = true);
    _user = _auth.currentUser;

    if (_user == null) {
      setState(() {
        _nameController.text = _name;
        _loading = false;
      });
      return;
    }

    try {
      final DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(_user!.uid).get();

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>?;

        setState(() {
          _name = data?['name'] ?? _user!.displayName ?? 'Anonymous';
          _email = _user!.email ?? 'guest@example.com';
          _photoURL =
              data?['photoURL'] ?? _user!.photoURL ?? 'assets/profile_pic.png';
          _nameController.text = _name;
        });
      } else {
        setState(() {
          _name = _user!.displayName ?? 'Anonymous';
          _email = _user!.email ?? 'guest@example.com';
          _photoURL = _user!.photoURL ?? 'assets/profile_pic.png';
          _nameController.text = _name;
        });
      }
    } catch (e) {
      debugPrint("Error fetching user profile: $e");
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _updateName() async {
    if (_user == null ||
        _nameController.text.trim().isEmpty ||
        _nameController.text == _name)
      return;

    setState(() => _updating = true);
    try {
      await _firestore.collection('users').doc(_user!.uid).update({
        'name': _nameController.text.trim(),
      });
      setState(() {
        _name = _nameController.text.trim();
      });
    } catch (e) {
      debugPrint("Error updating name: $e");
    } finally {
      setState(() => _updating = false);
    }
  }

  Future<void> _uploadImage() async {
    if (_user == null) return;

    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile == null) return;

    setState(() => _updating = true);
    try {
      final File imageFile = File(pickedFile.path);
      final Reference ref = _storage.ref().child(
        'profile-images/${_user!.uid}',
      );
      await ref.putFile(imageFile);
      final String downloadURL = await ref.getDownloadURL();

      await _firestore.collection('users').doc(_user!.uid).update({
        'photoURL': downloadURL,
      });
      setState(() {
        _photoURL = downloadURL;
      });
    } catch (e) {
      debugPrint("Error uploading image: $e");
    } finally {
      setState(() => _updating = false);
    }
  }

  Future<void> _logout() async {
    await _auth.signOut();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 65,
                  backgroundColor: Colors.transparent,
                  backgroundImage:
                      _photoURL.startsWith('http')
                          ? NetworkImage(_photoURL)
                          : AssetImage(_photoURL) as ImageProvider,
                ),
                if (_user != null)
                  GestureDetector(
                    onTap: _uploadImage,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit,
                        color: Colors.pinkAccent,
                        size: 18,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 25),
            _buildEditableInfoBox(),
            const SizedBox(height: 10),
            _buildInfoBox(_email, 14.5),
            const SizedBox(height: 25),
            if (_user != null)
              SizedBox(
                width: 140,
                height: 42,
                child: ElevatedButton(
                  onPressed: _logout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 3,
                  ),
                  child: const Text(
                    'Log Out',
                    style: TextStyle(fontSize: 15, color: Colors.white),
                  ),
                ),
              ),
            if (_user == null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "You're browsing as a guest. ",
                      style: TextStyle(fontSize: 13),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      child: const Text(
                        'Log In',
                        style: TextStyle(
                          color: Colors.pinkAccent,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (_updating)
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableInfoBox() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      height: 40,
      width: 300,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3CD),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 3, offset: Offset(0, 1)),
        ],
      ),
      child: TextFormField(
        controller: _nameController,
        enabled: _user != null,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        decoration: const InputDecoration(border: InputBorder.none),
        onEditingComplete: _updateName,
      ),
    );
  }

  Widget _buildInfoBox(String text, double fontSize) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      height: 43,
      width: 300,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3CD),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 3, offset: Offset(0, 1)),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }
}
