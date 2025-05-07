import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:animate_do/animate_do.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'global_menu.dart';

class RatingFeedbackScreen extends StatefulWidget {
  const RatingFeedbackScreen({super.key});

  @override
  State<RatingFeedbackScreen> createState() => _RatingFeedbackScreenState();
}

class _RatingFeedbackScreenState extends State<RatingFeedbackScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  bool _isLoading = false;
  final Map<String, dynamic> _jobRatings = {};
  final Map<String, TextEditingController> _feedbackControllers = {};
  List<Map<String, dynamic>> _completedJobs = [];
  String? _userType;
  String? _userId;
  String? _userFullName;

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

      final userData = await supabase
          .from('users')
          .select('user_type, full_name')
          .eq('id', _userId!)
          .single();
      _userType = userData['user_type'];
      _userFullName = userData['full_name'];

      if (_userType == 'Employer') {
        final jobs = await supabase
            .from('job_applications')
            .select('job_id, jobs!inner(job_title, id), worker_id')
            .eq('employer_id', _userId!)
            .eq('job_status', 'completed');
        _completedJobs = jobs;
      } else if (_userType == 'Job Seeker') {
        final jobs = await supabase
            .from('job_applications')
            .select('job_id, jobs!inner(job_title, id), employer_id')
            .eq('worker_id', _userId!)
            .eq('job_status', 'completed');
        _completedJobs = jobs;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching data: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
      _completedJobs.forEach((job) {
        _jobRatings[job['job_id']] = _jobRatings[job['job_id']] ?? 0;
        _feedbackControllers[job['job_id']] =
            _feedbackControllers[job['job_id']] ?? TextEditingController();
      });
    }
  }

  Future<void> _submitRating(String jobId) async {
    final rating = _jobRatings[jobId];
    final feedback = _feedbackControllers[jobId]!.text;
    if (rating == null || rating == 0 || feedback.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please provide a rating and feedback')),
      );
      return;
    }

    if (feedback.length > 150) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Feedback must be 150 characters or less')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final jobData = _completedJobs.firstWhere((job) => job['job_id'] == jobId);
      final targetUserId = _userType == 'Employer' ? jobData['worker_id'] : jobData['employer_id'];

      await supabase.from('ratings').insert({
        'job_id': jobId,
        'worker_id': _userType == 'Employer' ? targetUserId : _userId,
        'employer_id': _userType == 'Employer' ? _userId : targetUserId,
        'worker_rating': _userType == 'Employer' ? rating : null,
        'employer_rating': _userType == 'Job Seeker' ? rating : null,
        'worker_feedback': _userType == 'Employer' ? feedback : null,
        'employer_feedback': _userType == 'Job Seeker' ? feedback : null,
      });

      final ratingField = _userType == 'Employer' ? 'worker_rating' : 'employer_rating';
      final ratings = await supabase
          .from('ratings')
          .select(ratingField)
          .eq(_userType == 'Employer' ? 'worker_id' : 'employer_id', targetUserId);

      final validRatings = ratings
          .where((rating) => rating[ratingField] != null)
          .map((rating) => (rating[ratingField] as num).toDouble())
          .toList();

      final averageRating = validRatings.isEmpty
          ? 0
          : validRatings.reduce((a, b) => a + b) / validRatings.length;

      await supabase
          .from('users')
          .update({'global_rating': averageRating})
          .eq('id', targetUserId);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Rating and feedback submitted for $jobId!')),
      );
      setState(() {
        _jobRatings[jobId] = 0;
        _feedbackControllers[jobId]!.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit rating: $e')),
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

  Widget _buildJobCard(String jobId, String jobTitle) {
    return FadeInUp(
      duration: Duration(milliseconds: 800),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: Colors.teal.withOpacity(0.3), width: 1),
        ),
        color: Colors.white.withOpacity(0.95),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal.shade100, Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                jobTitle,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey[800],
                  fontFamily: 'Poppins',
                ),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < (_jobRatings[jobId] ?? 0)
                          ? Icons.star
                          : Icons.star_border,
                      color: Colors.teal,
                      size: 30,
                    ),
                    onPressed: () {
                      setState(() => _jobRatings[jobId] = index + 1);
                    },
                  );
                }),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _feedbackControllers[jobId],
                maxLines: 3,
                maxLength: 150,
                decoration: InputDecoration(
                  labelText: 'Feedback',
                  labelStyle: TextStyle(color: Colors.blueGrey[700]),
                  hintText: 'Enter your feedback (max 150 characters)',
                  hintStyle: TextStyle(color: Colors.blueGrey[300]),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.teal, width: 2),
                  ),
                  prefixIcon: Icon(FontAwesomeIcons.comment, color: Colors.teal),
                  contentPadding: EdgeInsets.all(12),
                ),
                style: TextStyle(color: Colors.blueGrey[800], fontFamily: 'Poppins'),
              ),
              SizedBox(height: 10),
              ZoomIn(
                duration: Duration(milliseconds: 300),
                child: ElevatedButton(
                  onPressed: () => _submitRating(jobId),
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(Colors.teal),
                    padding: WidgetStateProperty.all(
                        EdgeInsets.symmetric(horizontal: 20, vertical: 10)),
                    shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    elevation: WidgetStateProperty.all(5),
                    shadowColor: WidgetStateProperty.all(Colors.teal.withAlpha(128)),
                  ),
                  child: Text(
                    'Submit',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              FadeInDown(
                                duration: Duration(milliseconds: 800),
                                child: Text(
                                  _userFullName != null
                                      ? 'Welcome, $_userFullName!'
                                      : 'Welcome!',
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
                                ),
                              ),
                              SizedBox(height: 10),
                              FadeInDown(
                                duration: Duration(milliseconds: 800),
                                child: Text(
                                  'Rate & Feedback',
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
                              if (_completedJobs.isNotEmpty)
                                ..._completedJobs.map((job) => _buildJobCard(
                                  job['job_id'],
                                  job['jobs']['job_title'],
                                )).toList()
                              else
                                Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Text(
                                    'No completed jobs to rate.',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.blueGrey[600],
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      floatingActionButton: GlobalMenu(
        navigateToScreen: _navigateToScreen,
        logout: _logout,
      ),
    );
  }
}