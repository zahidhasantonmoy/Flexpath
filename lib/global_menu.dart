import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GlobalMenu extends StatelessWidget {
  final void Function(String) navigateToScreen;
  final void Function() logout;

  const GlobalMenu({
    super.key,
    required this.navigateToScreen,
    required this.logout,
  });

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) return SizedBox.shrink();

    return Positioned(
      bottom: 16,
      right: 16,
      child: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) => Container(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: Icon(Icons.person, color: Colors.blueAccent),
                    title: Text('Profile'),
                    onTap: () {
                      Navigator.pop(context);
                      navigateToScreen('/profile');
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.chat, color: Colors.green),
                    title: Text('Chat'),
                    onTap: () {
                      Navigator.pop(context);
                      navigateToScreen('/chat');
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.dashboard, color: Colors.teal),
                    title: Text('Employer Dashboard'),
                    onTap: () {
                      Navigator.pop(context);
                      navigateToScreen('/employerDashboard');
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.logout, color: Colors.red),
                    title: Text('Logout'),
                    onTap: () {
                      Navigator.pop(context);
                      logout();
                    },
                  ),
                ],
              ),
            ),
          );
        },
        backgroundColor: Colors.blueAccent,
        child: Icon(Icons.menu, color: Colors.white),
        elevation: 5,
        shape: CircleBorder(),
      ),
    );
  }
}