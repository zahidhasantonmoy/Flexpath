import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:animate_do/animate_do.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'global_menu.dart';
import 'sidebar_menu.dart';
import 'main.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController districtController = TextEditingController();
  final TextEditingController upazilaController = TextEditingController();
  final TextEditingController skillsController = TextEditingController();
  String? userType;
  bool _isLoading = false;
  List<dynamic> searchResults = [];

  Future<void> _searchUsers() async {
    setState(() => _isLoading = true);
    try {
      var query = supabase.from('users').select();

      if (nameController.text.isNotEmpty) {
        query = query.ilike('full_name', '%${nameController.text.trim()}%');
      }
      if (districtController.text.isNotEmpty) {
        query = query.ilike('district', '%${districtController.text.trim()}%');
      }
      if (upazilaController.text.isNotEmpty) {
        query = query.ilike('upazila', '%${upazilaController.text.trim()}%');
      }
      if (skillsController.text.isNotEmpty) {
        final skills = skillsController.text.trim().split(',').map((e) => e.trim()).toList();
        query = query.contains('skills', skills);
      }
      if (userType != null) {
        query = query.eq('user_type', userType!);
      }

      final response = await query;
      if (mounted) {
        setState(() {
          searchResults = response;
        });
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Search failed: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _navigateToScreen(String route) {
    FlexPathApp.navigateToScreen(context, route);
  }

  Future<void> _logout() async {
    await FlexPathApp.logout(context);
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
            colors: [Colors.teal.shade100, Colors.purple.shade100],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20),
                      FadeInDown(
                        duration: Duration(milliseconds: 800),
                        child: Text(
                          'Search Users',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                            fontFamily: 'Poppins',
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      FadeInUp(
                        duration: Duration(milliseconds: 800),
                        delay: Duration(milliseconds: 200),
                        child: TextField(
                          controller: nameController,
                          style: TextStyle(color: Colors.blueGrey[800]),
                          decoration: InputDecoration(
                            labelText: 'Name',
                            labelStyle: TextStyle(color: Colors.teal),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.9),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(color: Colors.teal, width: 2),
                            ),
                            prefixIcon: FaIcon(FontAwesomeIcons.user, color: Colors.teal),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      FadeInUp(
                        duration: Duration(milliseconds: 800),
                        delay: Duration(milliseconds: 300),
                        child: TextField(
                          controller: districtController,
                          style: TextStyle(color: Colors.blueGrey[800]),
                          decoration: InputDecoration(
                            labelText: 'District',
                            labelStyle: TextStyle(color: Colors.teal),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.9),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(color: Colors.teal, width: 2),
                            ),
                            prefixIcon: FaIcon(FontAwesomeIcons.city, color: Colors.teal),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      FadeInUp(
                        duration: Duration(milliseconds: 800),
                        delay: Duration(milliseconds: 400),
                        child: TextField(
                          controller: upazilaController,
                          style: TextStyle(color: Colors.blueGrey[800]),
                          decoration: InputDecoration(
                            labelText: 'Upazila',
                            labelStyle: TextStyle(color: Colors.teal),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.9),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(color: Colors.teal, width: 2),
                            ),
                            prefixIcon: FaIcon(FontAwesomeIcons.locationPin, color: Colors.teal),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      FadeInUp(
                        duration: Duration(milliseconds: 800),
                        delay: Duration(milliseconds: 500),
                        child: TextField(
                          controller: skillsController,
                          style: TextStyle(color: Colors.blueGrey[800]),
                          decoration: InputDecoration(
                            labelText: 'Skills (comma-separated)',
                            labelStyle: TextStyle(color: Colors.teal),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.9),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(color: Colors.teal, width: 2),
                            ),
                            prefixIcon: FaIcon(FontAwesomeIcons.tools, color: Colors.teal),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      FadeInUp(
                        duration: Duration(milliseconds: 800),
                        delay: Duration(milliseconds: 600),
                        child: DropdownButtonFormField<String>(
                          value: userType,
                          hint: Text('Select User Type', style: TextStyle(color: Colors.teal)),
                          items: ['Job Seeker', 'Employer']
                              .map((type) => DropdownMenuItem(value: type, child: Text(type, style: TextStyle(color: Colors.blueGrey[800]))))
                              .toList(),
                          onChanged: (value) {
                            setState(() => userType = value);
                          },
                          decoration: InputDecoration(
                            labelText: 'User Type',
                            labelStyle: TextStyle(color: Colors.teal),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.9),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(color: Colors.teal, width: 2),
                            ),
                            prefixIcon: FaIcon(FontAwesomeIcons.userTie, color: Colors.teal),
                          ),
                          dropdownColor: Colors.white,
                        ),
                      ),
                      SizedBox(height: 20),
                      FadeInUp(
                        duration: Duration(milliseconds: 800),
                        delay: Duration(milliseconds: 700),
                        child: ZoomIn(
                          duration: Duration(milliseconds: 300),
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _searchUsers,
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(Colors.teal),
                              padding: WidgetStateProperty.all(EdgeInsets.symmetric(vertical: 16, horizontal: 80)),
                              shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                              elevation: WidgetStateProperty.all(5),
                            ),
                            child: _isLoading
                                ? CircularProgressIndicator(color: Colors.white)
                                : Text(
                              'Search',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      if (searchResults.isNotEmpty)
                        FadeInUp(
                          duration: Duration(milliseconds: 800),
                          delay: Duration(milliseconds: 800),
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: searchResults.length,
                            itemBuilder: (context, index) {
                              final user = searchResults[index];
                              return FadeIn(
                                duration: Duration(milliseconds: 800),
                                delay: Duration(milliseconds: 100 * index),
                                child: Card(
                                  color: Colors.white.withOpacity(0.9),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                  margin: EdgeInsets.symmetric(vertical: 8),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundImage: user['profile_image'] != null
                                          ? NetworkImage(user['profile_image'])
                                          : null,
                                      backgroundColor: Colors.teal,
                                      child: user['profile_image'] == null
                                          ? FaIcon(FontAwesomeIcons.user, color: Colors.white)
                                          : null,
                                    ),
                                    title: Text(
                                      user['full_name'] ?? 'Unknown',
                                      style: TextStyle(
                                        color: Colors.blueGrey[800],
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                    subtitle: Text(
                                      '${user['user_type']} • ${user['district'] ?? ''}, ${user['upazila'] ?? ''}',
                                      style: TextStyle(color: Colors.blueGrey[600], fontFamily: 'Poppins'),
                                    ),
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        '/viewProfile',
                                        arguments: user['id'],
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      if (searchResults.isEmpty && !_isLoading)
                        Center(
                          child: Text(
                            'No results found',
                            style: TextStyle(color: Colors.blueGrey[600], fontFamily: 'Poppins'),
                          ),
                        ),
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