import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class JobFeedScreen extends StatefulWidget {
  @override
  _JobFeedScreenState createState() => _JobFeedScreenState();
}

class _JobFeedScreenState extends State<JobFeedScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> jobs = [];

  @override
  void initState() {
    super.initState();
    _fetchJobs();
  }

  // Fetch jobs from Supabase
  Future<void> _fetchJobs() async {
    final response = await supabase.from('jobs').select().execute();

    if (response.error == null) {
      setState(() {
        jobs = List<Map<String, dynamic>>.from(response.data);
      });
    } else {
      print('Error fetching jobs: ${response.error!.message}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: Text(
          'Job Feed',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: jobs.isEmpty
          ? Center(child: CircularProgressIndicator()) // Show loading indicator
          : ListView.builder(
        itemCount: jobs.length,
        itemBuilder: (context, index) {
          final job = jobs[index];
          return Card(
            elevation: 5,
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            color: Colors.white,
            child: ListTile(
              contentPadding: EdgeInsets.all(16),
              title: Text(
                job['title'],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.blueAccent,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 4),
                  Text(
                    'Location: ${job['location']}',
                    style: TextStyle(color: Colors.black54),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Compensation: ${job['compensation']}',
                    style: TextStyle(color: Colors.black54),
                  ),
                ],
              ),
              trailing: Icon(Icons.arrow_forward_ios, color: Colors.blueAccent),
              onTap: () {
                // Handle job details view (navigate to another page or show details)
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Handle adding new job (navigate to job creation page)
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }
}
