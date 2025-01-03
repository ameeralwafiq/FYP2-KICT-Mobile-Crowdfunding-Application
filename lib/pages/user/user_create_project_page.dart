import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'package:kict_crowdfunding/pages/user/user_homepage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserCreateProjectPage extends StatefulWidget {
  const UserCreateProjectPage({super.key});

  @override
  UserCreateProjectPageState createState() => UserCreateProjectPageState();
}

class UserCreateProjectPageState extends State<UserCreateProjectPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _goalController = TextEditingController();
  final TextEditingController _bankController = TextEditingController();
  final TextEditingController _accountNoController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final List<String> _categories = ['Education', 'Personal', 'Food'];
  String? _selectedCategory;

  bool _termsAgreed = false;
  String? _imageUrl;

  bool _isUploadingImage = false;
  bool _isSubmitting = false;

  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _uploadImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile =
          await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) return; // User cancelled picking image

      setState(() {
        _isUploadingImage = true;
      });

      // Create a unique file name based on timestamp
      String fileName = '${DateTime.now().millisecondsSinceEpoch}.png';

      File file = File(pickedFile.path);

      // Upload to Supabase Storage

      final uploadedPath = await Supabase.instance.client.storage
          .from('images')
          .upload(fileName, file);

      // If we reach here, upload is successful
      final publicURL = Supabase.instance.client.storage
          .from('images')
          .getPublicUrl(fileName);

      setState(() {
        _imageUrl = publicURL;
      });
    } catch (e) {
      print("Error uploading image: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error uploading image')),
      );
    } finally {
      setState(() {
        _isUploadingImage = false;
      });
    }
  }

  Future<void> _onSubmit() async {
    if (_titleController.text.isEmpty ||
        _selectedCategory == null ||
        _goalController.text.isEmpty ||
        _bankController.text.isEmpty ||
        _accountNoController.text.isEmpty ||
        _durationController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _imageUrl == null ||
        !_termsAgreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please fill in all fields and agree to the terms.')),
      );
      return;
    }

    final goal = double.tryParse(_goalController.text);
    if (goal == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid goal amount')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final user = _auth.currentUser;
      if (user == null) {
        // User not logged in
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not logged in.')),
        );
        return;
      }
      // Fetch all current project IDs
      final projectsSnapshot = await _databaseRef.child('projects').get();
      int nextId = 1;

      if (projectsSnapshot.exists) {
        final projectKeys =
            projectsSnapshot.children.map((e) => e.key).toList();
        // Calculate next sequential ID
        nextId = projectKeys.length + 1;
      }

      // Format the ID as 3 digits (e.g., 001, 002, etc.)
      final projectId = nextId.toString().padLeft(3, '0');

      final createdBy = user.uid;
      final now = DateTime.now();
      final createdAt = now.toIso8601String();
      final DateFormat formatter = DateFormat('d/M/yyyy');
      final String startDate = formatter.format(now);

      // Calculate endDate from duration in days
      final int durationDays = int.tryParse(_durationController.text) ??
          30; // default to 30 if parsing fails
      final DateTime endDateTime = now.add(Duration(days: durationDays));
      final String endDate = formatter.format(endDateTime);

      // Default values
      const clicked = 0;
      const shared = 0;
      const progress = 0;
      const status = "pending";

      // Prepare project data
      final projectData = {
        'title': _titleController.text.trim(),
        'category': _selectedCategory,
        'goal': goal,
        'bank': _bankController.text.trim(),
        'accountNo': _accountNoController.text.trim(),
        'description': _descriptionController.text.trim(),
        'imageUrl': _imageUrl,
        'createdBy': createdBy,
        'createdAt': createdAt,
        'startDate': startDate,
        'endDate': endDate,
        'clicked': clicked,
        'progress': progress,
        'status': status,
        'shared': shared
      };

      // Save the project with the custom ID
      await _databaseRef.child('projects').child(projectId).set(projectData);

      // Navigate to ProjectSubmittedPage
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProjectSubmittedPage()),
      );
    } catch (e) {
      print("Error creating project: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating project: $e')),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFFC0FCC2),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Create Project',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 34),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '*Upload your project\'s image',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 10),
              Center(
                child: GestureDetector(
                  onTap: _isUploadingImage ? null : _uploadImage,
                  child: Container(
                    height: 180,
                    width: MediaQuery.sizeOf(context).width * 0.85,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8.0),
                      image: _imageUrl != null
                          ? DecorationImage(
                              image: NetworkImage(_imageUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _imageUrl == null
                        ? _isUploadingImage
                            ? const Center(
                                child: CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation(Colors.black),
                              ))
                            : Icon(
                                Icons.add_a_photo,
                                size: 50,
                                color: Colors.grey[700],
                              )
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _titleController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Project Title',
                  labelStyle:
                      const TextStyle(fontSize: 16, color: Colors.white),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                dropdownColor: Colors.black,
                value: _selectedCategory,
                items: _categories
                    .map((cat) => DropdownMenuItem(
                          value: cat,
                          child: Text(
                            cat,
                            style: const TextStyle(color: Colors.greenAccent),
                          ),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Category',
                  labelStyle:
                      const TextStyle(fontSize: 16, color: Colors.white),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.greenAccent),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.greenAccent, width: 2),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _bankController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Bank Name',
                  labelStyle:
                      const TextStyle(fontSize: 16, color: Colors.white),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                keyboardType: TextInputType.number,
                controller: _accountNoController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Account Number',
                  labelStyle:
                      const TextStyle(fontSize: 16, color: Colors.white),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _goalController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Your target (Goal)',
                  labelStyle:
                      const TextStyle(fontSize: 16, color: Colors.white),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _durationController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Duration in days (max 90 for 3 months)',
                  labelStyle:
                      const TextStyle(fontSize: 16, color: Colors.white),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _descriptionController,
                maxLines: 4,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Project description',
                  labelStyle:
                      const TextStyle(fontSize: 16, color: Colors.white),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Checkbox(
                    value: _termsAgreed,
                    activeColor: Colors.green,
                    onChanged: (bool? value) {
                      setState(() {
                        _termsAgreed = value ?? false;
                      });
                    },
                  ),
                  Expanded(
                    child: RichText(
                      text: const TextSpan(
                        text: 'I agree to the ',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                        children: [
                          TextSpan(
                            text: 'terms and conditions',
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              color: Colors.green,
                            ),
                          ),
                          TextSpan(
                            text: ' as set out by the user agreement',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Center(
                child: GestureDetector(
                  onTap: _isSubmitting ? null : _onSubmit,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: _isSubmitting ? Colors.grey : Colors.green[300],
                      shape: BoxShape.circle,
                    ),
                    child: _isSubmitting
                        ? const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(Colors.black),
                            ),
                          )
                        : const Icon(
                            Icons.add,
                            size: 40,
                            color: Colors.white,
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
}

class ProjectSubmittedPage extends StatelessWidget {
  const ProjectSubmittedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFFC0FCC2),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Create Project',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Your project has successfully been submitted !',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                '✅',
                style: TextStyle(fontSize: 16, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const Text(
                'Thank you for using KICT Mobile Crowdfunding !',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const UserHomePage()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC0FCC2),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text(
                  'Home',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
