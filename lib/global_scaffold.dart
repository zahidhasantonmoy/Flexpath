import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'global_menu.dart';
import 'sidebar_menu.dart';
import 'main.dart';

class GlobalScaffold extends StatelessWidget {
  final Widget child;
  final String route;

  const GlobalScaffold({
    super.key,
    required this.child,
    required this.route,
  });

  void _navigateToScreen(BuildContext context, String route) {
    FlexPathApp.navigateToScreen(context, route);
  }

  Future<void> _logout(BuildContext context) async {
    await FlexPathApp.logout(context);
  }

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = Supabase.instance.client.auth.currentUser != null;

    return Scaffold(
      drawer: isAuthenticated
          ? SidebarMenu(
        navigateToScreen: (route) => _navigateToScreen(context, route),
        logout: () => _logout(context),
      )
          : null,
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
              child,
              if (isAuthenticated)
                GlobalMenu(
                  navigateToScreen: (route) => _navigateToScreen(context, route),
                  logout: () => _logout(context),
                ),
              if (isAuthenticated)
                Positioned(
                  top: 10,
                  left: 10,
                  child: SlideInLeft(
                    duration: Duration(milliseconds: 800),
                    child: IconButton(
                      icon: FaIcon(FontAwesomeIcons.bars, color: Colors.teal, size: 30),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                      tooltip: 'Open Menu',
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}