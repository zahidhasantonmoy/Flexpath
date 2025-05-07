import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:animate_do/animate_do.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'global_menu.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  bool _isLoading = false;
  String? _userType;
  String? _userId;
  String? _userFullName;
  Map<String, dynamic> _analyticsData = {};

  @override
  void initState() {
    super.initState();
    _fetchUserDataAndAnalytics();
  }

  Future<void> _fetchUserDataAndAnalytics() async {
    setState(() => _isLoading = true);
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');
      _userId = user.id;

      // Fetch user data
      final userDataResponse = await supabase
          .from('users')
          .select('user_type, full_name, job_completed, global_rating')
          .eq('id', _userId!)
          .maybeSingle();

      if (userDataResponse == null) {
        throw Exception('User data not found');
      }

      _userType = userDataResponse['user_type'];
      _userFullName = userDataResponse['full_name'] ?? 'User';

      // Fetch analytics data
      if (_userType == 'Employer') {
        final jobsPosted = await supabase
            .from('jobs')
            .select('id, job_category')
            .eq('employer_id', _userId!)
            .eq('status', 'open');
        final applications = await supabase
            .from('job_applications')
            .select('id, payment_status')
            .eq('employer_id', _userId!);
        final totalSpent = await supabase
            .from('job_applications')
            .select('jobs!inner(salary)')
            .eq('employer_id', _userId!)
            .eq('payment_status', 'completed');

        _analyticsData = {
          'jobs_posted': jobsPosted.length,
          'applications_received': applications.length,
          'total_spent': totalSpent.fold<double>(
              0, (sum, item) => sum + (item['jobs']['salary'] as num).toDouble()),
          'job_categories': _aggregateJobCategories(jobsPosted),
        };
      } else if (_userType == 'Job Seeker') {
        final jobsApplied = await supabase
            .from('job_applications')
            .select('id, application_status, jobs!inner(job_category)')
            .eq('worker_id', _userId!);
        final earnings = await supabase
            .from('job_applications')
            .select('jobs!inner(salary)')
            .eq('worker_id', _userId!)
            .eq('payment_status', 'completed');

        _analyticsData = {
          'jobs_applied': jobsApplied.length,
          'jobs_completed': userDataResponse['job_completed'] ?? 0,
          'total_earnings': earnings.fold<double>(
              0, (sum, item) => sum + (item['jobs']['salary'] as num).toDouble()),
          'application_success_rate': _calculateSuccessRate(jobsApplied),
          'job_categories': _aggregateJobCategories(jobsApplied),
          'global_rating': userDataResponse['global_rating']?.toDouble() ?? 0.0,
        };
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching data: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Map<String, int> _aggregateJobCategories(List<dynamic> jobs) {
    final categories = <String, int>{};
    for (var job in jobs) {
      final category = job['job_category'] ?? job['jobs']['job_category'] ?? 'Other';
      categories[category] = (categories[category] ?? 0) + 1;
    }
    return categories;
  }

  double _calculateSuccessRate(List<dynamic> applications) {
    if (applications.isEmpty) return 0.0;
    final accepted = applications
        .where((app) => app['application_status'] == 'accepted')
        .length;
    return (accepted / applications.length * 100).toDouble();
  }

  void _navigateToScreen(String route) {
    Navigator.pushNamed(context, route);
  }

  Future<void> _logout() async {
    await supabase.auth.signOut();
    Navigator.pushNamedAndRemoveUntil(context, '/homepage', (route) => false);
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color gradientStart,
    required Color gradientEnd,
  }) {
    return FadeInUp(
      duration: const Duration(milliseconds: 800),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: Colors.teal.withOpacity(0.3), width: 1),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [gradientStart, gradientEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              FaIcon(icon, color: Colors.white, size: 30),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPieChart(Map<String, int> categories) {
    final total = categories.values.fold(0, (sum, value) => sum + value);
    if (total == 0) return const SizedBox.shrink();

    final colors = [
      Colors.teal,
      Colors.purple,
      Colors.orange,
      Colors.lime,
      Colors.pink,
    ];
    final entries = categories.entries.toList();
    return FadeInUp(
      duration: const Duration(milliseconds: 1000),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          height: 200,
          child: PieChart(
            PieChartData(
              sections: List.generate(entries.length, (index) {
                final value = entries[index].value / total * 100;
                return PieChartSectionData(
                  color: colors[index % colors.length],
                  value: value,
                  title: '${entries[index].key}\n${value.toStringAsFixed(1)}%',
                  radius: 50,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Poppins',
                  ),
                );
              }),
              sectionsSpace: 2,
              centerSpaceRadius: 40,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBarChart(double earnings) {
    return FadeInUp(
      duration: const Duration(milliseconds: 1200),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          height: 200,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: earnings * 1.2,
              barGroups: [
                BarChartGroupData(
                  x: 0,
                  barRods: [
                    BarChartRodData(
                      toY: earnings,
                      gradient: const LinearGradient(
                        colors: [Colors.teal, Colors.lime],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                      width: 20,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ],
                ),
              ],
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) => Text(
                      '${value.toInt()} BDT',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontFamily: 'Poppins',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) => const Text(
                      'Total Earnings',
                      style: TextStyle(
                        color: Colors.white70,
                        fontFamily: 'Poppins',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
              gridData: FlGridData(show: false),
              borderData: FlBorderData(show: false),
            ),
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
            colors: [Colors.teal.shade100, Colors.purple.shade100],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.teal))
                  : LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FadeInDown(
                              duration: const Duration(milliseconds: 800),
                              child: Text(
                                'Welcome ${_userFullName ?? 'User'} to Your ${_userType == 'Employer' ? 'Employer' : 'Worker'} Dashboard',
                                style: TextStyle(
                                  fontSize: constraints.maxWidth > 600 ? 32 : 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueGrey[700],
                                  fontFamily: 'Poppins',
                                  shadows: [
                                    Shadow(
                                      blurRadius: 10,
                                      color: Colors.teal.withAlpha(77),
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 20),
                            if (_userType == 'Employer') ...[
                              _buildStatCard(
                                title: 'Jobs Posted',
                                value: '${_analyticsData['jobs_posted'] ?? 0}',
                                icon: FontAwesomeIcons.briefcase,
                                gradientStart: Colors.teal,
                                gradientEnd: Colors.lime,
                              ),
                              _buildStatCard(
                                title: 'Applications Received',
                                value: '${_analyticsData['applications_received'] ?? 0}',
                                icon: FontAwesomeIcons.users,
                                gradientStart: Colors.purple,
                                gradientEnd: Colors.pink,
                              ),
                              _buildStatCard(
                                title: 'Total Spent',
                                value: '${(_analyticsData['total_spent'] ?? 0).toStringAsFixed(2)} BDT',
                                icon: FontAwesomeIcons.wallet,
                                gradientStart: Colors.orange,
                                gradientEnd: Colors.yellow,
                              ),
                              const SizedBox(height: 20),
                              _buildPieChart(_analyticsData['job_categories'] ?? {}),
                            ] else if (_userType == 'Job Seeker') ...[
                              _buildStatCard(
                                title: 'Jobs Applied',
                                value: '${_analyticsData['jobs_applied'] ?? 0}',
                                icon: FontAwesomeIcons.briefcase,
                                gradientStart: Colors.teal,
                                gradientEnd: Colors.lime,
                              ),
                              _buildStatCard(
                                title: 'Jobs Completed',
                                value: '${_analyticsData['jobs_completed'] ?? 0}',
                                icon: FontAwesomeIcons.checkCircle,
                                gradientStart: Colors.purple,
                                gradientEnd: Colors.pink,
                              ),
                              _buildStatCard(
                                title: 'Success Rate',
                                value: '${(_analyticsData['application_success_rate'] ?? 0).toStringAsFixed(1)}%',
                                icon: FontAwesomeIcons.chartLine,
                                gradientStart: Colors.orange,
                                gradientEnd: Colors.yellow,
                              ),
                              _buildStatCard(
                                title: 'Global Rating',
                                value: '${(_analyticsData['global_rating'] ?? 0).toStringAsFixed(2)}',
                                icon: FontAwesomeIcons.star,
                                gradientStart: Colors.blue,
                                gradientEnd: Colors.cyan,
                              ),
                              const SizedBox(height: 20),
                              _buildBarChart(_analyticsData['total_earnings'] ?? 0),
                              const SizedBox(height: 20),
                              _buildPieChart(_analyticsData['job_categories'] ?? {}),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
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