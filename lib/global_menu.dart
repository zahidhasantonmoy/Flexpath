import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class GlobalMenu extends StatelessWidget {
  final void Function(String) navigateToScreen;
  final void Function() logout;

  const GlobalMenu({
    super.key,
    required this.navigateToScreen,
    required this.logout,
  });

  Future<String?> _getUserType() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) return null;

    final userData = await supabase
        .from('users')
        .select('user_type')
        .eq('id', user.id)
        .maybeSingle();
    return userData?['user_type'] as String?;
  }

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) return const SizedBox.shrink();

    return Positioned(
      bottom: 16,
      right: 16,
      child: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => FutureBuilder<String?>(
              future: _getUserType(),
              builder: (context, snapshot) {
                final userType = snapshot.data;
                return Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F3460), Color(0xFF16213E)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.teal, width: 1),
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            'FlexPath Menu',
                            style: TextStyle(
                              color: Colors.teal,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.1, end: 0),
                      ListTile(
                        leading: const FaIcon(
                          FontAwesomeIcons.user,
                          color: Colors.teal,
                          size: 24,
                        ).animate().fadeIn(delay: const Duration(milliseconds: 100)).slideX(),
                        title: const Text(
                          'Profile',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          navigateToScreen('/profile');
                        },
                      ).animate().fadeIn(delay: const Duration(milliseconds: 200)).slideY(),
                      ListTile(
                        leading: const FaIcon(
                          FontAwesomeIcons.search,
                          color: Colors.teal,
                          size: 24,
                        ).animate().fadeIn(delay: const Duration(milliseconds: 300)).slideX(),
                        title: const Text(
                          'Search',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          navigateToScreen('/search');
                        },
                      ).animate().fadeIn(delay: const Duration(milliseconds: 400)).slideY(),
                      ListTile(
                        leading: const FaIcon(
                          FontAwesomeIcons.message,
                          color: Colors.teal,
                          size: 24,
                        ).animate().fadeIn(delay: const Duration(milliseconds: 500)).slideX(),
                        title: const Text(
                          'Chat',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          navigateToScreen('/chat');
                        },
                      ).animate().fadeIn(delay: const Duration(milliseconds: 600)).slideY(),
                      ListTile(
                        leading: const FaIcon(
                          FontAwesomeIcons.chartLine,
                          color: Colors.teal,
                          size: 24,
                        ).animate().fadeIn(delay: const Duration(milliseconds: 700)).slideX(),
                        title: Text(
                          userType == 'Employer' ? 'Employer Dashboard' : 'Worker Dashboard',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          navigateToScreen('/dashboard');
                        },
                      ).animate().fadeIn(delay: const Duration(milliseconds: 800)).slideY(),
                      ListTile(
                        leading: const FaIcon(
                          FontAwesomeIcons.listAlt,
                          color: Colors.teal,
                          size: 24,
                        ).animate().fadeIn(delay: const Duration(milliseconds: 900)).slideX(),
                        title: const Text(
                          'Job Feed',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          navigateToScreen('/jobFeed');
                        },
                      ).animate().fadeIn(delay: const Duration(milliseconds: 1000)).slideY(),
                      ListTile(
                        leading: const FaIcon(
                          FontAwesomeIcons.plusCircle,
                          color: Colors.teal,
                          size: 24,
                        ).animate().fadeIn(delay: const Duration(milliseconds: 1100)).slideX(),
                        title: const Text(
                          'Post Job',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          navigateToScreen('/jobPost');
                        },
                      ).animate().fadeIn(delay: const Duration(milliseconds: 1200)).slideY(),
                      ListTile(
                        leading: const FaIcon(
                          FontAwesomeIcons.star,
                          color: Colors.teal,
                          size: 24,
                        ).animate().fadeIn(delay: const Duration(milliseconds: 1300)).slideX(),
                        title: const Text(
                          'Rate & Feedback',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          navigateToScreen('/ratingFeedback');
                        },
                      ).animate().fadeIn(delay: const Duration(milliseconds: 1400)).slideY(),
                      ListTile(
                        leading: const FaIcon(
                          FontAwesomeIcons.signOutAlt,
                          color: Colors.redAccent,
                          size: 24,
                        ).animate().fadeIn(delay: const Duration(milliseconds: 1500)).slideX(),
                        title: const Text(
                          'Logout',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          logout();
                        },
                      ).animate().fadeIn(delay: const Duration(milliseconds: 1600)).slideY(),
                      const SizedBox(height: 16),
                    ],
                  ),
                );
              },
            ),
          );
        },
        backgroundColor: Colors.teal,
        child: const FaIcon(
          FontAwesomeIcons.bars,
          color: Colors.white,
          size: 24,
        ),
        elevation: 8,
        shape: const CircleBorder(),
      ).animate().scale(duration: 500.ms),
    );
  }
}