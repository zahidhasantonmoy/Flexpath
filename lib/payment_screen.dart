import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:animate_do/animate_do.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'global_menu.dart';
import 'sidebar_menu.dart';
import 'main.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  bool _isLoading = false;
  String? _selectedJobId;
  String? _selectedPaymentMethod;
  List<Map<String, dynamic>> _jobs = [];
  String? _userType;
  String? _userId;
  String? _userFullName;
  final List<String> _paymentMethods = ['bKash', 'Nagad', 'Rocket', 'Bank Transfer'];

  @override
  void initState() {
    super.initState();
    _fetchUserDataAndJobs();
  }

  Future<void> _fetchUserDataAndJobs() async {
    setState(() => _isLoading = true);
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');
      _userId = user.id;

      final userDataResponse = await supabase
          .from('users')
          .select('user_type, full_name')
          .eq('id', _userId!)
          .maybeSingle();

      if (userDataResponse == null) {
        throw Exception('User data not found');
      }

      _userType = userDataResponse['user_type'];
      _userFullName = userDataResponse['full_name'] ?? 'User';

      if (_userType == 'Employer') {
        final jobs = await supabase
            .from('job_applications')
            .select('job_id, jobs!inner(job_title, salary), worker_id, payment_status')
            .eq('employer_id', _userId!)
            .eq('job_status', 'completed');
        _jobs = List<Map<String, dynamic>>.from(jobs);
      } else if (_userType == 'Job Seeker') {
        final jobs = await supabase
            .from('job_applications')
            .select('job_id, jobs!inner(job_title, salary), employer_id, payment_status')
            .eq('worker_id', _userId!)
            .eq('job_status', 'completed');
        _jobs = List<Map<String, dynamic>>.from(jobs);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching data: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _processPayment(String jobId) async {
    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a payment method')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await supabase
          .from('job_applications')
          .update({'payment_status': 'completed'})
          .eq('job_id', jobId)
          .eq('employer_id', _userId!);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment processed successfully!')),
      );
      await _fetchUserDataAndJobs();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to process payment: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _navigateToScreen(String route) {
    FlexPathApp.navigateToScreen(context, route);
  }

  Future<void> _logout() async {
    await FlexPathApp.logout(context);
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<Map<String, dynamic>> items,
    required Function(String?) onChanged,
    required IconData icon,
  }) {
    return FadeInUp(
      duration: Duration(milliseconds: 800),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            labelText: '$label *',
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
          items: items.map((Map<String, dynamic> job) {
            return DropdownMenuItem<String>(
              value: job['job_id'] as String,
              child: Text(job['jobs']['job_title'] as String),
            );
          }).toList(),
          onChanged: onChanged,
          validator: (value) => value == null ? 'This field is required' : null,
          dropdownColor: Colors.white,
          icon: Icon(Icons.arrow_drop_down, color: Colors.teal),
          isExpanded: true,
        ),
      ),
    );
  }

  Widget _buildPendingPaymentBox(Map<String, dynamic> job) {
    return FadeInUp(
      duration: Duration(milliseconds: 800),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: Colors.orange.withOpacity(0.5), width: 1),
        ),
        color: Colors.white.withOpacity(0.95),
        margin: EdgeInsets.symmetric(vertical: 8.0),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Payment Pending',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[700],
                  fontFamily: 'Poppins',
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Job Title: ${job['jobs']['job_title']}',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blueGrey[700],
                  fontFamily: 'Poppins',
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Amount: ${job['jobs']['salary']} BDT',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blueGrey[700],
                  fontFamily: 'Poppins',
                ),
              ),
              SizedBox(height: 10),
              if (_userType == 'Employer') ...[
                _buildDropdown(
                  label: 'Select Payment Method',
                  value: _selectedPaymentMethod,
                  items: _paymentMethods.map((method) => {'job_id': method, 'jobs': {'job_title': method}}).toList(),
                  onChanged: (value) {
                    setState(() => _selectedPaymentMethod = value);
                  },
                  icon: FontAwesomeIcons.wallet,
                ),
                SizedBox(height: 10),
                ZoomIn(
                  duration: Duration(milliseconds: 300),
                  child: ElevatedButton(
                    onPressed: () => _processPayment(job['job_id']),
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(Colors.orange),
                      padding: WidgetStateProperty.all(
                          EdgeInsets.symmetric(horizontal: 40, vertical: 16)),
                      shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15))),
                      elevation: WidgetStateProperty.all(5),
                      shadowColor:
                      WidgetStateProperty.all(Colors.orange.withAlpha(128)),
                    ),
                    child: Text(
                      'Pay Now',
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
            ],
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
                            'Welcome ${_userFullName ?? 'User'} to Payments',
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
                            child: Column(
                              children: [
                                _buildDropdown(
                                  label: 'Select Job',
                                  value: _selectedJobId,
                                  items: _jobs,
                                  onChanged: (value) {
                                    setState(() => _selectedJobId = value);
                                  },
                                  icon: FontAwesomeIcons.briefcase,
                                ),
                                if (_selectedJobId != null) ...[
                                  SizedBox(height: 10),
                                  FadeInUp(
                                    duration: Duration(milliseconds: 800),
                                    child: Text(
                                      'Amount: ${_jobs.firstWhere((job) => job['job_id'] == _selectedJobId)['jobs']['salary']} BDT',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blueGrey[700],
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  FadeInUp(
                                    duration: Duration(milliseconds: 800),
                                    child: Text(
                                      'Payment Status: ${_jobs.firstWhere((job) => job['job_id'] == _selectedJobId)['payment_status']}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.blueGrey[700],
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        if (_jobs.isNotEmpty)
                          ..._jobs
                              .where((job) =>
                          job['payment_status'] == 'pending')
                              .map((job) => _buildPendingPaymentBox(job))
                              .toList(),
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