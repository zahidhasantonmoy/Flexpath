import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class JobPostScreen extends StatefulWidget {
  const JobPostScreen({super.key});

  @override
  State<JobPostScreen> createState() => _JobPostScreenState();
}

class _JobPostScreenState extends State<JobPostScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  String category = 'Tutoring';
  String location = '';
  String jobType = 'Full-time';
  String salary = '';
  String skills = '';
  String experienceLevel = 'Beginner';
  DateTime? deadline;
  String paymentMethod = 'Bkash';
  List<String> tags = [];
  final TextEditingController tagsController = TextEditingController();

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    tagsController.dispose();
    super.dispose();
  }

  Future<void> _postJob() async {
    if (_formKey.currentState!.validate()) {
      final jobData = {
        'title': titleController.text,
        'description': descriptionController.text,
        'category': category,
        'location': location,
        'job_type': jobType,
        'salary': salary,
        'required_skills': skills.split(','),
        'experience_level': experienceLevel,
        'deadline': deadline?.toIso8601String(),
        'payment_method': paymentMethod,
        'tags': tags,
        'posted_by': supabase.auth.currentUser?.id,
        'created_at': DateTime.now().toIso8601String(),
      };

      try {
        await supabase.from('jobs').insert([jobData]);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Job posted successfully!')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error posting job: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: const Text('Post a Job', style: TextStyle(color: Colors.white, fontFamily: 'Poppins')),
        backgroundColor: const Color(0xFF0F3460),
      ),
      body: Theme(
        data: ThemeData(
          colorScheme: ColorScheme.dark(
            primary: Colors.teal,
            secondary: Colors.purpleAccent,
          ),
          fontFamily: 'Poppins',
        ),
        child: Form(
          key: _formKey,
          child: Stepper(
            currentStep: _currentStep,
            onStepContinue: () {
              if (_currentStep < 4) setState(() => _currentStep += 1);
              else _postJob();
            },
            onStepCancel: _currentStep > 0 ? () => setState(() => _currentStep -= 1) : null,
            controlsBuilder: (context, details) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  if (_currentStep > 0)
                    ElevatedButton(
                      onPressed: details.onStepCancel,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.purpleAccent),
                      child: const Text('Back'),
                    ),
                  ElevatedButton(
                    onPressed: details.onStepContinue,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                    child: Text(_currentStep == 4 ? 'Submit' : 'Next'),
                  ),
                ],
              );
            },
            steps: [
              Step(
                title: const Text('Job Title', style: TextStyle(color: Colors.white)),
                content: TextFormField(
                  controller: titleController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Enter Job Title',
                    labelStyle: TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                  ),
                  validator: (value) => value!.isEmpty ? 'Title is required' : null,
                ),
                isActive: _currentStep >= 0,
                state: _currentStep >= 0 ? StepState.complete : StepState.disabled,
              ),
              Step(
                title: const Text('Description', style: TextStyle(color: Colors.white)),
                content: TextFormField(
                  controller: descriptionController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Enter Job Description',
                    labelStyle: TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                  ),
                  maxLines: 5,
                  validator: (value) => value!.isEmpty ? 'Description is required' : null,
                ),
                isActive: _currentStep >= 1,
                state: _currentStep >= 1 ? StepState.complete : StepState.disabled,
              ),
              Step(
                title: const Text('Details', style: TextStyle(color: Colors.white)),
                content: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: category,
                      items: ['Tutoring', 'Delivery', 'Freelance']
                          .map((label) => DropdownMenuItem(
                        value: label,
                        child: Text(label, style: const TextStyle(color: Colors.white)),
                      ))
                          .toList(),
                      onChanged: (value) => setState(() => category = value!),
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        labelStyle: TextStyle(color: Colors.white70),
                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      onChanged: (value) => location = value,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Location',
                        labelStyle: TextStyle(color: Colors.white70),
                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                      ),
                      validator: (value) => value!.isEmpty ? 'Location is required' : null,
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: jobType,
                      items: ['Full-time', 'Part-time', 'Temporary']
                          .map((label) => DropdownMenuItem(
                        value: label,
                        child: Text(label, style: const TextStyle(color: Colors.white)),
                      ))
                          .toList(),
                      onChanged: (value) => setState(() => jobType = value!),
                      decoration: const InputDecoration(
                        labelText: 'Job Type',
                        labelStyle: TextStyle(color: Colors.white70),
                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      onChanged: (value) => salary = value,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Salary (e.g., \$500/month)',  // Fixed $ symbol
                        labelStyle: TextStyle(color: Colors.white70),
                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                      ),
                      validator: (value) => value!.isEmpty ? 'Salary is required' : null,
                    ),
                  ],
                ),
                isActive: _currentStep >= 2,
                state: _currentStep >= 2 ? StepState.complete : StepState.disabled,
              ),
              Step(
                title: const Text('Requirements', style: TextStyle(color: Colors.white)),
                content: Column(
                  children: [
                    TextFormField(
                      onChanged: (value) => skills = value,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Required Skills (comma-separated)',
                        labelStyle: TextStyle(color: Colors.white70),
                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: experienceLevel,
                      items: ['Beginner', 'Intermediate', 'Expert']
                          .map((label) => DropdownMenuItem(
                        value: label,
                        child: Text(label, style: const TextStyle(color: Colors.white)),
                      ))
                          .toList(),
                      onChanged: (value) => setState(() => experienceLevel = value!),
                      decoration: const InputDecoration(
                        labelText: 'Experience Level',
                        labelStyle: TextStyle(color: Colors.white70),
                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      onChanged: (value) => tags = value.split(','),
                      controller: tagsController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Tags (comma-separated, e.g., remote, urgent)',
                        labelStyle: TextStyle(color: Colors.white70),
                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ListTile(
                      title: const Text('Deadline', style: TextStyle(color: Colors.white)),
                      subtitle: Text(
                        deadline == null ? 'Not set' : deadline!.toIso8601String().split('T')[0],
                        style: const TextStyle(color: Colors.white70),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.calendar_today, color: Colors.teal),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) setState(() => deadline = picked);
                        },
                      ),
                    ),
                  ],
                ),
                isActive: _currentStep >= 3,
                state: _currentStep >= 3 ? StepState.complete : StepState.disabled,
              ),
              Step(
                title: const Text('Finalize', style: TextStyle(color: Colors.white)),
                content: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: paymentMethod,
                      items: ['Bkash', 'Bank Transfer']
                          .map((label) => DropdownMenuItem(
                        value: label,
                        child: Text(label, style: const TextStyle(color: Colors.white)),
                      ))
                          .toList(),
                      onChanged: (value) => setState(() => paymentMethod = value!),
                      decoration: const InputDecoration(
                        labelText: 'Payment Method',
                        labelStyle: TextStyle(color: Colors.white70),
                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('Review your job post and submit.', style: TextStyle(color: Colors.white70)),
                  ],
                ),
                isActive: _currentStep >= 4,
                state: _currentStep >= 4 ? StepState.complete : StepState.disabled,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
