import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'homepage_screen.dart';  // Your homepage screen
import 'sign_in_screen.dart';   // Your SignIn screen
import 'sign_up_screen.dart';   // Your SignUp screen
import 'job_feed_screen.dart';  // Your Job Feed screen

void main() async {
  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://eybnfjhttwgestlyiqkx.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV5Ym5mamh0dHdnZXN0bHlpcWt4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDYxNjQ5MDUsImV4cCI6MjA2MTc0MDkwNX0.GY-HeNqfn6g6LnQ4Fv1Hv79AFhV5p2qFG5sDmjfUU_o',
  );

  runApp(FlexPathApp());
}

class FlexPathApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlexPath',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false, // Disable debug banner
      home: HomepageScreen(),  // Your homepage screen
      routes: {
        '/signIn': (context) => SignInScreen(),  // Route to Sign In
        '/signUp': (context) => SignUpScreen(),  // Route to Sign Up
        '/jobFeed': (context) => JobFeedScreen(), // Add Job Feed screen route
      },
    );
  }
}
