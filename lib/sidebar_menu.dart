import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:animate_do/animate_do.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SidebarMenu extends StatefulWidget {
  final Function(String) navigateToScreen;
  final VoidCallback logout;

  const SidebarMenu({
    super.key,
    required this.navigateToScreen,
    required this.logout,
  });

  @override
  State<SidebarMenu> createState() => _SidebarMenuState();
}

class _SidebarMenuState extends State<SidebarMenu> {
  final SupabaseClient supabase = Supabase.instance.client;
  bool _isAdmin = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
  }

  Future<void> _fetchUserRole() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      final response = await supabase
          .from('users')
          .select('role')
          .eq('id', userId)
          .single();

      setState(() {
        _isAdmin = response['role'] == 'admin';
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching user role: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;
    final userId = user?.id;
    final email = user?.email ?? 'No Email';

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.75,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.teal.shade700,
              Colors.purple.shade600,
              Colors.blue.shade600,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 0.5, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: Colors.white))
            : Column(
          children: [
            Container(
              padding: EdgeInsets.only(top: 50, bottom: 20),
              child: Column(
                children: [
                  ElasticIn(
                    duration: Duration(milliseconds: 1000),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      child: ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: userId != null
                              ? supabase.storage
                              .from('profile-pictures')
                              .getPublicUrl('$userId/profile.jpg') ??
                              ''
                              : '',
                          placeholder: (context, url) => CircularProgressIndicator(
                              color: Colors.white),
                          errorWidget: (context, url, error) => Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 60),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  FadeInDown(
                    duration: Duration(milliseconds: 800),
                    child: Text(
                      email,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: Colors.white.withOpacity(0.2)),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildMenuItem(
                    icon: FontAwesomeIcons.user,
                    title: 'Profile',
                    route: '/profile',
                    delay: 300,
                  ),
                  _buildMenuItem(
                    icon: FontAwesomeIcons.tachometerAlt,
                    title: 'Dashboard',
                    route: '/dashboard',
                    delay: 400,
                  ),
                  _buildMenuItem(
                    icon: FontAwesomeIcons.listAlt,
                    title: 'Job Feed',
                    route: '/jobFeed',
                    delay: 500,
                  ),
                  _buildMenuItem(
                    icon: FontAwesomeIcons.plusCircle,
                    title: 'Post Job',
                    route: '/jobPost',
                    delay: 600,
                  ),
                  _buildMenuItem(
                    icon: FontAwesomeIcons.search,
                    title: 'Search',
                    route: '/search',
                    delay: 700,
                  ),
                  _buildMenuItem(
                    icon: FontAwesomeIcons.creditCard,
                    title: 'Payments',
                    route: '/payment',
                    delay: 800,
                  ),
                  _buildMenuItem(
                    icon: FontAwesomeIcons.idCard,
                    title: 'NID Verification',
                    route: '/nidVerification',
                    delay: 900,
                  ),
                  _buildMenuItem(
                    icon: FontAwesomeIcons.star,
                    title: 'Rating & Feedback',
                    route: '/ratingFeedback',
                    delay: 1000,
                  ),
                  if (_isAdmin)
                    _buildMenuItem(
                      icon: FontAwesomeIcons.idCardAlt,
                      title: 'Admin NID Review',
                      route: '/adminNidReview',
                      delay: 1100,
                    ),
                ],
              ),
            ),
            ZoomIn(
              duration: Duration(milliseconds: 800),
              delay: Duration(milliseconds: 1200),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                leading: FaIcon(FontAwesomeIcons.signOutAlt, color: Colors.white),
                title: Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: widget.logout,
                hoverColor: Colors.white.withOpacity(0.1),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String route,
    required int delay,
  }) {
    return SlideInLeft(
      duration: Duration(milliseconds: 800),
      delay: Duration(milliseconds: delay),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.1),
              Colors.white.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          leading: FaIcon(icon, color: Colors.white, size: 24),
          title: Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          onTap: () => widget.navigateToScreen(route),
          hoverColor: Colors.white.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}