import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'global_menu.dart';

class JobFeedScreen extends StatefulWidget {
  const JobFeedScreen({super.key});

  @override
  State<JobFeedScreen> createState() => _JobFeedScreenState();
}

class _JobFeedScreenState extends State<JobFeedScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> jobs = [];
  bool _isLoading = true;
  bool _isBengali = false;
  int _page = 0;
  final int _limit = 10;
  bool _hasMore = true;
  String? _selectedLocation;
  String? _selectedJobType;
  DateTimeRange? _selectedDateRange;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchJobs();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && _hasMore) {
        _fetchJobs(loadMore: true);
      }
    });
  }

  Future<void> _fetchJobs({bool loadMore = false}) async {
    if (!loadMore) setState(() => _isLoading = true);
    try {
      var query = supabase.from('jobs').select('*, users!employer_id(full_name)').eq('status', 'open');

      // Apply filters
      if (_selectedLocation != null) query = query.eq('location', _selectedLocation!);
      if (_selectedJobType != null) query = query.contains('skills', '{${_selectedJobType!}}');
      if (_selectedDateRange != null) {
        query = query
            .gte('created_at', _selectedDateRange!.start.toIso8601String())
            .lte('created_at', _selectedDateRange!.end.toIso8601String());
      }

      final response = await query
          .range(_page * _limit, (_page + 1) * _limit - 1)
          .order('created_at', ascending: false);

      setState(() {
        if (loadMore) {
          jobs.addAll(response as List<Map<String, dynamic>>);
        } else {
          jobs = response as List<Map<String, dynamic>>;
        }
        _hasMore = (response as List).length == _limit;
        if (_hasMore) _page++;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load jobs: $e')));
    }
  }

  Future<void> _saveJob(String jobId) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please sign in to save jobs')));
        return;
      }
      await supabase.from('saved_jobs').insert({'user_id': userId, 'job_id': jobId});
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Job saved successfully!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save job: $e')));
    }
  }

  void _navigateToScreen(String route) {
    Navigator.pushNamed(context, route);
  }

  Future<void> _logout() async {
    await supabase.auth.signOut();
    Navigator.pushNamedAndRemoveUntil(context, '/homepage', (route) => false);
  }

  void _applyFilters() {
    _page = 0;
    _hasMore = true;
    _fetchJobs();
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
            fit: StackFit.expand,
            children: [
              Column(
                children: [
                  // Filter Bar
                  Container(
                    padding: EdgeInsets.all(8.0),
                    color: Colors.blueAccent.withOpacity(0.1),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          // Location Filter
                          DropdownButton<String>(
                            hint: Text('Location', style: TextStyle(color: Colors.blueGrey)),
                            value: _selectedLocation,
                            items: ['Dhaka', 'Chittagong', 'Sylhet', 'Khulna']
                                .map((location) => DropdownMenuItem(value: location, child: Text(location, style: TextStyle(color: Colors.black))))
                                .toList(),
                            onChanged: (value) => setState(() => _selectedLocation = value),
                          ),
                          SizedBox(width: 10),
                          // Job Type Filter
                          DropdownButton<String>(
                            hint: Text('Job Type', style: TextStyle(color: Colors.blueGrey)),
                            value: _selectedJobType,
                            items: ['typing', 'design', 'writing', 'development']
                                .map((type) => DropdownMenuItem(value: type, child: Text(type, style: TextStyle(color: Colors.black))))
                                .toList(),
                            onChanged: (value) => setState(() => _selectedJobType = value),
                          ),
                          SizedBox(width: 10),
                          // Date Range Filter
                          ElevatedButton(
                            onPressed: () async {
                              final range = await showDateRangePicker(
                                context: context,
                                firstDate: DateTime(2025, 1, 1),
                                lastDate: DateTime(2025, 12, 31),
                                initialDateRange: _selectedDateRange,
                              );
                              setState(() => _selectedDateRange = range);
                            },
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(Colors.blueAccent),
                              shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                            ),
                            child: Text(
                              _selectedDateRange == null ? 'Select Date' : 'Date Set',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          SizedBox(width: 10),
                          // Apply Filters Button
                          ElevatedButton(
                            onPressed: _applyFilters,
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(Colors.green),
                              shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                            ),
                            child: Text('Apply', style: TextStyle(color: Colors.white)),
                          ),
                          SizedBox(width: 10),
                          // Bengali Toggle
                          IconButton(
                            icon: Icon(_isBengali ? Icons.language : Icons.translate, color: Colors.blueAccent),
                            onPressed: () => setState(() => _isBengali = !_isBengali),
                            tooltip: 'Toggle Language',
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Weather Suggestion (Simulated)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      children: [
                        Icon(Icons.cloud, color: Colors.blueAccent),
                        SizedBox(width: 8),
                        Text(
                          _selectedLocation == null
                              ? 'Select a location for weather-based suggestions'
                              : 'Weather in $_selectedLocation: Rainy - Indoor jobs recommended',
                          style: TextStyle(color: Colors.blueGrey[600]),
                        ),
                      ],
                    ),
                  ),
                  // Job List
                  Expanded(
                    child: _isLoading
                        ? Center(child: CircularProgressIndicator(color: Colors.green))
                        : jobs.isEmpty
                        ? Center(child: Text('No jobs available', style: TextStyle(color: Colors.blueGrey)))
                        : ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.all(16.0),
                      itemCount: jobs.length + (_hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == jobs.length) {
                          return Center(child: CircularProgressIndicator(color: Colors.green));
                        }
                        final job = jobs[index];
                        return FadeInUp(
                          duration: Duration(milliseconds: 800),
                          delay: Duration(milliseconds: index * 200),
                          child: Card(
                            elevation: 5,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            color: Colors.white,
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Image or Icon
                                  Container(
                                    width: 50,
                                    height: 50,
                                    child: FutureBuilder(
                                      future: _getImageUrl(job['id']),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                          return Center(child: CircularProgressIndicator(color: Colors.teal));
                                        }
                                        if (snapshot.hasData && snapshot.data != null) {
                                          return ClipRRect(
                                            borderRadius: BorderRadius.circular(10),
                                            child: Image.network(
                                              snapshot.data!,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) =>
                                                  _getJobIcon(job['skills']),
                                            ),
                                          );
                                        }
                                        return _getJobIcon(job['skills']);
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  // Job Details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _isBengali ? _translateToBengali(job['title']) : job['title'] ?? 'No Title',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.teal,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Location: ${job['location'] ?? 'N/A'}',
                                          style: TextStyle(color: Colors.blueGrey[600]),
                                        ),
                                        Text(
                                          'Pay: ${job['pay'] ?? 'N/A'} BDT',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green,
                                          ),
                                        ),
                                        Text(
                                          'Skills: ${job['skills']?.join(', ') ?? 'N/A'}',
                                          style: TextStyle(color: Colors.blueGrey[600]),
                                        ),
                                        Text(
                                          'Posted by: ${job['users']?['full_name'] ?? 'Unknown'}',
                                          style: TextStyle(color: Colors.blueGrey[600]),
                                        ),
                                        Text(
                                          'Match: 85%', // Simulated compatibility score
                                          style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Actions
                                  Column(
                                    children: [
                                      ZoomIn(
                                        duration: Duration(milliseconds: 300),
                                        child: ElevatedButton(
                                          onPressed: () {},
                                          style: ButtonStyle(
                                            backgroundColor: WidgetStateProperty.all(Colors.teal),
                                            shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                                            elevation: WidgetStateProperty.all(5),
                                            shadowColor: WidgetStateProperty.all(Colors.green.withAlpha(128)),
                                          ),
                                          child: Text('Apply Now', style: TextStyle(color: Colors.white)),
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      IconButton(
                                        icon: Icon(Icons.bookmark_border, color: Colors.blueAccent),
                                        onPressed: () => _saveJob(job['id']),
                                        tooltip: 'Save Job',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              // Global Menu
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

  Future<String?> _getImageUrl(String jobId) async {
    try {
      final url = supabase.storage.from('job-images').getPublicUrl('$jobId/image.jpg');
      return url;
    } catch (e) {
      return null;
    }
  }

  Widget _getJobIcon(List<dynamic>? skills) {
    if (skills == null) return Icon(Icons.work_outline, color: Colors.teal, size: 40);
    if (skills.contains('design')) return Icon(Icons.brush, color: Colors.teal, size: 40);
    if (skills.contains('writing')) return Icon(Icons.edit, color: Colors.teal, size: 40);
    if (skills.contains('development')) return Icon(Icons.code, color: Colors.teal, size: 40);
    return Icon(Icons.work_outline, color: Colors.teal, size: 40);
  }

  String _translateToBengali(String text) {
    // Simulated translation (replace with actual translation API or mapping in production)
    final translations = {
      'Data Entry Clerk': 'ডাটা এন্ট্রি ক্লার্ক',
      'Graphic Designer': 'গ্রাফিক ডিজাইনার',
      'Delivery Rider': 'ডেলিভারি রাইডার',
      'Content Writer': 'কন্টেন্ট রাইটার',
      'Web Developer': 'ওয়েব ডেভেলপার',
    };
    return translations[text] ?? text;
  }
}