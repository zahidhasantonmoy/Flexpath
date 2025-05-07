import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:animate_do/animate_do.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'sidebar_menu.dart';

class ViewProfileScreen extends StatefulWidget {
  final String userId;

  const ViewProfileScreen({super.key, required this.userId});

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  Map<String, dynamic>? userData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final response = await supabase.from('users').select().eq('id', widget.userId).single();
      if (mounted) {
        setState(() {
          userData = response;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load profile: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToScreen(String route) {
    Navigator.pushNamed(context, route);
  }

  Future<void> _logout() async {
    await supabase.auth.signOut();
    Navigator.pushNamedAndRemoveUntil(context, '/homepage', (route) => false);
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
      drawer: SidebarMenu(
        navigateToScreen: _navigateToScreen,
        logout: _logout,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F3460), Color(0xFF1A1A2E)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              _isLoading
                  ? Center(child: CircularProgressIndicator(color: Colors.teal))
                  : _errorMessage != null
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.white70, fontFamily: 'Poppins', fontSize: 18),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isLoading = true;
                          _errorMessage = null;
                        });
                        _fetchUserData();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(
                        'Retry',
                        style: TextStyle(color: Colors.white, fontFamily: 'Poppins'),
                      ),
                    ),
                  ],
                ),
              )
                  : userData == null
                  ? Center(
                child: Text(
                  'Profile not found',
                  style: TextStyle(color: Colors.white70, fontFamily: 'Poppins', fontSize: 18),
                ),
              )
                  : SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20),
                      FadeInDown(
                        duration: Duration(milliseconds: 800),
                        child: Center(
                          child: CircleAvatar(
                            radius: 60,
                            backgroundImage: userData!['profile_image'] != null
                                ? NetworkImage(userData!['profile_image'])
                                : null,
                            backgroundColor: Colors.teal,
                            child: userData!['profile_image'] == null
                                ? FaIcon(FontAwesomeIcons.user, color: Colors.white, size: 40)
                                : null,
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      FadeInUp(
                        duration: Duration(milliseconds: 800),
                        delay: Duration(milliseconds: 200),
                        child: Center(
                          child: Text(
                            userData!['full_name'] ?? 'Unknown',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      FadeInUp(
                        duration: Duration(milliseconds: 800),
                        delay: Duration(milliseconds: 300),
                        child: Center(
                          child: Text(
                            userData!['user_type'] ?? 'Unknown',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white70,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      FadeInUp(
                        duration: Duration(milliseconds: 800),
                        delay: Duration(milliseconds: 400),
                        child: Card(
                          color: Colors.white.withOpacity(0.1),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildInfoRow(
                                  FaIcon(FontAwesomeIcons.user, color: Colors.teal),
                                  'User Type',
                                  userData!['user_type'] ?? 'N/A',
                                ),
                                _buildInfoRow(
                                  FaIcon(FontAwesomeIcons.calendar, color: Colors.teal),
                                  'Date of Birth',
                                  userData!['date_of_birth'] ?? 'N/A',
                                ),
                                _buildInfoRow(
                                  FaIcon(FontAwesomeIcons.checkCircle, color: Colors.teal),
                                  'Verification Status',
                                  userData!['verification_status'] ?? 'N/A',
                                ),
                                _buildInfoRow(
                                  FaIcon(FontAwesomeIcons.locationDot, color: Colors.teal),
                                  'Location',
                                  '${userData!['district'] ?? 'N/A'}, ${userData!['upazila'] ?? 'N/A'}',
                                ),
                                if (userData!['user_type'] == 'Job Seeker') ...[
                                  _buildInfoRow(
                                    FaIcon(FontAwesomeIcons.tools, color: Colors.teal),
                                    'Skills',
                                    (userData!['skills'] as List<dynamic>?)?.join(', ') ?? 'N/A',
                                  ),
                                  _buildInfoRow(
                                    FaIcon(FontAwesomeIcons.briefcase, color: Colors.teal),
                                    'Primary Occupation',
                                    userData!['primary_occupation'] ?? 'N/A',
                                  ),
                                  _buildInfoRow(
                                    FaIcon(FontAwesomeIcons.clock, color: Colors.teal),
                                    'Available Hours',
                                    userData!['available_hours'] ?? 'N/A',
                                  ),
                                  _buildInfoRow(
                                    FaIcon(FontAwesomeIcons.graduationCap, color: Colors.teal),
                                    'Education',
                                    userData!['education'] ?? 'N/A',
                                  ),
                                  _buildInfoRow(
                                    FaIcon(FontAwesomeIcons.trophy, color: Colors.teal),
                                    'Jobs Completed',
                                    userData!['job_completed']?.toString() ?? '0',
                                  ),
                                ],
                                if (userData!['user_type'] == 'Employer') ...[
                                  _buildInfoRow(
                                    FaIcon(FontAwesomeIcons.star, color: Colors.teal),
                                    'Rating',
                                    userData!['rating']?.toStringAsFixed(1) ?? '0.0',
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (userData!['user_type'] == 'Employer' &&
                          userData!['feedbacks'] != null &&
                          (userData!['feedbacks'] as List).isNotEmpty) ...[
                        SizedBox(height: 16),
                        FadeInUp(
                          duration: Duration(milliseconds: 800),
                          delay: Duration(milliseconds: 500),
                          child: Card(
                            color: Colors.white.withOpacity(0.1),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Feedbacks',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.teal,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  ...List.generate(
                                    (userData!['feedbacks'] as List).length,
                                        (index) => Padding(
                                      padding: EdgeInsets.symmetric(vertical: 4.0),
                                      child: Row(
                                        children: [
                                          FaIcon(FontAwesomeIcons.comment, color: Colors.teal, size: 16),
                                          SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              userData!['feedbacks'][index] ?? 'N/A',
                                              style: TextStyle(
                                                color: Colors.white70,
                                                fontFamily: 'Poppins',
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 16,
                left: 16,
                child: FadeInLeft(
                  duration: Duration(milliseconds: 800),
                  child: IconButton(
                    icon: FaIcon(FontAwesomeIcons.arrowLeft, color: Colors.teal, size: 30),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(Widget icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          icon,
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.teal,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.white70,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}