import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:animate_do/animate_do.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'global_menu.dart';

class JobPostScreen extends StatefulWidget {
  const JobPostScreen({super.key});

  @override
  State<JobPostScreen> createState() => _JobPostScreenState();
}

class _JobPostScreenState extends State<JobPostScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  final PageController _pageController = PageController();
  bool _isLoading = false;

  // Form controllers
  final TextEditingController _jobTitleController = TextEditingController();
  final TextEditingController _jobDescriptionController = TextEditingController();
  final TextEditingController _salaryController = TextEditingController();
  final TextEditingController _requiredSkillsController = TextEditingController();
  final TextEditingController _deadlineController = TextEditingController();
  final TextEditingController _requiredExperienceController = TextEditingController();

  // Dropdown values
  String? _selectedJobCategory;
  String? _selectedJobType;
  String? _selectedExperienceLevel;
  String? _selectedLocation;
  String? _selectedPaymentMethod;
  String? _selectedJobUrgency;
  String? _selectedCompanySize;
  String? _selectedWorkHours;
  String? _selectedContractType;
  String? _selectedGenderPreference;
  String? _selectedRemoteOnSite;
  String? _selectedWorkSchedule;
  String? _selectedLanguages;

  // Switch values
  bool _jobScheduleFlexibility = false;
  bool _transportationTravelAssistance = false;

  // Predefined dropdown options
  final List<String> _jobCategories = [
    'Tutoring', 'Delivery', 'Freelance', 'Customer Service',
    'Sales and Marketing', 'Data Entry', 'IT and Software',
    'Healthcare and Medical', 'Engineering', 'Administration',
    'Design and Creative', 'Construction and Labor', 'Finance and Accounting',
    'Hospitality and Tourism', 'Manufacturing', 'Human Resources', 'Other'
  ];

  final List<String> _jobTypes = [
    'Full-time', 'Part-time', 'Temporary', 'Freelance', 'Internship', 'Contract-based'
  ];

  final List<String> _experienceLevels = [
    'Entry-level', 'Mid-level', 'Senior-level', 'Beginner', 'Intermediate', 'Expert'
  ];

  final List<String> _locations = [
    'Dhaka', 'Chittagong', 'Khulna', 'Rajshahi', 'Sylhet', 'Barisal',
    'Rangpur', 'Mymensingh', 'Rural Areas'
  ];

  final List<String> _paymentMethods = [
    'Cash', 'Bank Transfer', 'Mobile Banking', 'Check', 'Digital Wallet'
  ];

  final List<String> _jobUrgencyOptions = [
    'Immediate Hiring', 'Hiring Soon', 'Urgent Requirement'
  ];

  final List<String> _companySizes = [
    'Small (1-10 employees)', 'Medium (11-50 employees)', 'Large (51+ employees)'
  ];

  final List<String> _workHoursOptions = [
    '8 hours/day', '6 hours/day', 'Flexible Hours', 'Night Shift', 'Weekend Work'
  ];

  final List<String> _contractTypes = [
    'Freelance', 'Contract-based', 'Permanent', 'Temporary'
  ];

  final List<String> _genderPreferences = [
    'Male', 'Female', 'No Preference'
  ];

  final List<String> _remoteOnSiteOptions = [
    'Remote', 'On-Site', 'Hybrid'
  ];

  final List<String> _workSchedules = [
    'Day Shift', 'Night Shift', 'Morning Shift', 'Weekend Shift', 'Flexible Hours'
  ];

  final List<String> _languageOptions = [
    'Bangla', 'English', 'Hindi', 'Arabic', 'Urdu'
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _jobTitleController.dispose();
    _jobDescriptionController.dispose();
    _salaryController.dispose();
    _requiredSkillsController.dispose();
    _deadlineController.dispose();
    _requiredExperienceController.dispose();
    super.dispose();
  }

  Future<void> _postJob() async {
    if (!_validateMustNeedFields()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      await supabase.from('jobs').insert({
        'employer_id': userId,
        'job_title': _jobTitleController.text,
        'job_description': _jobDescriptionController.text,
        'job_category': _selectedJobCategory,
        'location': _selectedLocation,
        'job_type': _selectedJobType,
        'salary': double.tryParse(_salaryController.text) ?? 0.0,
        'experience_level': _selectedExperienceLevel,
        'required_skills': _requiredSkillsController.text.split(',').map((s) => s.trim()).toList(),
        'deadline': _deadlineController.text,
        'payment_method': _selectedPaymentMethod,
        'required_experience': int.tryParse(_requiredExperienceController.text) ?? 0,
        'job_urgency': _selectedJobUrgency,
        'company_size': _selectedCompanySize,
        'work_hours': _selectedWorkHours,
        'contract_type': _selectedContractType,
        'gender_preference': _selectedGenderPreference,
        'remote_on_site_indicator': _selectedRemoteOnSite,
        'work_schedule': _selectedWorkSchedule,
        'languages_required': _selectedLanguages?.split(',').map((s) => s.trim()).toList(),
        'job_schedule_flexibility': _jobScheduleFlexibility,
        'transportation_travel_assistance': _transportationTravelAssistance,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Job posted successfully!')),
      );
      Navigator.pushNamed(context, '/jobFeed');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to post job: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  bool _validateMustNeedFields() {
    return _jobTitleController.text.isNotEmpty &&
        _jobDescriptionController.text.isNotEmpty &&
        _selectedJobCategory != null &&
        _selectedLocation != null &&
        _selectedJobType != null &&
        _salaryController.text.isNotEmpty &&
        _selectedExperienceLevel != null &&
        _requiredSkillsController.text.isNotEmpty &&
        _deadlineController.text.isNotEmpty &&
        _selectedPaymentMethod != null &&
        _requiredExperienceController.text.isNotEmpty &&
        _selectedJobUrgency != null;
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _navigateToScreen(String route) {
    Navigator.pushNamed(context, route);
  }

  Future<void> _logout() async {
    await supabase.auth.signOut();
    Navigator.pushNamedAndRemoveUntil(context, '/homepage', (route) => false);
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2026),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.teal,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.blueGrey[700]!,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _deadlineController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    String? hintText,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    bool isRequired = true,
    VoidCallback? onTap,
  }) {
    return FadeInUp(
      duration: Duration(milliseconds: 800),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          readOnly: onTap != null,
          onTap: onTap,
          decoration: InputDecoration(
            labelText: isRequired ? '$label *' : label,
            labelStyle: TextStyle(color: Colors.blueGrey[700]),
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.blueGrey[300]),
            filled: true,
            fillColor: Colors.white.withOpacity(0.9),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.teal, width: 2),
            ),
            prefixIcon: Icon(icon, color: Colors.teal),
            contentPadding: EdgeInsets.all(16),
          ),
          style: TextStyle(color: Colors.blueGrey[800], fontFamily: 'Poppins'),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    required IconData icon,
    bool isRequired = true,
  }) {
    return FadeInUp(
      duration: Duration(milliseconds: 800),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            labelText: isRequired ? '$label *' : label,
            labelStyle: TextStyle(color: Colors.blueGrey[700]),
            filled: true,
            fillColor: Colors.white.withOpacity(0.9),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.teal, width: 2),
            ),
            prefixIcon: Icon(icon, color: Colors.teal),
            contentPadding: EdgeInsets.all(16),
          ),
          style: TextStyle(color: Colors.blueGrey[800], fontFamily: 'Poppins'),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
          validator: isRequired
              ? (value) => value == null ? 'This field is required' : null
              : null,
          dropdownColor: Colors.white,
          icon: Icon(Icons.arrow_drop_down, color: Colors.teal),
          isExpanded: true,
        ),
      ),
    );
  }

  Widget _buildSwitchField({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
  }) {
    return FadeInUp(
      duration: Duration(milliseconds: 800),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.teal, size: 24),
                SizedBox(width: 10),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.blueGrey[700],
                    fontFamily: 'Poppins',
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: Colors.teal,
              inactiveThumbColor: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade100, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              _isLoading
                  ? Center(child: CircularProgressIndicator(color: Colors.teal))
                  : PageView(
                controller: _pageController,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  // Required Fields Screen
                  SingleChildScrollView(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        FadeInDown(
                          duration: Duration(milliseconds: 800),
                          child: Text(
                            'Post a Job',
                            style: TextStyle(
                              fontSize: 32,
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
                          ),
                        ),
                        SizedBox(height: 20),
                        Card(
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            side: BorderSide(color: Colors.teal.withOpacity(0.3), width: 1),
                          ),
                          color: Colors.white.withOpacity(0.95),
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                _buildTextField(
                                  label: 'Job Title',
                                  controller: _jobTitleController,
                                  icon: FontAwesomeIcons.briefcase,
                                  hintText: 'e.g., Software Developer',
                                ),
                                _buildTextField(
                                  label: 'Job Description',
                                  controller: _jobDescriptionController,
                                  icon: FontAwesomeIcons.fileAlt,
                                  maxLines: 4,
                                  hintText: 'Describe the job responsibilities',
                                ),
                                _buildDropdown(
                                  label: 'Job Category',
                                  value: _selectedJobCategory,
                                  items: _jobCategories,
                                  onChanged: (value) => setState(() => _selectedJobCategory = value),
                                  icon: FontAwesomeIcons.tag,
                                ),
                                _buildDropdown(
                                  label: 'Location',
                                  value: _selectedLocation,
                                  items: _locations,
                                  onChanged: (value) => setState(() => _selectedLocation = value),
                                  icon: FontAwesomeIcons.mapMarkerAlt,
                                ),
                                _buildDropdown(
                                  label: 'Job Type',
                                  value: _selectedJobType,
                                  items: _jobTypes,
                                  onChanged: (value) => setState(() => _selectedJobType = value),
                                  icon: FontAwesomeIcons.clock,
                                ),
                                _buildTextField(
                                  label: 'Salary (BDT)',
                                  controller: _salaryController,
                                  icon: FontAwesomeIcons.moneyBillWave,
                                  keyboardType: TextInputType.number,
                                  hintText: 'e.g., 50000',
                                ),
                                _buildDropdown(
                                  label: 'Experience Level',
                                  value: _selectedExperienceLevel,
                                  items: _experienceLevels,
                                  onChanged: (value) => setState(() => _selectedExperienceLevel = value),
                                  icon: FontAwesomeIcons.star,
                                ),
                                _buildTextField(
                                  label: 'Required Skills',
                                  controller: _requiredSkillsController,
                                  icon: FontAwesomeIcons.tools,
                                  hintText: 'e.g., Flutter, Dart, SQL',
                                ),
                                _buildTextField(
                                  label: 'Deadline',
                                  controller: _deadlineController,
                                  icon: FontAwesomeIcons.calendarAlt,
                                  hintText: 'YYYY-MM-DD',
                                  onTap: _selectDate,
                                ),
                                _buildDropdown(
                                  label: 'Payment Method',
                                  value: _selectedPaymentMethod,
                                  items: _paymentMethods,
                                  onChanged: (value) => setState(() => _selectedPaymentMethod = value),
                                  icon: FontAwesomeIcons.creditCard,
                                ),
                                _buildTextField(
                                  label: 'Required Experience (Years)',
                                  controller: _requiredExperienceController,
                                  icon: FontAwesomeIcons.history,
                                  keyboardType: TextInputType.number,
                                  hintText: 'e.g., 2',
                                ),
                                _buildDropdown(
                                  label: 'Job Urgency',
                                  value: _selectedJobUrgency,
                                  items: _jobUrgencyOptions,
                                  onChanged: (value) => setState(() => _selectedJobUrgency = value),
                                  icon: FontAwesomeIcons.exclamationTriangle,
                                ),
                                SizedBox(height: 20),
                                ZoomIn(
                                  duration: Duration(milliseconds: 300),
                                  child: ElevatedButton(
                                    onPressed: _nextPage,
                                    style: ButtonStyle(
                                      backgroundColor: WidgetStateProperty.all(Colors.teal),
                                      padding: WidgetStateProperty.all(EdgeInsets.symmetric(horizontal: 40, vertical: 16)),
                                      shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                                      elevation: WidgetStateProperty.all(5),
                                      shadowColor: WidgetStateProperty.all(Colors.teal.withAlpha(128)),
                                    ),
                                    child: Text(
                                      'Next',
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
                      ],
                    ),
                  ),
                  // Optional Fields Screen
                  SingleChildScrollView(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        FadeInDown(
                          duration: Duration(milliseconds: 800),
                          child: Text(
                            'Additional Details',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey[700],
                              fontFamily: 'Poppins',
                              shadows: [
                                Shadow(
                                  blurRadius: 10,
                                  color: Colors.purpleAccent.withAlpha(77),
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Card(
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            side: BorderSide(color: Colors.purpleAccent.withOpacity(0.3), width: 1),
                          ),
                          color: Colors.white.withOpacity(0.95),
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                _buildDropdown(
                                  label: 'Company Size',
                                  value: _selectedCompanySize,
                                  items: _companySizes,
                                  onChanged: (value) => setState(() => _selectedCompanySize = value),
                                  icon: FontAwesomeIcons.building,
                                  isRequired: false,
                                ),
                                _buildDropdown(
                                  label: 'Work Hours',
                                  value: _selectedWorkHours,
                                  items: _workHoursOptions,
                                  onChanged: (value) => setState(() => _selectedWorkHours = value),
                                  icon: FontAwesomeIcons.clock,
                                  isRequired: false,
                                ),
                                _buildDropdown(
                                  label: 'Contract Type',
                                  value: _selectedContractType,
                                  items: _contractTypes,
                                  onChanged: (value) => setState(() => _selectedContractType = value),
                                  icon: FontAwesomeIcons.fileContract,
                                  isRequired: false,
                                ),
                                _buildDropdown(
                                  label: 'Gender Preference',
                                  value: _selectedGenderPreference,
                                  items: _genderPreferences,
                                  onChanged: (value) => setState(() => _selectedGenderPreference = value),
                                  icon: FontAwesomeIcons.user,
                                  isRequired: false,
                                ),
                                _buildDropdown(
                                  label: 'Remote/On-Site',
                                  value: _selectedRemoteOnSite,
                                  items: _remoteOnSiteOptions,
                                  onChanged: (value) => setState(() => _selectedRemoteOnSite = value),
                                  icon: FontAwesomeIcons.globe,
                                  isRequired: false,
                                ),
                                _buildDropdown(
                                  label: 'Work Schedule',
                                  value: _selectedWorkSchedule,
                                  items: _workSchedules,
                                  onChanged: (value) => setState(() => _selectedWorkSchedule = value),
                                  icon: FontAwesomeIcons.calendar,
                                  isRequired: false,
                                ),
                                _buildDropdown(
                                  label: 'Languages Required',
                                  value: _selectedLanguages,
                                  items: _languageOptions,
                                  onChanged: (value) => setState(() => _selectedLanguages = value),
                                  icon: FontAwesomeIcons.language,
                                  isRequired: false,
                                ),
                                _buildSwitchField(
                                  label: 'Flexible Schedule',
                                  value: _jobScheduleFlexibility,
                                  onChanged: (value) => setState(() => _jobScheduleFlexibility = value),
                                  icon: FontAwesomeIcons.syncAlt,
                                ),
                                _buildSwitchField(
                                  label: 'Transportation Assistance',
                                  value: _transportationTravelAssistance,
                                  onChanged: (value) => setState(() => _transportationTravelAssistance = value),
                                  icon: FontAwesomeIcons.bus,
                                ),
                                SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    ZoomIn(
                                      duration: Duration(milliseconds: 300),
                                      child: ElevatedButton(
                                        onPressed: _previousPage,
                                        style: ButtonStyle(
                                          backgroundColor: WidgetStateProperty.all(Colors.grey[600]),
                                          padding: WidgetStateProperty.all(EdgeInsets.symmetric(horizontal: 30, vertical: 16)),
                                          shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                                          elevation: WidgetStateProperty.all(5),
                                        ),
                                        child: Text(
                                          'Previous',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'Poppins',
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    ZoomIn(
                                      duration: Duration(milliseconds: 300),
                                      child: ElevatedButton(
                                        onPressed: _postJob,
                                        style: ButtonStyle(
                                          backgroundColor: WidgetStateProperty.all(Colors.purpleAccent),
                                          padding: WidgetStateProperty.all(EdgeInsets.symmetric(horizontal: 30, vertical: 16)),
                                          shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                                          elevation: WidgetStateProperty.all(5),
                                          shadowColor: WidgetStateProperty.all(Colors.purpleAccent.withAlpha(128)),
                                        ),
                                        child: Text(
                                          'Post Job',
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
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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