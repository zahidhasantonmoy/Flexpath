import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'global_menu.dart';
import 'sidebar_menu.dart';
import 'main.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  Map<String, dynamic>? userData;
  List<Map<String, dynamic>> savedJobs = [];
  List<Map<String, dynamic>> appliedJobs = [];
  bool _isLoading = true;
  bool _isEditing = false;
  bool _isBengali = false;
  bool _isDarkMode = true;
  bool _notificationsEnabled = true;
  TextEditingController _fullNameController = TextEditingController();
  TextEditingController _mobileController = TextEditingController();
  TextEditingController _districtController = TextEditingController();
  TextEditingController _skillsController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchSavedJobs();
    _fetchAppliedJobs();
  }

  Future<void> _fetchUserData() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please sign in to view profile')));
        Navigator.pushNamedAndRemoveUntil(context, '/homepage', (route) => false);
        return;
      }

      final response = await supabase
          .from('users')
          .select()
          .eq('id', userId)
          .single();

      setState(() {
        userData = response;
        _fullNameController.text = userData?['full_name'] ?? '';
        _mobileController.text = userData?['mobile_number'] ?? '';
        _districtController.text = userData?['district_upazila'] ?? '';
        _skillsController.text = userData?['skills']?.join(', ') ?? '';
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching user data: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load profile: $e')));
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchSavedJobs() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      final response = await supabase
          .from('saved_jobs')
          .select('jobs(*)')
          .eq('user_id', userId);

      setState(() {
        savedJobs = response.map((item) => item['jobs'] as Map<String, dynamic>).toList();
      });
    } catch (e) {
      print('Error fetching saved jobs: $e');
    }
  }

  Future<void> _fetchAppliedJobs() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      final response = await supabase
          .from('job_applications')
          .select('jobs(*), status')
          .eq('user_id', userId);

      setState(() {
        appliedJobs = response.map((item) => {
          'title': item['jobs']['title'],
          'pay': item['jobs']['pay'],
          'status': item['status'],
        } as Map<String, dynamic>).toList();
      });
    } catch (e) {
      print('Error fetching applied jobs: $e');
    }
  }

  Future<void> _updateProfile() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      await supabase
          .from('users')
          .update({
        'full_name': _fullNameController.text,
        'mobile_number': _mobileController.text,
        'district_upazila': _districtController.text,
        'skills': _skillsController.text.split(',').map((s) => s.trim()).toList(),
      })
          .eq('id', userId);

      if (_passwordController.text.isNotEmpty) {
        await supabase.auth.updateUser(UserAttributes(password: _passwordController.text));
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile updated successfully!')));
      setState(() => _isEditing = false);
      _fetchUserData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update profile: $e')));
    }
  }

  Future<void> _updateProfilePhoto() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      try {
        final userId = supabase.auth.currentUser?.id;
        if (userId == null) return;

        final bytes = await pickedFile.readAsBytes();
        await supabase.storage
            .from('profile-pictures')
            .uploadBinary(
          '${userId}/profile.jpg',
          bytes,
        );

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile photo updated!')));
        _fetchUserData();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update photo: $e')));
      }
    }
  }

  Future<void> _logout() async {
    await FlexPathApp.logout(context);
  }

  void _navigateToScreen(String route) {
    FlexPathApp.navigateToScreen(context, route);
  }

  void _toggleTheme() {
    setState(() => _isDarkMode = !_isDarkMode);
  }

  void _toggleNotifications() {
    setState(() => _notificationsEnabled = !_notificationsEnabled);
  }

  String _translateToBengali(String text) {
    final translations = {
      'Full Name': 'পুরো নাম',
      'Mobile Number': 'মোবাইল নম্বর',
      'District/Upazila': 'জেলা/উপজেলা',
      'Skills': 'দক্ষতা',
      'Password': 'পাসওয়ার্ড',
      'Edit Profile': 'প্রোফাইল সম্পাদনা করুন',
      'Save': 'সংরক্ষণ করুন',
      'Saved Jobs': 'সংরক্ষিত কাজ',
      'No saved jobs': 'কোনো সংরক্ষিত কাজ নেই',
      'Applied Jobs': 'আবেদন করা কাজ',
      'Notifications': 'নোটিফিকেশন',
      'Enable Notifications': 'নোটিফিকেশন সক্ষম করুন',
      'Update Photo': 'ছবি আপডেট করুন',
    };
    return translations[text] ?? text;
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
            colors: _isDarkMode
                ? [const Color(0xFF0F3460), const Color(0xFF16213E)]
                : [Colors.teal.shade100, Colors.purple.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 0.8],
          ),
        ),
        child: SafeArea(
          child: Stack(
            fit: StackFit.expand,
            children: [
              _isLoading
                  ? Center(child: CircularProgressIndicator(color: Colors.teal))
                  : SingleChildScrollView(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    FadeInUp(
                      duration: Duration(milliseconds: 800),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [Colors.teal.withOpacity(0.3), Colors.transparent],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.teal.withOpacity(0.5),
                                  blurRadius: 15,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: _isEditing ? _updateProfilePhoto : null,
                            child: CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.teal,
                              child: ClipOval(
                                child: CachedNetworkImage(
                                  imageUrl: userData != null
                                      ? supabase.storage
                                      .from('profile-pictures')
                                      .getPublicUrl('${userData!['id']}/profile.jpg') ??
                                      ''
                                      : '',
                                  placeholder: (context, url) =>
                                      CircularProgressIndicator(color: Colors.white),
                                  errorWidget: (context, url, error) =>
                                      Icon(Icons.person, color: Colors.white, size: 60),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          if (_isEditing)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: ZoomIn(
                                duration: Duration(milliseconds: 300),
                                child: IconButton(
                                  icon: Icon(Icons.camera_alt, color: Colors.white),
                                  onPressed: _updateProfilePhoto,
                                  tooltip: _isBengali ? _translateToBengali('Update Photo') : 'Update Photo',
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    FadeInUp(
                      duration: Duration(milliseconds: 800),
                      delay: Duration(milliseconds: 200),
                      child: Text(
                        _isBengali ? _translateToBengali('Full Name') : 'Full Name',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _isDarkMode ? Colors.white : Colors.blueGrey[700],
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                    FadeInUp(
                      duration: Duration(milliseconds: 800),
                      delay: Duration(milliseconds: 300),
                      child: TextField(
                        controller: _fullNameController,
                        enabled: _isEditing,
                        style: TextStyle(color: _isDarkMode ? Colors.white : Colors.blueGrey[800]),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: _isDarkMode ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.9),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: Colors.teal, width: 2),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    FadeInUp(
                      duration: Duration(milliseconds: 800),
                      delay: Duration(milliseconds: 400),
                      child: Text(
                        _isBengali ? _translateToBengali('Mobile Number') : 'Mobile Number',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _isDarkMode ? Colors.white : Colors.blueGrey[700],
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                    FadeInUp(
                      duration: Duration(milliseconds: 800),
                      delay: Duration(milliseconds: 500),
                      child: TextField(
                        controller: _mobileController,
                        enabled: _isEditing,
                        style: TextStyle(color: _isDarkMode ? Colors.white : Colors.blueGrey[800]),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: _isDarkMode ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.9),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: Colors.teal, width: 2),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    FadeInUp(
                      duration: Duration(milliseconds: 800),
                      delay: Duration(milliseconds: 600),
                      child: Text(
                        _isBengali ? _translateToBengali('District/Upazila') : 'District/Upazila',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _isDarkMode ? Colors.white : Colors.blueGrey[700],
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                    FadeInUp(
                      duration: Duration(milliseconds: 800),
                      delay: Duration(milliseconds: 700),
                      child: TextField(
                        controller: _districtController,
                        enabled: _isEditing,
                        style: TextStyle(color: _isDarkMode ? Colors.white : Colors.blueGrey[800]),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: _isDarkMode ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.9),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: Colors.teal, width: 2),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    FadeInUp(
                      duration: Duration(milliseconds: 800),
                      delay: Duration(milliseconds: 800),
                      child: Text(
                        _isBengali ? _translateToBengali('Skills') : 'Skills',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _isDarkMode ? Colors.white : Colors.blueGrey[700],
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                    FadeInUp(
                      duration: Duration(milliseconds: 800),
                      delay: Duration(milliseconds: 900),
                      child: TextField(
                        controller: _skillsController,
                        enabled: _isEditing,
                        style: TextStyle(color: _isDarkMode ? Colors.white : Colors.blueGrey[800]),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: _isDarkMode ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.9),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: Colors.teal, width: 2),
                          ),
                        ),
                      ),
                    ),
                    if (_isEditing) ...[
                      SizedBox(height: 16),
                      FadeInUp(
                        duration: Duration(milliseconds: 800),
                        delay: Duration(milliseconds: 1000),
                        child: Text(
                          _isBengali ? _translateToBengali('Password') : 'Password',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _isDarkMode ? Colors.white : Colors.blueGrey[700],
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                      FadeInUp(
                        duration: Duration(milliseconds: 800),
                        delay: Duration(milliseconds: 1100),
                        child: TextField(
                          controller: _passwordController,
                          obscureText: true,
                          style: TextStyle(color: _isDarkMode ? Colors.white : Colors.blueGrey[800]),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: _isDarkMode ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.9),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(color: Colors.teal, width: 2),
                            ),
                          ),
                        ),
                      ),
                    ],
                    SizedBox(height: 20),
                    FadeInUp(
                      duration: Duration(milliseconds: 800),
                      delay: Duration(milliseconds: 1200),
                      child: ZoomIn(
                        duration: Duration(milliseconds: 300),
                        child: ElevatedButton(
                          onPressed: _isEditing ? _updateProfile : () => setState(() => _isEditing = true),
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(Colors.teal),
                            padding: WidgetStateProperty.all(
                                EdgeInsets.symmetric(horizontal: 40, vertical: 16)),
                            shape: WidgetStateProperty.all(
                                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                            elevation: WidgetStateProperty.all(5),
                            shadowColor: WidgetStateProperty.all(Colors.teal.withAlpha(128)),
                          ),
                          child: Text(
                            _isEditing
                                ? (_isBengali ? _translateToBengali('Save') : 'Save')
                                : (_isBengali ? _translateToBengali('Edit Profile') : 'Edit Profile'),
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    FadeInUp(
                      duration: Duration(milliseconds: 800),
                      delay: Duration(milliseconds: 1300),
                      child: Text(
                        _isBengali ? _translateToBengali('Saved Jobs') : 'Saved Jobs',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: _isDarkMode ? Colors.white : Colors.blueGrey[700],
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    savedJobs.isEmpty
                        ? FadeInUp(
                      duration: Duration(milliseconds: 800),
                      delay: Duration(milliseconds: 1400),
                      child: Text(
                        _isBengali ? _translateToBengali('No saved jobs') : 'No saved jobs',
                        style: TextStyle(
                          color: _isDarkMode ? Colors.white70 : Colors.blueGrey[600],
                          fontFamily: 'Poppins',
                        ),
                      ),
                    )
                        : FadeInUp(
                      duration: Duration(milliseconds: 800),
                      delay: Duration(milliseconds: 1400),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: savedJobs.length,
                        itemBuilder: (context, index) {
                          final job = savedJobs[index];
                          return Card(
                            color: _isDarkMode ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.9),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            margin: EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              title: Text(
                                job['title'] ?? 'No Title',
                                style: TextStyle(
                                  color: _isDarkMode ? Colors.white : Colors.blueGrey[800],
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              subtitle: Text(
                                'Pay: ${job['pay']?.toStringAsFixed(2) ?? 'N/A'}',
                                style: TextStyle(
                                  color: _isDarkMode ? Colors.white70 : Colors.blueGrey[600],
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 20),
                    FadeInUp(
                      duration: Duration(milliseconds: 800),
                      delay: Duration(milliseconds: 1500),
                      child: Text(
                        _isBengali ? _translateToBengali('Applied Jobs') : 'Applied Jobs',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: _isDarkMode ? Colors.white : Colors.blueGrey[700],
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    appliedJobs.isEmpty
                        ? FadeInUp(
                      duration: Duration(milliseconds: 800),
                      delay: Duration(milliseconds: 1600),
                      child: Text(
                        _isBengali ? _translateToBengali('No applied jobs') : 'No applied jobs',
                        style: TextStyle(
                          color: _isDarkMode ? Colors.white70 : Colors.blueGrey[600],
                          fontFamily: 'Poppins',
                        ),
                      ),
                    )
                        : FadeInUp(
                      duration: Duration(milliseconds: 800),
                      delay: Duration(milliseconds: 1600),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: appliedJobs.length,
                        itemBuilder: (context, index) {
                          final job = appliedJobs[index];
                          return Card(
                            color: _isDarkMode ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.9),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            margin: EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              title: Text(
                                job['title'] ?? 'No Title',
                                style: TextStyle(
                                  color: _isDarkMode ? Colors.white : Colors.blueGrey[800],
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              subtitle: Text(
                                'Pay: ${job['pay']?.toStringAsFixed(2) ?? 'N/A'}\nStatus: ${job['status']}',
                                style: TextStyle(
                                  color: _isDarkMode ? Colors.white70 : Colors.blueGrey[600],
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 20),
                    FadeInUp(
                      duration: Duration(milliseconds: 800),
                      delay: Duration(milliseconds: 1700),
                      child: SwitchListTile(
                        title: Text(
                          _isBengali ? 'বাংলা' : 'Bengali',
                          style: TextStyle(
                            color: _isDarkMode ? Colors.white : Colors.blueGrey[700],
                            fontFamily: 'Poppins',
                          ),
                        ),
                        value: _isBengali,
                        onChanged: (value) => setState(() => _isBengali = value),
                        activeColor: Colors.teal,
                      ),
                    ),
                    FadeInUp(
                      duration: Duration(milliseconds: 800),
                      delay: Duration(milliseconds: 1800),
                      child: SwitchListTile(
                        title: Text(
                          'Dark Mode',
                          style: TextStyle(
                            color: _isDarkMode ? Colors.white : Colors.blueGrey[700],
                            fontFamily: 'Poppins',
                          ),
                        ),
                        value: _isDarkMode,
                        onChanged: (value) => _toggleTheme(),
                        activeColor: Colors.teal,
                      ),
                    ),
                    FadeInUp(
                      duration: Duration(milliseconds: 800),
                      delay: Duration(milliseconds: 1900),
                      child: SwitchListTile(
                        title: Text(
                          _isBengali
                              ? _translateToBengali('Enable Notifications')
                              : 'Enable Notifications',
                          style: TextStyle(
                            color: _isDarkMode ? Colors.white : Colors.blueGrey[700],
                            fontFamily: 'Poppins',
                          ),
                        ),
                        value: _notificationsEnabled,
                        onChanged: (value) => _toggleNotifications(),
                        activeColor: Colors.teal,
                      ),
                    ),
                  ],
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