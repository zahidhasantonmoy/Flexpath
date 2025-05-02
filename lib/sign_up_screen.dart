import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart'; // For date formatting

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
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

  Future<void> _signUp() async {
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Passwords do not match')));
      return;
    }

    final profileImagePath = await _uploadImage(profileImage, 'profile-pictures');
    final nidImagePath = await _uploadImage(nidImage, 'nid-verifications');

    final userData = {
      'full_name': fullNameController.text,
      'mobile_number': mobileController.text,
      'email': emailController.text.isEmpty ? null : emailController.text,
      'date_of_birth': dobController.text,
      'nid_number': nidController.text,
      'profile_image': profileImagePath,
      'district': districtController.text,
      'upazila': upazilaController.text,
      'password': passwordController.text,
      'user_type': userType,
      'verification_status': verificationStatus,
      'created_at': DateTime.now().toIso8601String(),
      'skills': userType == 'worker' ? skillsController.text.split(',') : null,
      'primary_occupation': userType == 'worker' ? occupationController.text : null,
      'available_hours': userType == 'worker' ? availableHoursController.text : null,
      'expected_compensation': userType == 'worker' ? compensationController.text : null,
      'transportation': userType == 'worker' ? transportationController.text : null,
      'education': userType == 'worker' ? educationController.text : null,
      'company_name': userType == 'employer' ? companyNameController.text : null,
      'business_reg_number': userType == 'employer' ? businessRegController.text : null,
      'industry_sector': userType == 'employer' ? industryController.text : null,
      'company_size': userType == 'employer' ? companySizeController.text : null,
      'office_location': userType == 'employer' ? officeLocationController.text : null,
      'nid_image': nidImagePath,
    };

    final response = await supabase.from('users').insert([userData]).execute();
    if (response.error == null) {
      Navigator.pushNamed(context, '/signIn');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sign up failed: ${response.error!.message}')));
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
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    contentPadding: EdgeInsets.all(12),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: mobileController,
                  decoration: InputDecoration(
                    labelText: 'Mobile Number',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    contentPadding: EdgeInsets.all(12),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    contentPadding: EdgeInsets.all(12),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: dobController,
                  decoration: InputDecoration(
                    labelText: 'Date of Birth',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    contentPadding: EdgeInsets.all(12),
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
                      color: Colors.blueAccent.withOpacity(0.1),
                      boxShadow: [BoxShadow(color: Colors.blueAccent.withOpacity(0.2), blurRadius: 10)],
                    ),
                    child: profileImage == null
                        ? Icon(Icons.camera_alt, color: Colors.blueAccent, size: 50)
                        : CircleAvatar(backgroundImage: FileImage(File(profileImage!.path)), radius: 50),
                    alignment: Alignment.center,
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: districtController,
                  decoration: InputDecoration(
                    labelText: 'District',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    contentPadding: EdgeInsets.all(12),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: upazilaController,
                  decoration: InputDecoration(
                    labelText: 'Upazila',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    contentPadding: EdgeInsets.all(12),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    contentPadding: EdgeInsets.all(12),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    contentPadding: EdgeInsets.all(12),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: nidController,
                  decoration: InputDecoration(
                    labelText: 'NID Number',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    contentPadding: EdgeInsets.all(12),
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
                      color: Colors.grey.withOpacity(0.1),
                      boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 10)],
                    ),
                    child: nidImage == null
                        ? Icon(Icons.image, color: Colors.grey, size: 50)
                        : CircleAvatar(backgroundImage: FileImage(File(nidImage!.path)), radius: 50),
                    alignment: Alignment.center,
                  ),
                ),
                SizedBox(height: 16),
                if (userType == 'worker')
                  Column(
                    children: [
                      TextField(
                        controller: skillsController,
                        decoration: InputDecoration(
                          labelText: 'Skills (comma-separated)',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                          contentPadding: EdgeInsets.all(12),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: occupationController,
                        decoration: InputDecoration(
                          labelText: 'Primary Occupation',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                          contentPadding: EdgeInsets.all(12),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: availableHoursController,
                        decoration: InputDecoration(
                          labelText: 'Available Hours',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                          contentPadding: EdgeInsets.all(12),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: compensationController,
                        decoration: InputDecoration(
                          labelText: 'Expected Compensation',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                          contentPadding: EdgeInsets.all(12),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: transportationController,
                        decoration: InputDecoration(
                          labelText: 'Transportation Options',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                          contentPadding: EdgeInsets.all(12),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: educationController,
                        decoration: InputDecoration(
                          labelText: 'Educational Qualifications',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                          contentPadding: EdgeInsets.all(12),
                        ),
                      ),
                    ],
                  ),
                if (userType == 'employer')
                  Column(
                    children: [
                      TextField(
                        controller: companyNameController,
                        decoration: InputDecoration(
                          labelText: 'Company/Business Name',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                          contentPadding: EdgeInsets.all(12),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: businessRegController,
                        decoration: InputDecoration(
                          labelText: 'Business Registration Number',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                          contentPadding: EdgeInsets.all(12),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: industryController,
                        decoration: InputDecoration(
                          labelText: 'Industry Sector',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                          contentPadding: EdgeInsets.all(12),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: companySizeController,
                        decoration: InputDecoration(
                          labelText: 'Company Size',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                          contentPadding: EdgeInsets.all(12),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: officeLocationController,
                        decoration: InputDecoration(
                          labelText: 'Office/Work Location',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                          contentPadding: EdgeInsets.all(12),
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
                    backgroundColor: MaterialStateProperty.all(Colors.green),
                    padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 16.0, horizontal: 80.0)),
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
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