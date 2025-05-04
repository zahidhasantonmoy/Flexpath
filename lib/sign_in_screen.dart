import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'job_feed_screen.dart'; // Replace with your actual home screen

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> _signIn() async {
    try {
      // Call the sign-in method using Supabase Authentication
      final response = await supabase.auth.signInWithPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      if (response.user != null) {
        // If sign-in is successful, navigate to the home screen (e.g., job feed)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => JobFeedScreen()), // Replace with your home screen
        );
      } else {
        // Display error if credentials are invalid
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign in failed: Invalid credentials')),
        );
      }
    } catch (e) {
      // Handle errors that occur during sign-in
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign in failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 100),
            // Title
            Text(
              'Sign In to FlexPath',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 40),

            // Email input field
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                contentPadding: EdgeInsets.all(12),
              ),
            ),
            SizedBox(height: 16),

            // Password input field
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
            SizedBox(height: 30),

            // Forgot password link
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () {
                  // Navigate to Forgot Password Screen
                  Navigator.pushNamed(context, '/reset-password'); // Ensure this route exists in your app
                },
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(color: Colors.blueAccent, fontSize: 14),
                ),
              ),
            ),
            SizedBox(height: 30),

            // Sign-in button
            ElevatedButton(
              onPressed: _signIn,
              child: Text('Sign In'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 80.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
