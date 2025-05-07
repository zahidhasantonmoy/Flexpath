import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'homepage_screen.dart';
import 'sign_in_screen.dart';
import 'sign_up_screen.dart';
import 'job_feed_screen.dart';
import 'reset_password_screen.dart';
import 'job_post_screen.dart';
import 'profile_screen.dart';
import 'search_screen.dart';
import 'view_profile_screen.dart';
import 'rating_feedback_screen.dart';
import 'payment_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://epxapxmlwweiydgitpnq.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVweGFweG1sd3dlaXlkZ2l0cG5xIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDYzNzE4MjYsImV4cCI6MjA2MTk0NzgyNn0.n67p6qBtxDauTy0rD-9P0rUWhs0Z7FCtWhCz3c7ycWs',
  );

  runApp(const FlexPathApp());
}

class FlexPathApp extends StatelessWidget {
  const FlexPathApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlexPath',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1A1A2E),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0F3460),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white, fontFamily: 'Poppins'),
          bodyMedium: TextStyle(color: Colors.white70, fontFamily: 'Poppins'),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: HomepageScreen(),
      routes: {
        '/homepage': (context) => HomepageScreen(),
        '/signIn': (context) => SignInScreen(),
        '/signUp': (context) => SignUpScreen(),
        '/jobFeed': (context) => JobFeedScreen(),
        '/reset-password': (context) => ResetPasswordScreen(),
        '/jobPost': (context) => JobPostScreen(),
        '/profile': (context) => ProfileScreen(),
        '/search': (context) => SearchScreen(),
        '/ratingFeedback': (context) => RatingFeedbackScreen(),
        '/payment': (context) => PaymentScreen(),
        '/viewProfile': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as String;
          return ViewProfileScreen(userId: args);
        },
      },
    );
  }
}