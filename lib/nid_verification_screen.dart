import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:animate_do/animate_do.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'global_menu.dart';
import 'sidebar_menu.dart';

class NidVerificationScreen extends StatefulWidget {
  const NidVerificationScreen({super.key});

  @override
  State<NidVerificationScreen> createState() => _NidVerificationScreenState();
}

class _NidVerificationScreenState extends State<NidVerificationScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();
  final _nidController = TextEditingController();
  File? _frontImage;
  File? _backImage;
  bool _isLoading = false;
  String? _userId;
  String? _userFullName;
  String? _verificationStatus;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _subscribeToVerificationUpdates();
  }

  Future<void> _fetchUserData() async {
    setState(() => _isLoading = true);
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');
      _userId = user.id;

      final userData = await supabase
          .from('users')
          .select('full_name, verification_status')
          .eq('id', _userId!)
          .maybeSingle();
      _userFullName = userData?['full_name'] ?? 'User';
      _verificationStatus = userData?['verification_status'] as String?;

      final verificationData = await supabase
          .from('nid_verifications')
          .select('verification_status')
          .eq('user_id', _userId!)
          .maybeSingle();
      if (verificationData != null) {
        _verificationStatus = verificationData['verification_status'] as String?;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching data: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _subscribeToVerificationUpdates() async {
    supabase
        .from('nid_verifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', _userId!)
        .listen((List<Map<String, dynamic>> data) {
      if (data.isNotEmpty) {
        final newStatus = data.first['verification_status'];
        setState(() {
          _verificationStatus = newStatus;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification status updated: $newStatus')),
        );
      }
    });

    supabase
        .from('users')
        .stream(primaryKey: ['id'])
        .eq('id', _userId!)
        .listen((List<Map<String, dynamic>> data) {
      if (data.isNotEmpty) {
        final newStatus = data.first['verification_status'];
        setState(() {
          _verificationStatus = newStatus;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User verification status updated: $newStatus')),
        );
      }
    });
  }

  Future<void> _pickImage(bool isFront) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        if (isFront) {
          _frontImage = File(pickedFile.path);
        } else {
          _backImage = File(pickedFile.path);
        }
      });
    }
  }

  Future<void> _submitNidVerification() async {
    if (!_formKey.currentState!.validate()) return;
    if (_frontImage == null || _backImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please upload both front and back images')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final frontImagePath = 'nid_images/$_userId-front-${DateTime.now().millisecondsSinceEpoch}.jpg';
      final backImagePath = 'nid_images/$_userId-back-${DateTime.now().millisecondsSinceEpoch}.jpg';

      await supabase.storage.from('nid_images').upload(frontImagePath, _frontImage!);
      await supabase.storage.from('nid_images').upload(backImagePath, _backImage!);

      final frontImageUrl = supabase.storage.from('nid_images').getPublicUrl(frontImagePath);
      final backImageUrl = supabase.storage.from('nid_images').getPublicUrl(backImagePath);

      await supabase.from('nid_verifications').insert({
        'user_id': _userId,
        'nid_number': _nidController.text,
        'front_image_url': frontImageUrl,
        'back_image_url': backImageUrl,
        'verification_status': 'pending',
      });

      await supabase
          .from('users')
          .update({'verification_status': 'pending'})
          .eq('id', _userId!);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('NID verification submitted successfully!')),
      );
      setState(() {
        _verificationStatus = 'pending';
        _frontImage = null;
        _backImage = null;
        _nidController.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit verification: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _navigateToScreen(String route) {
    Navigator.pushNamed(context, route);
  }

  Future<void> _logout() async {
    await supabase.auth.signOut();
    Navigator.pushNamedAndRemoveUntil(context, '/homepage', (route) => false);
  }

  Widget _buildImagePicker(bool isFront) {
    return FadeInUp(
      duration: Duration(milliseconds: 800),
      child: GestureDetector(
        onTap: () => _pickImage(isFront),
        child: Container(
          height: 150,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.teal, width: 2),
          ),
          child: (isFront ? _frontImage : _backImage) == null
              ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FaIcon(
                FontAwesomeIcons.camera,
                color: Colors.teal,
                size: 40,
              ),
              SizedBox(height: 10),
              Text(
                isFront ? 'Upload Front Image' : 'Upload Back Image',
                style: TextStyle(
                  color: Colors.blueGrey[700],
                  fontFamily: 'Poppins',
                  fontSize: 16,
                ),
              ),
            ],
          )
              : ClipRRect(
            borderRadius: BorderRadius.circular(13),
            child: Image.file(
              isFront ? _frontImage! : _backImage!,
              fit: BoxFit.cover,
            ),
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
                            'NID Verification',
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
                        SizedBox(height: 10),
                        if (_verificationStatus != null)
                          FadeInUp(
                            duration: Duration(milliseconds: 800),
                            child: Text(
                              'Status: $_verificationStatus',
                              style: TextStyle(
                                fontSize: 18,
                                color: _verificationStatus == 'approved'
                                    ? Colors.green
                                    : _verificationStatus == 'rejected'
                                    ? Colors.red
                                    : Colors.orange,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        SizedBox(height: 20),
                        Card(
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            side: BorderSide(
                                color: Colors.teal.withOpacity(0.3),
                                width: 1),
                          ),
                          color: Colors.white.withOpacity(0.95),
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  FadeInUp(
                                    duration: Duration(milliseconds: 800),
                                    child: TextFormField(
                                      controller: _nidController,
                                      decoration: InputDecoration(
                                        labelText: 'NID Number *',
                                        labelStyle: TextStyle(
                                            color: Colors.blueGrey[700]),
                                        filled: true,
                                        fillColor: Colors.white
                                            .withOpacity(0.9),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius.circular(15),
                                          borderSide: BorderSide.none,
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius.circular(15),
                                          borderSide: BorderSide(
                                              color: Colors.teal,
                                              width: 2),
                                        ),
                                        prefixIcon: FaIcon(
                                            FontAwesomeIcons.idCard,
                                            color: Colors.teal),
                                        contentPadding:
                                        EdgeInsets.all(16),
                                      ),
                                      style: TextStyle(
                                          color: Colors.blueGrey[800],
                                          fontFamily: 'Poppins'),
                                      keyboardType: TextInputType.number,
                                      validator: (value) {
                                        if (value == null ||
                                            value.isEmpty) {
                                          return 'NID number is required';
                                        }
                                        if (value.length != 17) {
                                          return 'NID number must be 17 digits';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  _buildImagePicker(true),
                                  SizedBox(height: 20),
                                  _buildImagePicker(false),
                                  SizedBox(height: 20),
                                  ZoomIn(
                                    duration: Duration(milliseconds: 300),
                                    child: ElevatedButton(
                                      onPressed: _submitNidVerification,
                                      style: ButtonStyle(
                                        backgroundColor:
                                        WidgetStateProperty.all(
                                            Colors.teal),
                                        padding: WidgetStateProperty.all(
                                            EdgeInsets.symmetric(
                                                horizontal: 40,
                                                vertical: 16)),
                                        shape: WidgetStateProperty.all(
                                            RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius.circular(
                                                    15))),
                                        elevation:
                                        WidgetStateProperty.all(5),
                                        shadowColor: WidgetStateProperty
                                            .all(Colors.teal
                                            .withAlpha(128)),
                                      ),
                                      child: Text(
                                        'Submit Verification',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'Poppins',
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
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