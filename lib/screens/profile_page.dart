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
  String _name = "";
  String _email = "";
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
      Future.microtask(() {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      });
      return;
    }

    try {
      final DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(_user!.uid).get();

      if (userDoc.exists) {
        setState(() {
          _name = userDoc['name'] ?? _user!.displayName ?? 'Anonymous';
          _email = _user!.email ?? '';
          _photoURL =
              userDoc['photoURL'] ??
              _user!.photoURL ??
              'assets/profile_pic.png';
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
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile == null || _user == null) return;

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
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.transparent,
                  backgroundImage:
                      _photoURL.startsWith('http')
                          ? NetworkImage(_photoURL)
                          : AssetImage(_photoURL) as ImageProvider,
                ),
                GestureDetector(
                  onTap: _uploadImage,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26.withAlpha(51),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: Colors.redAccent,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            _buildEditableInfoBox(),
            const SizedBox(height: 10),
            _buildInfoBox(_email, 16),
            const SizedBox(height: 25),
            SizedBox(
              width: 120,
              child: ElevatedButton(
                onPressed: _logout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE91E63),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'Log Out',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
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
      width: 280,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3CD),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextFormField(
        controller: _nameController,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 18,
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
      width: 280,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3CD),
        borderRadius: BorderRadius.circular(10),
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
