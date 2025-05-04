import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:animations/animations.dart'; // For smooth transitions
import 'job_post_screen.dart'; // New screen for posting jobs

class JobFeedScreen extends StatefulWidget {
  const JobFeedScreen({super.key});

  @override
  State<JobFeedScreen> createState() => _JobFeedScreenState();
}

class _JobFeedScreenState extends State<JobFeedScreen> with SingleTickerProviderStateMixin {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> jobs = [];
  String selectedCategory = 'All';
  final List<String> categories = ['All', 'Tutoring', 'Delivery', 'Freelance'];

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _fetchJobs();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _fetchJobs() async {
    try {
      final response = await supabase.from('jobs').select();
      setState(() {
        jobs = List<Map<String, dynamic>>.from(response);
        _controller.forward(from: 0); // Trigger fade animation
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching jobs: $e')),
        );
      }
    }
  }

  List<Map<String, dynamic>> getFilteredJobs() {
    if (selectedCategory == 'All') return jobs;
    return jobs.where((job) => job['category'] == selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E), // Dark theme background
      appBar: AppBar(
        title: const Text(
          'Job Feed',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
            fontFamily: 'Poppins', // Modern font
          ),
        ),
        backgroundColor: const Color(0xFF0F3460), // Deep blue
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: const Color(0xFF1A1A2E),
                  title: const Text('Filter Jobs', style: TextStyle(color: Colors.white)),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: categories.map((category) {
                        return RadioListTile<String>(
                          title: Text(category, style: const TextStyle(color: Colors.white)),
                          value: category,
                          groupValue: selectedCategory,
                          activeColor: Colors.teal,
                          onChanged: (value) {
                            setState(() => selectedCategory = value!);
                            Navigator.pop(context);
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: getFilteredJobs().length,
          itemBuilder: (context, index) {
            final job = getFilteredJobs()[index];
            return OpenContainer(
              transitionType: ContainerTransitionType.fade,
              openBuilder: (context, action) => JobDetailScreen(job: job),
              closedBuilder: (context, action) => Card(
                elevation: 8,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                color: const Color(0xFF16213E), // Dark card background
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: const CircleAvatar(
                    backgroundColor: Colors.teal,
                    child: Icon(Icons.work, color: Colors.white),
                  ),
                  title: Text(
                    job['title'] ?? 'No Title',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.teal, // Neon accent
                      fontFamily: 'Poppins',
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        'Location: ${job['location'] ?? 'N/A'}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Salary: ${job['salary'] ?? 'N/A'}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Type: ${job['job_type'] ?? 'N/A'}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                  trailing: ElevatedButton(
                    onPressed: () => action(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Apply', style: TextStyle(color: Colors.black)),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const JobPostScreen()));
        },
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add, color: Colors.white),
        elevation: 8,
      ),
    );
  }
}

// Placeholder for Job Detail Screen
class JobDetailScreen extends StatelessWidget {
  final Map<String, dynamic> job;

  const JobDetailScreen({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: Text(job['title'] ?? 'Job Details', style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0F3460),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Description: ${job['description'] ?? 'No description'}', style: const TextStyle(color: Colors.white)),
            Text('Location: ${job['location'] ?? 'N/A'}', style: const TextStyle(color: Colors.white70)),
            Text('Salary: ${job['salary'] ?? 'N/A'}', style: const TextStyle(color: Colors.white70)),
            Text('Type: ${job['job_type'] ?? 'N/A'}', style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent),
              child: const Text('Apply Now', style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
}