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
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade100, Colors.purple.shade100],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: Colors.teal))
            : Column(
          children: [
            Container(
              padding: EdgeInsets.only(top: 40, bottom: 20),
              child: Column(
                children: [
                  FadeInDown(
                    duration: Duration(milliseconds: 800),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.teal,
                      child: ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: userId != null
                              ? supabase.storage
                              .from('profile-pictures')
                              .getPublicUrl('$userId/profile.jpg') ??
                              ''
                              : '',
                          placeholder: (context, url) =>
                              CircularProgressIndicator(color: Colors.white),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.person, color: Colors.white, size: 50),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  FadeInDown(
                    duration: Duration(milliseconds: 800),
                    delay: Duration(milliseconds: 200),
                    child: Text(
                      email,
                      style: TextStyle(
                        color: Colors.blueGrey[700],
                        fontSize: 16,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: Colors.teal.withOpacity(0.3)),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  FadeInLeft(
                    duration: Duration(milliseconds: 800),
                    delay: Duration(milliseconds: 300),
                    child: ListTile(
                      leading: FaIcon(FontAwesomeIcons.user, color: Colors.teal),
                      title: Text(
                        'View Profile',
                        style: TextStyle(
                          color: Colors.blueGrey[700],
                          fontFamily: 'Poppins',
                        ),
                      ),
                      onTap: () => widget.navigateToScreen('/profile'),
                    ),
                  ),
                  FadeInLeft(
                    duration: Duration(milliseconds: 800),
                    delay: Duration(milliseconds: 400),
                    child: ListTile(
                      leading: FaIcon(FontAwesomeIcons.tachometerAlt, color: Colors.teal),
                      title: Text(
                        'Dashboard',
                        style: TextStyle(
                          color: Colors.blueGrey[700],
                          fontFamily: 'Poppins',
                        ),
                      ),
                      onTap: () => widget.navigateToScreen('/dashboard'),
                    ),
                  ),
                  FadeInLeft(
                    duration: Duration(milliseconds: 800),
                    delay: Duration(milliseconds: 500),
                    child: ListTile(
                      leading: FaIcon(FontAwesomeIcons.listAlt, color: Colors.teal),
                      title: Text(
                        'Job Feed',
                        style: TextStyle(
                          color: Colors.blueGrey[700],
                          fontFamily: 'Poppins',
                        ),
                      ),
                      onTap: () => widget.navigateToScreen('/jobFeed'),
                    ),
                  ),
                  FadeInLeft(
                    duration: Duration(milliseconds: 800),
                    delay: Duration(milliseconds: 600),
                    child: ListTile(
                      leading: FaIcon(FontAwesomeIcons.plusCircle, color: Colors.teal),
                      title: Text(
                        'Post Job',
                        style: TextStyle(
                          color: Colors.blueGrey[700],
                          fontFamily: 'Poppins',
                        ),
                      ),
                      onTap: () => widget.navigateToScreen('/jobPost'),
                    ),
                  ),
                  FadeInLeft(
                    duration: Duration(milliseconds: 800),
                    delay: Duration(milliseconds: 700),
                    child: ListTile(
                      leading: FaIcon(FontAwesomeIcons.search, color: Colors.teal),
                      title: Text(
                        'Search',
                        style: TextStyle(
                          color: Colors.blueGrey[700],
                          fontFamily: 'Poppins',
                        ),
                      ),
                      onTap: () => widget.navigateToScreen('/search'),
                    ),
                  ),
                  FadeInLeft(
                    duration: Duration(milliseconds: 800),
                    delay: Duration(milliseconds: 800),
                    child: ListTile(
                      leading: FaIcon(FontAwesomeIcons.creditCard, color: Colors.teal),
                      title: Text(
                        'Payments',
                        style: TextStyle(
                          color: Colors.blueGrey[700],
                          fontFamily: 'Poppins',
                        ),
                      ),
                      onTap: () => widget.navigateToScreen('/payments'),
                    ),
                  ),
                  FadeInLeft(
                    duration: Duration(milliseconds: 800),
                    delay: Duration(milliseconds: 900),
                    child: ListTile(
                      leading: FaIcon(FontAwesomeIcons.idCard, color: Colors.teal),
                      title: Text(
                        'NID Verification',
                        style: TextStyle(
                          color: Colors.blueGrey[700],
                          fontFamily: 'Poppins',
                        ),
                      ),
                      onTap: () => widget.navigateToScreen('/nidVerification'),
                    ),
                  ),
                  FadeInLeft(
                    duration: Duration(milliseconds: 800),
                    delay: Duration(milliseconds: 1000),
                    child: ListTile(
                      leading: FaIcon(FontAwesomeIcons.star, color: Colors.teal),
                      title: Text(
                        'Rating & Feedback',
                        style: TextStyle(
                          color: Colors.blueGrey[700],
                          fontFamily: 'Poppins',
                        ),
                      ),
                      onTap: () => widget.navigateToScreen('/ratingFeedback'),
                    ),
                  ),
                  if (_isAdmin)
                    FadeInLeft(
                      duration: Duration(milliseconds: 800),
                      delay: Duration(milliseconds: 1100),
                      child: ListTile(
                        leading: FaIcon(FontAwesomeIcons.idCardAlt, color: Colors.teal),
                        title: Text(
                          'NID Review',
                          style: TextStyle(
                            color: Colors.blueGrey[700],
                            fontFamily: 'Poppins',
                          ),
                        ),
                        onTap: () => widget.navigateToScreen('/adminNidReview'),
                      ),
                    ),
                ],
              ),
            ),
            FadeInUp(
              duration: Duration(milliseconds: 800),
              delay: Duration(milliseconds: 1200),
              child: ListTile(
                leading: FaIcon(FontAwesomeIcons.signOutAlt, color: Colors.teal),
                title: Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.blueGrey[700],
                    fontFamily: 'Poppins',
                  ),
                ),
                onTap: widget.logout,
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}