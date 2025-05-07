import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'global_menu.dart';

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
           // Specify content type directly
        );

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile photo updated!')));
        _fetchUserData(); // Refresh to update UI, though image might need manual refresh
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update photo: $e')));
      }
    }
  }

  Future<void> _logout() async {
    await supabase.auth.signOut();
    Navigator.pushNamedAndRemoveUntil(context, '/homepage', (route) => false);
  }

  void _navigateToScreen(String route) {
    Navigator.pushNamed(context, route);
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _isDarkMode
                ? [const Color(0xFF0F3460), const Color(0xFF16213E)]
                : [Colors.blue.shade100, Colors.white],
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
                    // Profile Header with Photo
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
                    // Profile Details Card
                    SlideInUp(
                      duration: Duration(milliseconds: 800),
                      child: Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: BorderSide(color: Colors.teal.withOpacity(0.5), width: 1),
                        ),
                        color: _isDarkMode ? Colors.black26 : Colors.white.withOpacity(0.9),
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _isBengali ? _translateToBengali('Edit Profile') : 'Edit Profile',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              SizedBox(height: 15),
                              _buildEditableField(
                                label: _isBengali ? _translateToBengali('Full Name') : 'Full Name',
                                icon: Icons.person,
                                controller: _fullNameController,
                                enabled: _isEditing,
                              ),
                              _buildEditableField(
                                label: _isBengali ? _translateToBengali('Mobile Number') : 'Mobile Number',
                                icon: Icons.phone,
                                controller: _mobileController,
                                enabled: _isEditing,
                              ),
                              _buildEditableField(
                                label: _isBengali ? _translateToBengali('District/Upazila') : 'District/Upazila',
                                icon: Icons.location_on,
                                controller: _districtController,
                                enabled: _isEditing,
                              ),
                              _buildEditableField(
                                label: _isBengali ? _translateToBengali('Skills') : 'Skills',
                                icon: Icons.work,
                                controller: _skillsController,
                                enabled: _isEditing,
                              ),
                              _buildEditableField(
                                label: _isBengali ? _translateToBengali('Password') : 'Password',
                                icon: Icons.lock,
                                controller: _passwordController,
                                enabled: _isEditing,
                                obscureText: true,
                              ),
                              SizedBox(height: 15),
                              ZoomIn(
                                duration: Duration(milliseconds: 300),
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (_isEditing) {
                                      _updateProfile();
                                    } else {
                                      setState(() => _isEditing = true);
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.teal,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  child: Text(
                                    _isEditing
                                        ? (_isBengali ? _translateToBengali('Save') : 'Save')
                                        : (_isBengali ? _translateToBengali('Edit Profile') : 'Edit Profile'),
                                    style: TextStyle(color: Colors.white, fontFamily: 'Poppins'),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    // Applied Jobs Section
                    FadeInUp(
                      duration: Duration(milliseconds: 800),
                      delay: Duration(milliseconds: 200),
                      child: Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: BorderSide(color: Colors.green.withOpacity(0.5), width: 1),
                        ),
                        color: _isDarkMode ? Colors.black26 : Colors.white.withOpacity(0.9),
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _isBengali ? _translateToBengali('Applied Jobs') : 'Applied Jobs',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                  Icon(Icons.work, color: Colors.green),
                                ],
                              ),
                              SizedBox(height: 8),
                              appliedJobs.isEmpty
                                  ? Text(
                                _isBengali ? _translateToBengali('No applied jobs') : 'No applied jobs',
                                style: TextStyle(color: Colors.white70, fontFamily: 'Poppins'),
                              )
                                  : ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: appliedJobs.length,
                                itemBuilder: (context, index) {
                                  final job = appliedJobs[index];
                                  return ListTile(
                                    leading: Icon(Icons.check_circle, color: Colors.green),
                                    title: Text(
                                      job['title'] ?? 'No Title',
                                      style: TextStyle(color: Colors.white, fontFamily: 'Poppins'),
                                    ),
                                    subtitle: Text(
                                      'Pay: ${job['pay'] ?? 'N/A'} BDT | Status: ${job['status'] ?? 'N/A'}',
                                      style: TextStyle(color: Colors.white70, fontFamily: 'Poppins'),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    // Saved Jobs Section
                    FadeInUp(
                      duration: Duration(milliseconds: 800),
                      delay: Duration(milliseconds: 400),
                      child: Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: BorderSide(color: Colors.teal.withOpacity(0.5), width: 1),
                        ),
                        color: _isDarkMode ? Colors.black26 : Colors.white.withOpacity(0.9),
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _isBengali ? _translateToBengali('Saved Jobs') : 'Saved Jobs',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.teal,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                  Icon(Icons.bookmark, color: Colors.teal),
                                ],
                              ),
                              SizedBox(height: 8),
                              savedJobs.isEmpty
                                  ? Text(
                                _isBengali ? _translateToBengali('No saved jobs') : 'No saved jobs',
                                style: TextStyle(color: Colors.white70, fontFamily: 'Poppins'),
                              )
                                  : ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: savedJobs.length,
                                itemBuilder: (context, index) {
                                  final job = savedJobs[index];
                                  return ListTile(
                                    leading: Icon(Icons.bookmark_border, color: Colors.teal),
                                    title: Text(
                                      job['title'] ?? 'No Title',
                                      style: TextStyle(color: Colors.white, fontFamily: 'Poppins'),
                                    ),
                                    subtitle: Text(
                                      'Pay: ${job['pay'] ?? 'N/A'} BDT',
                                      style: TextStyle(color: Colors.white70, fontFamily: 'Poppins'),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    // Notification Settings
                    FadeInUp(
                      duration: Duration(milliseconds: 800),
                      delay: Duration(milliseconds: 600),
                      child: Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: BorderSide(color: Colors.blue.withOpacity(0.5), width: 1),
                        ),
                        color: _isDarkMode ? Colors.black26 : Colors.white.withOpacity(0.9),
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.notifications, color: Colors.blue),
                                  SizedBox(width: 8),
                                  Text(
                                    _isBengali ? _translateToBengali('Notifications') : 'Notifications',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.blue,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ],
                              ),
                              Switch(
                                value: _notificationsEnabled,
                                onChanged: (value) => _toggleNotifications(),
                                activeColor: Colors.blue,
                                inactiveThumbColor: Colors.grey,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
              // Global Menu
              GlobalMenu(
                navigateToScreen: _navigateToScreen,
                logout: _logout,
              ),
              // Theme and Language Toggle
              Positioned(
                top: 16,
                right: 16,
                child: Row(
                  children: [
                    ZoomIn(
                      duration: Duration(milliseconds: 300),
                      child: IconButton(
                        icon: Icon(_isBengali ? Icons.language : Icons.translate,
                            color: _isDarkMode ? Colors.white : Colors.blueAccent),
                        onPressed: () => setState(() => _isBengali = !_isBengali),
                        tooltip: 'Toggle Language',
                      ),
                    ),
                    ZoomIn(
                      duration: Duration(milliseconds: 300),
                      delay: Duration(milliseconds: 100),
                      child: IconButton(
                        icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode,
                            color: _isDarkMode ? Colors.white : Colors.blueAccent),
                        onPressed: _toggleTheme,
                        tooltip: 'Toggle Theme',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditableField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    bool enabled = false,
    bool obscureText = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.teal, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              enabled: enabled,
              obscureText: obscureText,
              decoration: InputDecoration(
                labelText: label,
                labelStyle: TextStyle(color: Colors.white70, fontFamily: 'Poppins'),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.teal),
                ),
              ),
              style: TextStyle(color: enabled ? Colors.white : Colors.green, fontFamily: 'Poppins'),
            ),
          ),
        ],
      ),
    );
  }
}