import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:animate_do/animate_do.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'global_menu.dart';
import 'sidebar_menu.dart';
import 'main.dart';

class AdminNidReviewScreen extends StatefulWidget {
  const AdminNidReviewScreen({super.key});

  @override
  State<AdminNidReviewScreen> createState() => _AdminNidReviewScreenState();
}

class _AdminNidReviewScreenState extends State<AdminNidReviewScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  bool _isLoading = false;
  List<Map<String, dynamic>> _verifications = [];

  @override
  void initState() {
    super.initState();
    _fetchPendingVerifications();
  }

  Future<void> _fetchPendingVerifications() async {
    setState(() => _isLoading = true);
    try {
      final verifications = await supabase
          .from('nid_verifications')
          .select('id, user_id, nid_number, front_image_url, back_image_url, verification_status, users!inner(full_name)')
          .eq('verification_status', 'pending');
      _verifications = List<Map<String, dynamic>>.from(verifications);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching verifications: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateVerificationStatus(String verificationId, String userId, String status) async {
    setState(() => _isLoading = true);
    try {
      // Update nid_verifications table
      await supabase
          .from('nid_verifications')
          .update({
        'verification_status': status,
        'updated_at': DateTime.now().toIso8601String(),
      })
          .eq('id', verificationId);

      // Update users table
      await supabase
          .from('users')
          .update({
        'verification_status': status,
      })
          .eq('id', userId);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verification $status successfully!')),
      );
      await _fetchPendingVerifications();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update verification: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _navigateToScreen(String route) {
    FlexPathApp.navigateToScreen(context, route);
  }

  Future<void> _logout() async {
    await FlexPathApp.logout(context);
  }

  Widget _buildVerificationCard(Map<String, dynamic> verification) {
    return FadeInUp(
      duration: Duration(milliseconds: 800),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: Colors.teal.withOpacity(0.3), width: 1),
        ),
        color: Colors.white.withOpacity(0.95),
        margin: EdgeInsets.symmetric(vertical: 8.0),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'User: ${verification['users']['full_name']}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey[700],
                  fontFamily: 'Poppins',
                ),
              ),
              SizedBox(height: 10),
              Text(
                'NID Number: ${verification['nid_number']}',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blueGrey[700],
                  fontFamily: 'Poppins',
                ),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Image.network(
                      verification['front_image_url'],
                      height: 150,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(Icons.error, color: Colors.red),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Image.network(
                      verification['back_image_url'],
                      height: 150,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(Icons.error, color: Colors.red),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ZoomIn(
                    duration: Duration(milliseconds: 300),
                    child: ElevatedButton(
                      onPressed: () => _updateVerificationStatus(
                          verification['id'], verification['user_id'], 'approved'),
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(Colors.green),
                        padding: WidgetStateProperty.all(
                            EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
                        shape: WidgetStateProperty.all(
                            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      ),
                      child: Row(
                        children: [
                          FaIcon(FontAwesomeIcons.check, color: Colors.white, size: 16),
                          SizedBox(width: 5),
                          Text(
                            'Approve',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Poppins',
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ZoomIn(
                    duration: Duration(milliseconds: 300),
                    child: ElevatedButton(
                      onPressed: () => _updateVerificationStatus(
                          verification['id'], verification['user_id'], 'rejected'),
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(Colors.red),
                        padding: WidgetStateProperty.all(
                            EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
                        shape: WidgetStateProperty.all(
                            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      ),
                      child: Row(
                        children: [
                          FaIcon(FontAwesomeIcons.times, color: Colors.white, size: 16),
                          SizedBox(width: 5),
                          Text(
                            'Reject',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Poppins',
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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
            colors: [Colors.teal.shade100, Colors.purple.shade100],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              _isLoading
                  ? Center(child: CircularProgressIndicator(color: Colors.teal))
                  : SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        FadeInDown(
                          duration: Duration(milliseconds: 800),
                          child: Text(
                            'NID Verification Review',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey[700],
                              fontFamily: 'Poppins',
                              shadows: [
                                Shadow(
                                  blurRadius: 10,
                                  color: Colors.teal.withAlpha(77),
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(height: 20),
                        if (_verifications.isEmpty)
                          FadeInUp(
                            duration: Duration(milliseconds: 800),
                            child: Text(
                              'No pending verifications',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.blueGrey[700],
                                fontFamily: 'Poppins',
                              ),
                            ),
                          )
                        else
                          ..._verifications.map((verification) => _buildVerificationCard(verification)).toList(),
                      ],
                    ),
                  ),
                ),
              ),
              GlobalMenu(
                navigateToScreen: _navigateToScreen,
                logout: _logout,
              ),
            ],
          ),
        ),
      ),
    );
  }
}