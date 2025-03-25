import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import '../auth/authservice.dart';
import '../routes/routes.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  User? currentUser;
  Map<String, dynamic>? userDetails;
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    currentUser = _authService.currentUser;
    if (currentUser != null) {
      try {
        final docSnapshot = await _firestore
            .collection('users')
            .doc(currentUser!.uid)
            .get();
        
        setState(() {
          userDetails = docSnapshot.data();
        });
      } catch (e) {
        print('Error fetching user details: $e');
      }
    }
  }

  Future<void> _pickProfileImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50, // Reduce image quality to save storage
    );
    
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
      
      await _uploadProfileImage();
    }
  }

  Future<void> _uploadProfileImage() async {
    if (_profileImage == null || currentUser == null) return;

    try {
      Reference reference = _storage
        .ref()
        .child('profile_images/${currentUser!.uid}.jpg');

      await reference.putFile(_profileImage!);

      String imageUrl = await reference.getDownloadURL();

      await _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .update({'profileImageUrl': imageUrl});

      await _fetchUserDetails();
    } catch (e) {
      print('Error uploading profile image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to upload image: $e'),
          backgroundColor: Colors.green.shade700,
        )
      );
    }
  }

  Future<void> _logout() async {
    await _authService.signOut();
    Navigator.of(context).pushReplacementNamed(Routes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5DC), // Beige background
      appBar: AppBar(
        title: Text('Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF4CAF50), // Green app bar
        elevation: 0,
      ),
      body: currentUser == null 
        ? Center(
            child: CircularProgressIndicator(
              color: Color(0xFF4CAF50), // Green loading indicator
            )
          )
        : SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile Image
                  GestureDetector(
                    onTap: _pickProfileImage,
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Color(0xFF4CAF50), // Green border
                              width: 4,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 80,
                            backgroundImage: userDetails?['profileImageUrl'] != null
                              ? NetworkImage(userDetails!['profileImageUrl'])
                              : _profileImage != null
                                ? FileImage(_profileImage!)
                                : AssetImage('assets/user.jpg') as ImageProvider,
                            child: userDetails?['profileImageUrl'] == null && _profileImage == null
                              ? Icon(Icons.camera_alt, size: 50, color: Colors.white)
                              : null,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Color(0xFF4CAF50), // Green edit button
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: Icon(Icons.edit, color: Colors.white),
                              onPressed: _pickProfileImage,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),

                  // User Details
                  _buildProfileSection(
                    title: 'Personal Information',
                    children: [
                      _buildDetailRow(
                        icon: Icons.person,
                        label: 'Name',
                        value: userDetails?['displayName'] ?? currentUser?.displayName ?? 'Not set',
                      ),
                      _buildDetailRow(
                        icon: Icons.email,
                        label: 'Email',
                        value: currentUser?.email ?? 'Not available',
                      ),
                    ],
                  ),

                  // Dog Details
                  _buildProfileSection(
                    title: 'Dog Information',
                    children: [
                      _buildDetailRow(
                        icon: Icons.pets,
                        label: 'Dog Name',
                        value: userDetails?['dogName'] ?? 'Not set',
                      ),
                      _buildDetailRow(
                        icon: Icons.cake,
                        label: 'Dog Birthday',
                        value: userDetails?['dogDob'] != null 
                          ? _formatDate(userDetails!['dogDob']) 
                          : 'Not set',
                      ),
                      _buildDetailRow(
                        icon: Icons.category,
                        label: 'Dog Breed',
                        value: userDetails?['dogBreed'] ?? 'Not set',
                      ),
                    ],
                  ),

                  SizedBox(height: 30),

                  // Logout Button
                  ElevatedButton.icon(
                    onPressed: _logout,
                    icon: Icon(Icons.logout, color: Colors.white),
                    label: Text('Logout', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade400,
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  // Helper method to format date
  String _formatDate(dynamic dateValue) {
    DateTime date;
    if (dateValue is Timestamp) {
      date = dateValue.toDate();
    } else if (dateValue is DateTime) {
      date = dateValue;
    } else {
      return 'Invalid Date';
    }
    return DateFormat('dd/MM/yyyy').format(date);
  }

  // Reusable profile section widget
  Widget _buildProfileSection({
    required String title, 
    required List<Widget> children,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32), // Dark green
            ),
          ),
          Divider(color: Colors.green.shade200),
          ...children,
        ],
      ),
    );
  }

  // Reusable detail row widget
  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Color(0xFF4CAF50), size: 24),
          SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.green.shade700,
                  fontSize: 14,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.green.shade900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}