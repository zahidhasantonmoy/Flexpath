import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:animate_do/animate_do.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'global_menu.dart';
import 'sidebar_menu.dart';
import 'main.dart';

class JobFeedScreen extends StatefulWidget {
  const JobFeedScreen({super.key});

  @override
  State<JobFeedScreen> createState() => _JobFeedScreenState();
}

class _JobFeedScreenState extends State<JobFeedScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> jobs = [];
  bool _isLoading = true;
  int _page = 0;
  final int _limit = 10;
  bool _hasMore = true;
  String? _selectedLocation;
  String? _selectedJobType;
  String? _selectedJobCategory;
  DateTimeRange? _selectedDateRange;
  String? _minSalary;
  String? _maxSalary;
  String? _searchQuery;
  String? _sortBy;
  final ScrollController _scrollController = ScrollController();
  final Map<String, List<Map<String, dynamic>>> _jobCache = {};
  bool _showFilter = false;

  final List<String> _locations = [
    'Dhaka', 'Chittagong', 'Khulna', 'Rajshahi', 'Sylhet', 'Barisal',
    'Rangpur', 'Mymensingh', 'Rural Areas'
  ];
  final List<String> _jobTypes = [
    'Full-time', 'Part-time', 'Temporary', 'Freelance', 'Internship', 'Contract-based'
  ];
  final List<String> _jobCategories = [
    'Tutoring', 'Delivery', 'Freelance', 'Customer Service',
    'Sales and Marketing', 'Data Entry', 'IT and Software',
    'Healthcare and Medical', 'Engineering', 'Administration',
    'Design and Creative', 'Construction and Labor', 'Finance and Accounting',
    'Hospitality and Tourism', 'Manufacturing', 'Human Resources', 'Other'
  ];
  final List<String> _sortOptions = [
    'salary_asc', 'salary_desc', 'created_at_new', 'created_at_old'
  ];

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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchJobs({bool loadMore = false}) async {
    if (!loadMore) setState(() => _isLoading = true);
    try {
      String cacheKey = _getCacheKey();
      if (_jobCache.containsKey(cacheKey) && !loadMore) {
        setState(() {
          jobs = _jobCache[cacheKey]!;
          _isLoading = false;
        });
        return;
      }

      var query = supabase
          .from('jobs')
          .select('*, users!employer_id(full_name)')
          .eq('status', 'open');

      if (_selectedLocation != null) query.eq('location', _selectedLocation!);
      if (_selectedJobType != null) query.eq('job_type', _selectedJobType!);
      if (_selectedJobCategory != null) query.eq('job_category', _selectedJobCategory!);
      if (_selectedDateRange != null) {
        query
            .gte('created_at', _selectedDateRange!.start.toIso8601String())
            .lte('created_at', _selectedDateRange!.end.toIso8601String());
      }
      if (_minSalary != null && _minSalary!.isNotEmpty) {
        query.gte('salary', double.tryParse(_minSalary!) ?? 0.0);
      }
      if (_maxSalary != null && _maxSalary!.isNotEmpty) {
        query.lte('salary', double.tryParse(_maxSalary!) ?? double.infinity);
      }
      if (_searchQuery != null && _searchQuery!.isNotEmpty) {
        query.or('job_title.ilike.%$_searchQuery%,required_skills.ilike.%$_searchQuery%');
      }

      if (_sortBy == 'salary_asc') query.order('salary', ascending: true);
      if (_sortBy == 'salary_desc') query.order('salary', ascending: false);
      if (_sortBy == 'created_at_new') query.order('created_at', ascending: false);
      if (_sortBy == 'created_at_old') query.order('created_at', ascending: true);

      final response = await query.range(_page * _limit, (_page + 1) * _limit - 1);

      setState(() {
        if (loadMore) {
          jobs.addAll(response);
        } else {
          jobs = response;
          _jobCache[cacheKey] = List.from(jobs);
        }
        _hasMore = response.length == _limit;
        if (_hasMore) _page++;
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load jobs: $e')),
      );
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveJob(String jobId) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please sign in to save jobs')),
        );
        return;
      }
      await supabase.from('saved_jobs').insert({'user_id': userId, 'job_id': jobId});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Job saved successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save job: $e')),
      );
    }
  }

  void _navigateToScreen(String route) {
    FlexPathApp.navigateToScreen(context, route);
  }

  Future<void> _logout() async {
    await FlexPathApp.logout(context);
  }

  void _applyFilters() {
    _page = 0;
    _hasMore = true;
    _fetchJobs();
    setState(() => _showFilter = false);
  }

  String _getCacheKey() {
    return '${_selectedLocation ?? ''}_${_selectedJobType ?? ''}_${_selectedJobCategory ?? ''}_'
        '${_selectedDateRange?.start ?? ''}_${_selectedDateRange?.end ?? ''}_'
        '${_minSalary ?? ''}_${_maxSalary ?? ''}_${_searchQuery ?? ''}_${_sortBy ?? ''}';
  }

  Widget _getJobIcon(List<dynamic>? skills) {
    if (skills == null || skills.isEmpty) {
      return Icon(FontAwesomeIcons.briefcase, color: Colors.teal, size: 40);
    }
    if (skills.contains('Flutter') || skills.contains('Dart')) {
      return Icon(FontAwesomeIcons.code, color: Colors.teal, size: 40);
    }
    if (skills.contains('Photoshop') || skills.contains('Illustrator')) {
      return Icon(FontAwesomeIcons.paintBrush, color: Colors.teal, size: 40);
    }
    if (skills.contains('Driving') || skills.contains('Navigation')) {
      return Icon(FontAwesomeIcons.truck, color: Colors.teal, size: 40);
    }
    return Icon(FontAwesomeIcons.briefcase, color: Colors.teal, size: 40);
  }

  Widget _buildFilterDialog() {
    return AnimatedPositioned(
      duration: Duration(milliseconds: 300),
      top: _showFilter ? 0 : -MediaQuery.of(context).size.height,
      left: 0,
      right: 0,
      height: MediaQuery.of(context).size.height,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade100, Colors.purple.shade100],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: BorderSide(color: Colors.teal.withOpacity(0.3), width: 1),
                ),
                color: Colors.white.withOpacity(0.95),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FadeInDown(
                        duration: Duration(milliseconds: 800),
                        child: Text(
                          'Filter Jobs',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey[700],
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedLocation,
                              decoration: InputDecoration(
                                labelText: 'Location',
                                labelStyle: TextStyle(color: Colors.blueGrey[700]),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.9),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide.none,
                                ),
                                prefixIcon: Icon(FontAwesomeIcons.mapMarkerAlt, color: Colors.teal),
                              ),
                              items: _locations.map((location) {
                                return DropdownMenuItem<String>(
                                  value: location,
                                  child: Text(location, style: TextStyle(fontFamily: 'Poppins')),
                                );
                              }).toList(),
                              onChanged: (value) => setState(() => _selectedLocation = value),
                              dropdownColor: Colors.white,
                              isExpanded: true,
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedJobType,
                              decoration: InputDecoration(
                                labelText: 'Job Type',
                                labelStyle: TextStyle(color: Colors.blueGrey[700]),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.9),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide.none,
                                ),
                                prefixIcon: Icon(FontAwesomeIcons.clock, color: Colors.teal),
                              ),
                              items: _jobTypes.map((type) {
                                return DropdownMenuItem<String>(
                                  value: type,
                                  child: Text(type, style: TextStyle(fontFamily: 'Poppins')),
                                );
                              }).toList(),
                              onChanged: (value) => setState(() => _selectedJobType = value),
                              dropdownColor: Colors.white,
                              isExpanded: true,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedJobCategory,
                              decoration: InputDecoration(
                                labelText: 'Job Category',
                                labelStyle: TextStyle(color: Colors.blueGrey[700]),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.9),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide.none,
                                ),
                                prefixIcon: Icon(FontAwesomeIcons.tag, color: Colors.teal),
                              ),
                              items: _jobCategories.map((category) {
                                return DropdownMenuItem<String>(
                                  value: category,
                                  child: Text(category, style: TextStyle(fontFamily: 'Poppins')),
                                );
                              }).toList(),
                              onChanged: (value) => setState(() => _selectedJobCategory = value),
                              dropdownColor: Colors.white,
                              isExpanded: true,
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                labelText: 'Search (Title/Skills)',
                                labelStyle: TextStyle(color: Colors.blueGrey[700]),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.9),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide.none,
                                ),
                                prefixIcon: Icon(FontAwesomeIcons.search, color: Colors.teal),
                              ),
                              style: TextStyle(fontFamily: 'Poppins'),
                              onChanged: (value) => setState(() => _searchQuery = value),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                labelText: 'Min Salary (BDT)',
                                labelStyle: TextStyle(color: Colors.blueGrey[700]),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.9),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide.none,
                                ),
                                prefixIcon: Icon(FontAwesomeIcons.moneyBillWave, color: Colors.teal),
                              ),
                              keyboardType: TextInputType.number,
                              style: TextStyle(fontFamily: 'Poppins'),
                              onChanged: (value) => setState(() => _minSalary = value),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                labelText: 'Max Salary (BDT)',
                                labelStyle: TextStyle(color: Colors.blueGrey[700]),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.9),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide.none,
                                ),
                                prefixIcon: Icon(FontAwesomeIcons.moneyBillWave, color: Colors.teal),
                              ),
                              keyboardType: TextInputType.number,
                              style: TextStyle(fontFamily: 'Poppins'),
                              onChanged: (value) => setState(() => _maxSalary = value),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                final range = await showDateRangePicker(
                                  context: context,
                                  firstDate: DateTime(2025, 1, 1),
                                  lastDate: DateTime(2025, 12, 31),
                                  initialDateRange: _selectedDateRange,
                                  builder: (context, child) => Theme(
                                    data: ThemeData.light().copyWith(
                                      colorScheme: ColorScheme.light(
                                        primary: Colors.teal,
                                        onPrimary: Colors.white,
                                        surface: Colors.white,
                                        onSurface: Colors.blueGrey[700]!,
                                      ),
                                    ),
                                    child: child!,
                                  ),
                                );
                                if (range != null) setState(() => _selectedDateRange = range);
                              },
                              style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.all(Colors.teal),
                                shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                                padding: WidgetStateProperty.all(EdgeInsets.symmetric(vertical: 16)),
                              ),
                              child: Text(
                                _selectedDateRange == null ? 'Select Date Range' : 'Date Range Set',
                                style: TextStyle(color: Colors.white, fontFamily: 'Poppins'),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _sortBy,
                              decoration: InputDecoration(
                                labelText: 'Sort By',
                                labelStyle: TextStyle(color: Colors.blueGrey[700]),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.9),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide.none,
                                ),
                                prefixIcon: Icon(FontAwesomeIcons.sort, color: Colors.teal),
                              ),
                              items: _sortOptions.map((sort) {
                                return DropdownMenuItem<String>(
                                  value: sort,
                                  child: Text(
                                    sort == 'salary_asc' ? 'Salary (Low to High)' :
                                    sort == 'salary_desc' ? 'Salary (High to Low)' :
                                    sort == 'created_at_new' ? 'Newest First' : 'Oldest First',
                                    style: TextStyle(fontFamily: 'Poppins'),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) => setState(() => _sortBy = value),
                              dropdownColor: Colors.white,
                              isExpanded: true,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ZoomIn(
                            duration: Duration(milliseconds: 300),
                            child: ElevatedButton(
                              onPressed: () => setState(() => _showFilter = false),
                              style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.all(Colors.grey),
                                shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                                padding: WidgetStateProperty.all(EdgeInsets.symmetric(vertical: 16)),
                                elevation: WidgetStateProperty.all(5),
                              ),
                              child: Text(
                                'Close',
                                style: TextStyle(color: Colors.white, fontFamily: 'Poppins', fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          ZoomIn(
                            duration: Duration(milliseconds: 300),
                            child: ElevatedButton(
                              onPressed: _applyFilters,
                              style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.all(Colors.purpleAccent),
                                shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                                padding: WidgetStateProperty.all(EdgeInsets.symmetric(vertical: 16)),
                                elevation: WidgetStateProperty.all(5),
                                shadowColor: WidgetStateProperty.all(Colors.purpleAccent.withAlpha(128)),
                              ),
                              child: Text(
                                'Apply Filters',
                                style: TextStyle(color: Colors.white, fontFamily: 'Poppins', fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
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
              Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: FloatingActionButton(
                        onPressed: () => setState(() => _showFilter = true),
                        backgroundColor: Colors.teal,
                        child: Icon(FontAwesomeIcons.filter, color: Colors.white),
                      ),
                    ),
                  ),
                  Expanded(
                    child: _isLoading
                        ? Center(child: CircularProgressIndicator(color: Colors.teal))
                        : jobs.isEmpty
                        ? Center(
                      child: Text(
                        'No jobs available',
                        style: TextStyle(
                          color: Colors.blueGrey[700],
                          fontFamily: 'Poppins',
                          fontSize: 18,
                        ),
                      ),
                    )
                        : ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.all(16.0),
                      itemCount: jobs.length + (_hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == jobs.length) {
                          return Center(child: CircularProgressIndicator(color: Colors.teal));
                        }
                        final job = jobs[index];
                        return FadeInUp(
                          duration: Duration(milliseconds: 800),
                          delay: Duration(milliseconds: index * 200),
                          child: Card(
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                              side: BorderSide(color: Colors.teal.withOpacity(0.3), width: 1),
                            ),
                            color: Colors.white.withOpacity(0.95),
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _getJobIcon(job['required_skills']),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          job['job_title'] ?? 'No Title',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.teal,
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Category: ${job['job_category'] ?? 'N/A'}',
                                          style: TextStyle(
                                            color: Colors.blueGrey[600],
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                        Text(
                                          'Location: ${job['location'] ?? 'N/A'}',
                                          style: TextStyle(
                                            color: Colors.blueGrey[600],
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                        Text(
                                          'Salary: ${job['salary']?.toStringAsFixed(2) ?? 'N/A'} BDT',
                                          style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green,
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                        Text(
                                          'Skills: ${job['required_skills']?.join(', ') ?? 'N/A'}',
                                          style: TextStyle(
                                            color: Colors.blueGrey[600],
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                        Text(
                                          'Posted by: ${job['users']?['full_name'] ?? 'Unknown'}',
                                          style: TextStyle(
                                            color: Colors.blueGrey[600],
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                        Text(
                                          'Match: 85%',
                                          style: TextStyle(
                                            color: Colors.blueAccent,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      ZoomIn(
                                        duration: Duration(milliseconds: 300),
                                        child: ElevatedButton(
                                          onPressed: () {},
                                          style: ButtonStyle(
                                            backgroundColor: WidgetStateProperty.all(Colors.teal),
                                            shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                                            elevation: WidgetStateProperty.all(5),
                                            shadowColor: WidgetStateProperty.all(Colors.teal.withAlpha(128)),
                                          ),
                                          child: Text(
                                            'Apply Now',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontFamily: 'Poppins',
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      IconButton(
                                        icon: Icon(FontAwesomeIcons.bookmark, color: Colors.blueAccent),
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
              _buildFilterDialog(),
            ],
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