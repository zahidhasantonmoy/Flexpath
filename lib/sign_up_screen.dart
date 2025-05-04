import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController nidController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController districtController = TextEditingController();
  final TextEditingController upazilaController = TextEditingController();
  XFile? profileImage;
  String userType = 'worker';
  String? verificationStatus = 'Pending';
  final ImagePicker _picker = ImagePicker();
  final TextEditingController skillsController = TextEditingController();
  final TextEditingController occupationController = TextEditingController();
  final TextEditingController availableHoursController = TextEditingController();
  final TextEditingController compensationController = TextEditingController();
  final TextEditingController transportationController = TextEditingController();
  final TextEditingController educationController = TextEditingController();
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController businessRegController = TextEditingController();
  final TextEditingController industryController = TextEditingController();
  final TextEditingController companySizeController = TextEditingController();
  final TextEditingController officeLocationController = TextEditingController();
  XFile? nidImage;

  Future<void> _pickProfileImage() async {
    final XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    setState(() => profileImage = pickedImage);
  }

  Future<void> _pickNidImage() async {
    final XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    setState(() => nidImage = pickedImage);
  }

  Future<String?> _uploadImage(XFile? image, String pathPrefix) async {
    if (image == null) return null;
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.png';
    final filePath = '$pathPrefix/$fileName';
    await supabase.storage.from(pathPrefix).upload(filePath, File(image.path));
    return filePath;
  }

  bool _isValidEmail(String email) {
    // Enhanced email validation to match Supabase requirements
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(email)) return false;
    // Ensure local part (before @) is at least 3 characters
    final localPart = email.split('@')[0];
    if (localPart.length < 3) return false;
    // Ensure no consecutive dots or invalid characters
    if (localPart.contains('..') || localPart.startsWith('.') || localPart.endsWith('.')) return false;
    return true;
  }

  Future<void> _signUp() async {
    final email = emailController.text.trim().toLowerCase();
    final password = passwordController.text;

    if (password != confirmPasswordController.text) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Passwords do not match')),
        );
      }
      return;
    }

    if (email.isEmpty || !_isValidEmail(email)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please enter a valid email (e.g., example@gmail.com)')),
        );
      }
      return;
    }

    if (password.isEmpty || password.length < 6) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Password must be at least 6 characters')),
        );
      }
      return;
    }

    try {
      // Sign up the user with Supabase Auth
      final authResponse = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Sign up failed: Unable to create user')),
          );
        }
        return;
      }

      final profileImagePath = await _uploadImage(profileImage, 'profile-pictures');
      final nidImagePath = await _uploadImage(nidImage, 'nid-verifications');

      final userData = {
        'id': authResponse.user!.id,
        'full_name': fullNameController.text.isEmpty ? null : fullNameController.text,
        'mobile_number': mobileController.text.isEmpty ? null : mobileController.text,
        'email': email,
        'date_of_birth': dobController.text.isEmpty ? null : dobController.text,
        'nid_number': nidController.text.isEmpty ? null : nidController.text,
        'profile_image': profileImagePath,
        'district': districtController.text.isEmpty ? null : districtController.text,
        'upazila': upazilaController.text.isEmpty ? null : upazilaController.text,
        'user_type': userType,
        'verification_status': verificationStatus,
        'created_at': DateTime.now().toIso8601String(),
        'skills': userType == 'worker' && skillsController.text.isNotEmpty ? skillsController.text.split(',') : null,
        'primary_occupation': userType == 'worker' && occupationController.text.isNotEmpty ? occupationController.text : null,
        'available_hours': userType == 'worker' && availableHoursController.text.isNotEmpty ? availableHoursController.text : null,
        'expected_compensation': userType == 'worker' && compensationController.text.isNotEmpty ? compensationController.text : null,
        'transportation': userType == 'worker' && transportationController.text.isNotEmpty ? transportationController.text : null,
        'education': userType == 'worker' && educationController.text.isNotEmpty ? educationController.text : null,
        'company_name': userType == 'employer' && companyNameController.text.isNotEmpty ? companyNameController.text : null,
        'business_reg_number': userType == 'employer' && businessRegController.text.isNotEmpty ? businessRegController.text : null,
        'industry_sector': userType == 'employer' && industryController.text.isNotEmpty ? industryController.text : null,
        'company_size': userType == 'employer' && companySizeController.text.isNotEmpty ? companySizeController.text : null,
        'office_location': userType == 'employer' && officeLocationController.text.isNotEmpty ? officeLocationController.text : null,
        'nid_image': nidImagePath,
      };

      // Insert user data into the 'users' table
      await supabase.from('users').insert(userData);

      if (mounted) {
        Navigator.pushNamed(context, '/signIn');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign up failed: $e')),
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => dobController.text = DateFormat('yyyy-MM-dd').format(picked));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade100, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 20),
                Text(
                  'Register with FlexPath',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey[700],
                    letterSpacing: 1.5,
                  ),
                ),
                SizedBox(height: 40),
                TextField(
                  controller: fullNameController,
                  style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    contentPadding: EdgeInsets.all(12),
                    labelStyle: TextStyle(color: Colors.blueGrey),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: mobileController,
                  style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    labelText: 'Mobile Number',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    contentPadding: EdgeInsets.all(12),
                    labelStyle: TextStyle(color: Colors.blueGrey),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    labelText: 'Email Address *',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    contentPadding: EdgeInsets.all(12),
                    labelStyle: TextStyle(color: Colors.blueGrey),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: dobController,
                  style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    labelText: 'Date of Birth',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    contentPadding: EdgeInsets.all(12),
                    labelStyle: TextStyle(color: Colors.blueGrey),
                  ),
                  onTap: () => _selectDate(context),
                ),
                SizedBox(height: 16),
                GestureDetector(
                  onTap: _pickProfileImage,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blueAccent.withAlpha(26),
                      boxShadow: [BoxShadow(color: Colors.blueAccent.withAlpha(51), blurRadius: 10)],
                    ),
                    alignment: Alignment.center,
                    child: profileImage == null
                        ? Icon(Icons.camera_alt, color: Colors.blueAccent, size: 50)
                        : CircleAvatar(backgroundImage: FileImage(File(profileImage!.path)), radius: 50),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: districtController,
                  style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    labelText: 'District',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    contentPadding: EdgeInsets.all(12),
                    labelStyle: TextStyle(color: Colors.blueGrey),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: upazilaController,
                  style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    labelText: 'Upazila',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    contentPadding: EdgeInsets.all(12),
                    labelStyle: TextStyle(color: Colors.blueGrey),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    labelText: 'Password *',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    contentPadding: EdgeInsets.all(12),
                    labelStyle: TextStyle(color: Colors.blueGrey),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    labelText: 'Confirm Password *',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    contentPadding: EdgeInsets.all(12),
                    labelStyle: TextStyle(color: Colors.blueGrey),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: nidController,
                  style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    labelText: 'NID Number',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    contentPadding: EdgeInsets.all(12),
                    labelStyle: TextStyle(color: Colors.blueGrey),
                  ),
                ),
                SizedBox(height: 16),
                GestureDetector(
                  onTap: _pickNidImage,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.withAlpha(26),
                      boxShadow: [BoxShadow(color: Colors.grey.withAlpha(51), blurRadius: 10)],
                    ),
                    alignment: Alignment.center,
                    child: nidImage == null
                        ? Icon(Icons.image, color: Colors.grey, size: 50)
                        : CircleAvatar(backgroundImage: FileImage(File(nidImage!.path)), radius: 50),
                  ),
                ),
                SizedBox(height: 16),
                if (userType == 'worker')
                  Column(
                    children: [
                      TextField(
                        controller: skillsController,
                        style: TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          labelText: 'Skills (comma-separated)',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                          contentPadding: EdgeInsets.all(12),
                          labelStyle: TextStyle(color: Colors.blueGrey),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: occupationController,
                        style: TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          labelText: 'Primary Occupation',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                          contentPadding: EdgeInsets.all(12),
                          labelStyle: TextStyle(color: Colors.blueGrey),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: availableHoursController,
                        style: TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          labelText: 'Available Hours',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                          contentPadding: EdgeInsets.all(12),
                          labelStyle: TextStyle(color: Colors.blueGrey),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: compensationController,
                        style: TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          labelText: 'Expected Compensation',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                          contentPadding: EdgeInsets.all(12),
                          labelStyle: TextStyle(color: Colors.blueGrey),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: transportationController,
                        style: TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          labelText: 'Transportation Options',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                          contentPadding: EdgeInsets.all(12),
                          labelStyle: TextStyle(color: Colors.blueGrey),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: educationController,
                        style: TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          labelText: 'Educational Qualifications',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                          contentPadding: EdgeInsets.all(12),
                          labelStyle: TextStyle(color: Colors.blueGrey),
                        ),
                      ),
                    ],
                  ),
                if (userType == 'employer')
                  Column(
                    children: [
                      TextField(
                        controller: companyNameController,
                        style: TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          labelText: 'Company/Business Name',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                          contentPadding: EdgeInsets.all(12),
                          labelStyle: TextStyle(color: Colors.blueGrey),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: businessRegController,
                        style: TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          labelText: 'Business Registration Number',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                          contentPadding: EdgeInsets.all(12),
                          labelStyle: TextStyle(color: Colors.blueGrey),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: industryController,
                        style: TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          labelText: 'Industry Sector',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                          contentPadding: EdgeInsets.all(12),
                          labelStyle: TextStyle(color: Colors.blueGrey),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: companySizeController,
                        style: TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          labelText: 'Company Size',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                          contentPadding: EdgeInsets.all(12),
                          labelStyle: TextStyle(color: Colors.blueGrey),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: officeLocationController,
                        style: TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          labelText: 'Office/Work Location',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                          contentPadding: EdgeInsets.all(12),
                          labelStyle: TextStyle(color: Colors.blueGrey),
                        ),
                      ),
                    ],
                  ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Worker'),
                    Radio(value: 'worker', groupValue: userType, onChanged: (value) => setState(() => userType = value!)),
                    Text('Employer'),
                    Radio(value: 'employer', groupValue: userType, onChanged: (value) => setState(() => userType = value!)),
                  ],
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _signUp,
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(Colors.green),
                    padding: WidgetStateProperty.all(EdgeInsets.symmetric(vertical: 16.0, horizontal: 80.0)),
                    shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                  ),
                  child: Text(
                    'Register',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                SizedBox(height: 20),
                Text('Verification Status: $verificationStatus', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}