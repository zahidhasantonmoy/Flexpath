import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:animate_do/animate_do.dart';
import 'job_feed_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController forgotPasswordEmailController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController nidController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _signIn() async {
    setState(() => _isLoading = true);
    try {
      final response = await supabase.auth.signInWithPassword(
        email: emailController.text.trim().toLowerCase(),
        password: passwordController.text,
      );
      if (!mounted) return;
      if (response.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => JobFeedScreen()),
        );
      } else {
        _showErrorDialog('Sign in failed: Invalid credentials');
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog('Sign in failed: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _resetPasswordDirectly() async {
    final email = forgotPasswordEmailController.text.trim().toLowerCase();
    final dob = dobController.text.trim();
    final nid = nidController.text.trim();
    final newPassword = newPasswordController.text.trim();

    if (email.isEmpty || dob.isEmpty || nid.isEmpty || newPassword.isEmpty) {
      if (!mounted) return;
      _showErrorDialog('Please fill in all fields');
      return;
    }

    if (newPassword.length < 6) {
      if (!mounted) return;
      _showErrorDialog('New password must be at least 6 characters');
      return;
    }

    try {
      // Verify user exists with matching email, DOB, and NID
      final response = await supabase
          .from('users')
          .select()
          .eq('email', email)
          .eq('date_of_birth', dob)
          .eq('nid_number', nid)
          .maybeSingle();

      if (!mounted) return;
      if (response == null) {
        _showErrorDialog('No user found with the provided details');
        return;
      }

      // Get the user ID from the authenticated session or response
      final user = supabase.auth.currentUser;
      if (user == null || user.email != email) {
        await supabase.auth.signInWithPassword(email: email, password: newPassword); // Sign in to get session
      }

      // Update the password directly
      await supabase.auth.updateUser(UserAttributes(password: newPassword));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Password updated successfully! Please sign in with the new password.')),
        );
        Navigator.pop(context); // Close the dialog
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog('Error updating password: $e');
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

  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text('Reset Password', style: TextStyle(color: Colors.blueGrey[700], fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: forgotPasswordEmailController,
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Colors.blueGrey),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  contentPadding: EdgeInsets.all(12),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: dobController,
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  labelText: 'Date of Birth (YYYY-MM-DD)',
                  labelStyle: TextStyle(color: Colors.blueGrey),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  contentPadding: EdgeInsets.all(12),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: nidController,
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  labelText: 'NID Number',
                  labelStyle: TextStyle(color: Colors.blueGrey),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  contentPadding: EdgeInsets.all(12),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  labelText: 'New Password',
                  labelStyle: TextStyle(color: Colors.blueGrey),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  contentPadding: EdgeInsets.all(12),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              await _resetPasswordDirectly();
            },
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.blueAccent),
              shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
            ),
            child: Text('Reset', style: TextStyle(color: Colors.white)),
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
                            'Sign In to FlexPath',
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
                              labelText: 'Email',
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
                              labelText: 'Password',
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
                        SizedBox(height: 20),
                        FadeInUp(
                          duration: Duration(milliseconds: 800),
                          delay: Duration(milliseconds: 400),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: _showForgotPasswordDialog,
                              child: Bounce(
                                duration: Duration(milliseconds: 500),
                                child: Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                    color: Colors.blueAccent,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 30),
                        FadeInUp(
                          duration: Duration(milliseconds: 800),
                          delay: Duration(milliseconds: 500),
                          child: ZoomIn(
                            duration: Duration(milliseconds: 300),
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _signIn,
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
                                'Sign In',
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