import 'dart:io'; // For File class
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';  // For picking profile image

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController companyController = TextEditingController();
  XFile? profileImage; // Variable to store profile image
  String userType = 'worker'; // Default to worker

  // Pick profile image
  Future<void> _pickProfileImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedImage = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      profileImage = pickedImage;
    });
  }

  // Sign up function to insert data into Supabase
  Future<void> _signUp() async {
    try {
      String? imagePath = profileImage != null ? await _uploadProfileImage(File(profileImage!.path)) : null;

      final response = await supabase.from('users').insert([
        {
          'email': emailController.text,
          'password': passwordController.text,
          'phone': phoneController.text,
          'user_type': userType, // Either 'worker' or 'employer'
          'company_name': userType == 'employer' ? companyController.text : null, // Only for employer
          'profile_image': imagePath, // Store profile image path
          'created_at': DateTime.now().toIso8601String(),
          'role': 'user' // Default role
        }
      ]).execute();

      if (response.error == null) {
        print('User signed up successfully');
        Navigator.pushNamed(context, '/signIn'); // Navigate to Sign In screen
      } else {
        print('Error signing up: ${response.error!.message}');
      }
    } catch (e) {
      print('Exception: $e');
    }
  }

  // Upload image to Supabase
  Future<String?> _uploadProfileImage(File imageFile) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.png'; // Unique file name
      final filePath = 'profile-pictures/$fileName'; // Path in Supabase

      final response = await supabase.storage.from('profile-pictures').upload(filePath, imageFile);
      if (response.error != null) {
        print('Error uploading image: ${response.error!.message}');
        return null;
      }

      return filePath; // Return file path after upload
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign Up')),
      body: SingleChildScrollView( // Scrollable to avoid overflow
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Profile Image Upload Button
            GestureDetector(
              onTap: _pickProfileImage,
              child: profileImage == null
                  ? Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blueAccent.withOpacity(0.1),
                ),
                child: Icon(Icons.camera_alt, color: Colors.blueAccent, size: 50),
              )
                  : CircleAvatar(
                radius: 50,
                backgroundImage: FileImage(File(profileImage!.path)),
              ),
            ),
            SizedBox(height: 30),
            // Full Name, Phone, Email, Password fields
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(labelText: 'Phone'),
            ),
            SizedBox(height: 16),
            // Company Name (Only for Employer)
            if (userType == 'employer')
              TextField(
                controller: companyController,
                decoration: InputDecoration(labelText: 'Company Name'),
              ),
            SizedBox(height: 20),
            // Worker or Employer Radio Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Worker'),
                Radio(value: 'worker', groupValue: userType, onChanged: (value) {
                  setState(() {
                    userType = value!;
                  });
                }),
                Text('Employer'),
                Radio(value: 'employer', groupValue: userType, onChanged: (value) {
                  setState(() {
                    userType = value!;
                  });
                }),
              ],
            ),
            SizedBox(height: 30),
            // Register Button
            ElevatedButton(
              onPressed: _signUp,
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.greenAccent),
                padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 16.0, horizontal: 80.0)),
                shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
              ),
              child: Text(
                'Register',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
