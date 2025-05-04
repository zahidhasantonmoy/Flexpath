import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart'; // For loading animation



class HomepageScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade200,
      body: SafeArea(
        child: Column(
          children: [
            // Main content centered in the middle of the screen
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Minimize the column size to fit content
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'FlexPath',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2.0,
                      ),
                    ),
                    SizedBox(height: 40),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/signIn');
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 100),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.teal, Colors.green],
                          ),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          'Sign In',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/signUp');
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 100),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.green, Colors.yellow],
                          ),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          'Sign Up',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Footer at the bottom
            Column(
              children: [
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('About Us'),
                          content: Text(
                            'FlexPath is a mobile-first platform designed to connect workers and employers for flexible, short-term gigs. Focused on the unique needs of Bangladesh, it provides an accessible solution for individuals looking to monetize their idle hours while giving employers access to a pool of local talent for micro-tasks. Whether you\'re a student looking for part-time work, a rural artisan seeking to showcase your crafts, or a small business in need of quick assistance, FlexPath bridges the gap. With features like job feeds, user profiles, real-time messaging, and local payment integration through Bkash, FlexPath aims to redefine the gig economy by offering a simple, secure, and empowering platform for Bangladesh’s diverse workforce.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('Close'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Text(
                    'About Us',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ),
                SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Terms & Conditions'),
                          content: Text(
                            '''Acceptance of Terms
By accessing or using the FlexPath application, you agree to comply with and be bound by the following terms and conditions. If you do not agree with these terms, do not use the App.

User Registration
Users must provide accurate information during registration. You agree to keep your login credentials confidential and notify FlexPath immediately in case of any unauthorized use of your account.

Privacy Policy
Your privacy is important to us. FlexPath will collect personal information only as needed for providing the services. By using the App, you consent to the collection and use of your information as outlined in our Privacy Policy.

User Responsibilities
For Workers: You agree to provide truthful and complete information about your skills, availability, and work history. You are responsible for managing your job applications and ensuring the quality of your work.
For Employers: You are responsible for providing accurate job descriptions and fair compensation. You agree to treat workers respectfully and follow the applicable labor laws.

Prohibited Activities
You must not:
- Engage in unlawful or fraudulent activities.
- Post jobs that violate the rights of others or are misleading.
- Use the App to harass, threaten, or discriminate against any user.

Payments
FlexPath integrates with Bkash and other local payment methods to ensure secure transactions. You agree to use these services responsibly. All payments are processed according to the platform’s guidelines.

Rating and Reviews
Both workers and employers are encouraged to leave ratings and reviews after completing a task. These reviews should be honest, and FlexPath reserves the right to remove any inappropriate or offensive feedback.

Intellectual Property
All content provided by FlexPath, including logos, designs, and software, remains the property of FlexPath. You are granted a limited, non-transferable license to use the App in accordance with these terms.

Limitation of Liability
FlexPath will not be liable for any damages resulting from the use or inability to use the App. We make no guarantees regarding the availability or quality of jobs posted or completed.

Modifications to Terms
FlexPath reserves the right to update or modify these Terms and Conditions at any time. Any changes will be posted on the App, and your continued use will indicate acceptance of the updated terms.

Termination
FlexPath reserves the right to suspend or terminate your account for violation of these terms, without prior notice.

Governing Law
These Terms and Conditions are governed by the laws of Bangladesh. Any disputes will be resolved in the appropriate courts in Bangladesh.

For more details or inquiries, please contact FlexPath support at monekostomathanosto@gmail.com''',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('Close'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Text(
                    'Terms & Conditions',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ),
                SizedBox(height: 10),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
