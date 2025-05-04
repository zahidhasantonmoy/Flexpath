import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:animate_do/animate_do.dart';
import 'sign_in_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController mobileNumberController = TextEditingController();
  final TextEditingController dateOfBirthController = TextEditingController();
  final TextEditingController nidNumberController = TextEditingController();
  final TextEditingController districtController = TextEditingController();
  final TextEditingController upazilaController = TextEditingController();
  final TextEditingController skillsController = TextEditingController();
  final TextEditingController primaryOccupationController = TextEditingController();
  final TextEditingController availableHoursController = TextEditingController();
  final TextEditingController expectedCompensationController = TextEditingController();
  final TextEditingController transportationController = TextEditingController();
  final TextEditingController educationController = TextEditingController();
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController businessRegNumberController = TextEditingController();
  final TextEditingController industrySectorController = TextEditingController();
  final TextEditingController companySizeController = TextEditingController();
  final TextEditingController officeLocationController = TextEditingController();

  String userType = 'Job Seeker';
  File? profileImage;
  File? nidImage;
  bool _isLoading = false;

  Future<void> _pickImage({required bool isProfile}) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (isProfile) {
          profileImage = File(pickedFile.path);
        } else {
          nidImage = File(pickedFile.path);
        }
      });
    }
  }

  Future<String?> _uploadImage(File image, String bucket, String path) async {
    try {
      final response = await supabase.storage.from(bucket).upload(path, image);
      return response;
    } catch (e) {
      _showErrorDialog('Image upload failed: $e');
      return null;
    }
  }

  Future<void> _signUp() async {
    setState(() => _isLoading = true);

    final email = emailController.text.trim().toLowerCase();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showErrorDialog('Email and password are required');
      setState(() => _isLoading = false);
      return;
    }

    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email)) {
      _showErrorDialog('Please enter a valid email address');
      setState(() => _isLoading = false);
      return;
    }

    if (password.length < 6) {
      _showErrorDialog('Password must be at least 6 characters');
      setState(() => _isLoading = false);
      return;
    }

    if (password != confirmPassword) {
      _showErrorDialog('Passwords do not match');
      setState(() => _isLoading = false);
      return;
    }

    try {
      // Sign up user with Supabase Auth
      final response = await supabase.auth.signUp(email: email, password: password);
      final userId = response.user?.id;

      if (userId == null) {
        _showErrorDialog('Sign up failed: Unable to create user');
        setState(() => _isLoading = false);
        return;
      }

      // Upload images if provided
      String? profileImageUrl;
      String? nidImageUrl;

      if (profileImage != null) {
        profileImageUrl = await _uploadImage(
          profileImage!,
          'profile-pictures',
          '$userId/profile.jpg',
        );
      }

      if (nidImage != null) {
        nidImageUrl = await _uploadImage(
          nidImage!,
          'nid-verifications',
          '$userId/nid.jpg',
        );
      }

      // Prepare user data
      final userData = {
        'id': userId,
        'full_name': fullNameController.text.trim(),
        'mobile_number': mobileNumberController.text.trim(),
        'email': email,
        'date_of_birth': dateOfBirthController.text.trim(),
        'nid_number': nidNumberController.text.trim(),
        'profile_image': profileImageUrl,
        'district': districtController.text.trim(),
        'upazila': upazilaController.text.trim(),
        'user_type': userType,
        'verification_status': 'pending',
        'skills': skillsController.text.trim().split(',').map((e) => e.trim()).toList(),
        'primary_occupation': primaryOccupationController.text.trim(),
        'available_hours': availableHoursController.text.trim(),
        'expected_compensation': expectedCompensationController.text.trim(),
        'transportation': transportationController.text.trim(),
        'education': educationController.text.trim(),
        'company_name': companyNameController.text.trim(),
        'business_reg_number': businessRegNumberController.text.trim(),
        'industry_sector': industrySectorController.text.trim(),
        'company_size': companySizeController.text.trim(),
        'office_location': officeLocationController.text.trim(),
        'nid_image': nidImageUrl,
      };

      // Insert user data into the users table
      await supabase.from('users').insert(userData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign up successful! Please sign in.')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SignInScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Sign up failed: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.redAccent, size: 30),
            SizedBox(width: 10),
            Text('Error', style: TextStyle(color: Colors.blueGrey[700], fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(message, style: TextStyle(color: Colors.blueGrey[600])),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: TextStyle(color: Colors.blueAccent)),
          ),
        ],
      ),
    );
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
          child: Stack(
            fit: StackFit.expand,
            children: [
              SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height),
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 60),
                        FadeInDown(
                          duration: Duration(milliseconds: 800),
                          child: Text(
                            'Sign Up to FlexPath',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey[700],
                              letterSpacing: 1.5,
                              shadows: [
                                Shadow(
                                  blurRadius: 10,
                                  color: Colors.blueAccent.withAlpha(77),
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 40),
                        FadeInUp(
                          duration: Duration(milliseconds: 800),
                          delay: Duration(milliseconds: 200),
                          child: TextField(
                            controller: emailController,
                            style: TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              labelText: 'Email *',
                              labelStyle: TextStyle(color: Colors.blueGrey),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                              ),
                              contentPadding: EdgeInsets.all(12),
                              prefixIcon: Icon(Icons.email, color: Colors.blueAccent),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        FadeInUp(
                          duration: Duration(milliseconds: 800),
                          delay: Duration(milliseconds: 300),
                          child: TextField(
                            controller: passwordController,
                            obscureText: true,
                            style: TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              labelText: 'Password *',
                              labelStyle: TextStyle(color: Colors.blueGrey),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                              ),
                              contentPadding: EdgeInsets.all(12),
                              prefixIcon: Icon(Icons.lock, color: Colors.blueAccent),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        FadeInUp(
                          duration: Duration(milliseconds: 800),
                          delay: Duration(milliseconds: 400),
                          child: TextField(
                            controller: confirmPasswordController,
                            obscureText: true,
                            style: TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              labelText: 'Confirm Password *',
                              labelStyle: TextStyle(color: Colors.blueGrey),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                              ),
                              contentPadding: EdgeInsets.all(12),
                              prefixIcon: Icon(Icons.lock, color: Colors.blueAccent),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        FadeInUp(
                          duration: Duration(milliseconds: 800),
                          delay: Duration(milliseconds: 500),
                          child: TextField(
                            controller: fullNameController,
                            style: TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              labelText: 'Full Name',
                              labelStyle: TextStyle(color: Colors.blueGrey),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                              ),
                              contentPadding: EdgeInsets.all(12),
                              prefixIcon: Icon(Icons.person, color: Colors.blueAccent),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        FadeInUp(
                          duration: Duration(milliseconds: 800),
                          delay: Duration(milliseconds: 600),
                          child: TextField(
                            controller: mobileNumberController,
                            style: TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              labelText: 'Mobile Number',
                              labelStyle: TextStyle(color: Colors.blueGrey),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                              ),
                              contentPadding: EdgeInsets.all(12),
                              prefixIcon: Icon(Icons.phone, color: Colors.blueAccent),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        FadeInUp(
                          duration: Duration(milliseconds: 800),
                          delay: Duration(milliseconds: 700),
                          child: TextField(
                            controller: dateOfBirthController,
                            style: TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              labelText: 'Date of Birth (YYYY-MM-DD)',
                              labelStyle: TextStyle(color: Colors.blueGrey),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                              ),
                              contentPadding: EdgeInsets.all(12),
                              prefixIcon: Icon(Icons.calendar_today, color: Colors.blueAccent),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        FadeInUp(
                          duration: Duration(milliseconds: 800),
                          delay: Duration(milliseconds: 800),
                          child: TextField(
                            controller: nidNumberController,
                            style: TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              labelText: 'NID Number',
                              labelStyle: TextStyle(color: Colors.blueGrey),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                              ),
                              contentPadding: EdgeInsets.all(12),
                              prefixIcon: Icon(Icons.credit_card, color: Colors.blueAccent),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        FadeInUp(
                          duration: Duration(milliseconds: 800),
                          delay: Duration(milliseconds: 900),
                          child: TextField(
                            controller: districtController,
                            style: TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              labelText: 'District',
                              labelStyle: TextStyle(color: Colors.blueGrey),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                              ),
                              contentPadding: EdgeInsets.all(12),
                              prefixIcon: Icon(Icons.location_city, color: Colors.blueAccent),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        FadeInUp(
                          duration: Duration(milliseconds: 800),
                          delay: Duration(milliseconds: 1000),
                          child: TextField(
                            controller: upazilaController,
                            style: TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              labelText: 'Upazila',
                              labelStyle: TextStyle(color: Colors.blueGrey),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                              ),
                              contentPadding: EdgeInsets.all(12),
                              prefixIcon: Icon(Icons.location_on, color: Colors.blueAccent),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        FadeInUp(
                          duration: Duration(milliseconds: 800),
                          delay: Duration(milliseconds: 1100),
                          child: DropdownButtonFormField<String>(
                            value: userType,
                            items: ['Job Seeker', 'Employer']
                                .map((type) => DropdownMenuItem(value: type, child: Text(type, style: TextStyle(color: Colors.white))))
                                .toList(),
                            onChanged: (value) {
                              setState(() => userType = value!);
                            },
                            decoration: InputDecoration(
                              labelText: 'User Type *',
                              labelStyle: TextStyle(color: Colors.blueGrey),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                              ),
                              contentPadding: EdgeInsets.all(12),
                              prefixIcon: Icon(Icons.person_pin, color: Colors.blueAccent),
                            ),
                          ),
                        ),
                        if (userType == 'Job Seeker') ...[
                          SizedBox(height: 16),
                          FadeInUp(
                            duration: Duration(milliseconds: 800),
                            delay: Duration(milliseconds: 1200),
                            child: TextField(
                              controller: skillsController,
                              style: TextStyle(color: Colors.black),
                              decoration: InputDecoration(
                                labelText: 'Skills (comma-separated)',
                                labelStyle: TextStyle(color: Colors.blueGrey),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                                ),
                                contentPadding: EdgeInsets.all(12),
                                prefixIcon: Icon(Icons.build, color: Colors.blueAccent),
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          FadeInUp(
                            duration: Duration(milliseconds: 800),
                            delay: Duration(milliseconds: 1300),
                            child: TextField(
                              controller: primaryOccupationController,
                              style: TextStyle(color: Colors.black),
                              decoration: InputDecoration(
                                labelText: 'Primary Occupation',
                                labelStyle: TextStyle(color: Colors.blueGrey),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                                ),
                                contentPadding: EdgeInsets.all(12),
                                prefixIcon: Icon(Icons.work, color: Colors.blueAccent),
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          FadeInUp(
                            duration: Duration(milliseconds: 800),
                            delay: Duration(milliseconds: 1400),
                            child: TextField(
                              controller: availableHoursController,
                              style: TextStyle(color: Colors.black),
                              decoration: InputDecoration(
                                labelText: 'Available Hours',
                                labelStyle: TextStyle(color: Colors.blueGrey),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                                ),
                                contentPadding: EdgeInsets.all(12),
                                prefixIcon: Icon(Icons.access_time, color: Colors.blueAccent),
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          FadeInUp(
                            duration: Duration(milliseconds: 800),
                            delay: Duration(milliseconds: 1500),
                            child: TextField(
                              controller: expectedCompensationController,
                              style: TextStyle(color: Colors.black),
                              decoration: InputDecoration(
                                labelText: 'Expected Compensation',
                                labelStyle: TextStyle(color: Colors.blueGrey),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                                ),
                                contentPadding: EdgeInsets.all(12),
                                prefixIcon: Icon(Icons.attach_money, color: Colors.blueAccent),
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          FadeInUp(
                            duration: Duration(milliseconds: 800),
                            delay: Duration(milliseconds: 1600),
                            child: TextField(
                              controller: transportationController,
                              style: TextStyle(color: Colors.black),
                              decoration: InputDecoration(
                                labelText: 'Transportation',
                                labelStyle: TextStyle(color: Colors.blueGrey),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                                ),
                                contentPadding: EdgeInsets.all(12),
                                prefixIcon: Icon(Icons.directions_car, color: Colors.blueAccent),
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          FadeInUp(
                            duration: Duration(milliseconds: 800),
                            delay: Duration(milliseconds: 1700),
                            child: TextField(
                              controller: educationController,
                              style: TextStyle(color: Colors.black),
                              decoration: InputDecoration(
                                labelText: 'Education',
                                labelStyle: TextStyle(color: Colors.blueGrey),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                                ),
                                contentPadding: EdgeInsets.all(12),
                                prefixIcon: Icon(Icons.school, color: Colors.blueAccent),
                              ),
                            ),
                          ),
                        ],
                        if (userType == 'Employer') ...[
                          SizedBox(height: 16),
                          FadeInUp(
                            duration: Duration(milliseconds: 800),
                            delay: Duration(milliseconds: 1200),
                            child: TextField(
                              controller: companyNameController,
                              style: TextStyle(color: Colors.black),
                              decoration: InputDecoration(
                                labelText: 'Company Name',
                                labelStyle: TextStyle(color: Colors.blueGrey),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                                ),
                                contentPadding: EdgeInsets.all(12),
                                prefixIcon: Icon(Icons.business, color: Colors.blueAccent),
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          FadeInUp(
                            duration: Duration(milliseconds: 800),
                            delay: Duration(milliseconds: 1300),
                            child: TextField(
                              controller: businessRegNumberController,
                              style: TextStyle(color: Colors.black),
                              decoration: InputDecoration(
                                labelText: 'Business Registration Number',
                                labelStyle: TextStyle(color: Colors.blueGrey),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                                ),
                                contentPadding: EdgeInsets.all(12),
                                prefixIcon: Icon(Icons.description, color: Colors.blueAccent),
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          FadeInUp(
                            duration: Duration(milliseconds: 800),
                            delay: Duration(milliseconds: 1400),
                            child: TextField(
                              controller: industrySectorController,
                              style: TextStyle(color: Colors.black),
                              decoration: InputDecoration(
                                labelText: 'Industry Sector',
                                labelStyle: TextStyle(color: Colors.blueGrey),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                                ),
                                contentPadding: EdgeInsets.all(12),
                                prefixIcon: Icon(Icons.factory, color: Colors.blueAccent),
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          FadeInUp(
                            duration: Duration(milliseconds: 800),
                            delay: Duration(milliseconds: 1500),
                            child: TextField(
                              controller: companySizeController,
                              style: TextStyle(color: Colors.black),
                              decoration: InputDecoration(
                                labelText: 'Company Size',
                                labelStyle: TextStyle(color: Colors.blueGrey),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                                ),
                                contentPadding: EdgeInsets.all(12),
                                prefixIcon: Icon(Icons.group, color: Colors.blueAccent),
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          FadeInUp(
                            duration: Duration(milliseconds: 800),
                            delay: Duration(milliseconds: 1600),
                            child: TextField(
                              controller: officeLocationController,
                              style: TextStyle(color: Colors.black),
                              decoration: InputDecoration(
                                labelText: 'Office Location',
                                labelStyle: TextStyle(color: Colors.blueGrey),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                                ),
                                contentPadding: EdgeInsets.all(12),
                                prefixIcon: Icon(Icons.location_on, color: Colors.blueAccent),
                              ),
                            ),
                          ),
                        ],
                        SizedBox(height: 16),
                        FadeInUp(
                          duration: Duration(milliseconds: 800),
                          delay: Duration(milliseconds: 1800),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => _pickImage(isProfile: true),
                                  style: ButtonStyle(
                                    backgroundColor: WidgetStateProperty.all(Colors.blueAccent),
                                    shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                                  ),
                                  child: Text(
                                    profileImage == null ? 'Upload Profile Image' : 'Profile Image Selected',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => _pickImage(isProfile: false),
                                  style: ButtonStyle(
                                    backgroundColor: WidgetStateProperty.all(Colors.blueAccent),
                                    shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                                  ),
                                  child: Text(
                                    nidImage == null ? 'Upload NID Image' : 'NID Image Selected',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 30),
                        FadeInUp(
                          duration: Duration(milliseconds: 800),
                          delay: Duration(milliseconds: 1900),
                          child: ZoomIn(
                            duration: Duration(milliseconds: 300),
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _signUp,
                              style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.all(Colors.green),
                                padding: WidgetStateProperty.all(EdgeInsets.symmetric(vertical: 16.0, horizontal: 80.0)),
                                shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                                elevation: WidgetStateProperty.all(5),
                                shadowColor: WidgetStateProperty.all(Colors.green.withAlpha(128)),
                              ),
                              child: _isLoading
                                  ? CircularProgressIndicator(color: Colors.white)
                                  : Text(
                                'Sign Up',
                                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 16,
                left: 16,
                child: FadeInLeft(
                  duration: Duration(milliseconds: 800),
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.blueGrey[700], size: 30),
                    onPressed: () => Navigator.pushReplacementNamed(context, '/homepage'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}