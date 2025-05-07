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
import 'dashboard_screen.dart';
import 'nid_verification_screen.dart';
import 'admin_nid_review_screen.dart';
import 'global_scaffold.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://epxapxmlwweiydgitpnq.supabase.co',
    anonKey:
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVweGFweG1sd3dlaXlkZ2l0cG5xIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDYzNzE4MjYsImV4cCI6MjA2MTk0NzgyNn0.n67p6qBtxDauTy0rD-9P0rUWhs0Z7FCtWhCz3c7ycWs',
  );

  runApp(const FlexPathApp());
}

class FlexPathApp extends StatelessWidget {
  const FlexPathApp({super.key});

  static void navigateToScreen(BuildContext context, String route) {
    final isAuthenticated = Supabase.instance.client.auth.currentUser != null;
    final restrictedRoutes = ['/homepage', '/signIn', '/signUp'];

    if (isAuthenticated && restrictedRoutes.contains(route)) {
      return;
    }

    Navigator.pushNamed(context, route);
  }

  static Future<void> logout(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();
    Navigator.pushNamedAndRemoveUntil(context, '/homepage', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = Supabase.instance.client.auth.currentUser != null;
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
      initialRoute: isAuthenticated ? '/dashboard' : '/homepage',
      routes: {
        '/homepage': (context) => const HomepageScreen(),
        '/signIn': (context) => const SignInScreen(),
        '/signUp': (context) => const SignUpScreen(),
        '/jobFeed': (context) => GlobalScaffold(
          route: '/jobFeed',
          child: const JobFeedScreen(),
        ),
        '/reset-password': (context) => const ResetPasswordScreen(),
        '/jobPost': (context) => GlobalScaffold(
          route: '/jobPost',
          child: const JobPostScreen(),
        ),
        '/profile': (context) => GlobalScaffold(
          route: '/profile',
          child: const ProfileScreen(),
        ),
        '/search': (context) => GlobalScaffold(
          route: '/search',
          child: const SearchScreen(),
        ),
        '/ratingFeedback': (context) => GlobalScaffold(
          route: '/ratingFeedback',
          child: const RatingFeedbackScreen(),
        ),
        '/payment': (context) => GlobalScaffold(
          route: '/payment',
          child: const PaymentScreen(),
        ),
        '/dashboard': (context) => GlobalScaffold(
          route: '/dashboard',
          child: const DashboardScreen(),
        ),
        '/nidVerification': (context) => GlobalScaffold(
          route: '/nidVerification',
          child: const NidVerificationScreen(),
        ),
        '/adminNidReview': (context) => GlobalScaffold(
          route: '/adminNidReview',
          child: const AdminNidReviewScreen(),
        ),
        '/viewProfile': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as String;
          return GlobalScaffold(
            route: '/viewProfile',
            child: ViewProfileScreen(userId: args),
          );
        },
      },
    );
  }
}