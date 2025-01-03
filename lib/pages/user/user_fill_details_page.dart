import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:kict_crowdfunding/pages/user/user_homepage.dart';

class UserFillDetailsPage extends StatefulWidget {
  const UserFillDetailsPage({super.key});

  @override
  UserFillDetailsPageState createState() => UserFillDetailsPageState();
}

class UserFillDetailsPageState extends State<UserFillDetailsPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  String? _selectedStatus;
  String? _selectedDepartment;

  final List<String> _statusOptions = [
    'UnderGraduate', 
    'PostGraduate',
    'Staff',
    'Alumni',
    'Other',
    ];
    
  final List<String> _departmentOptions = [
    'Information System',
    'Computer Science',
    'Other',
  ];

  bool _isSaving = false;

  Future<void> _onContinue() async {
    // Validate fields
    if (_nameController.text.isEmpty ||
        _idController.text.isEmpty ||
        _selectedStatus == null ||
        _selectedDepartment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Get the current logged-in user
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not logged in.')),
        );
        return;
      }

      final userId = user.uid;

      // Create a reference to the user's data in the Realtime Database
      final DatabaseReference userRef =
          FirebaseDatabase.instance.ref('users/$userId');

      // Save the user details
      await userRef.update({
        'username': _nameController.text.trim(),
        'studentId': _idController.text.trim(),
        'department': _selectedDepartment,
        'status': _selectedStatus,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Details saved successfully.')),
      );

      // Navigate to UserHomePage and remove this page from the route stack
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const UserHomePage()),
        (route) => false,
      );
    } catch (e) {
      print('Error saving details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving details: $e')),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 80),
                  const Text(
                    'Details :',
                    style: TextStyle(
                      color: Colors.greenAccent,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  
                  
                  // Name TextField
                  TextField(
                    controller: _nameController,
                    style: const TextStyle(color: Colors.white),
                    
                    decoration: InputDecoration(
                      labelText: 'Username',
                      labelStyle: const TextStyle(color: Colors.greenAccent),
                      
                      // Add hint text
                      hintText: '(Enter your username)',
                      hintStyle: const TextStyle(color: Color.fromARGB(255, 90, 102, 96)),
                      
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.greenAccent),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: Colors.greenAccent, width: 2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  
                  
                  
                  
                  
                  // Student/Staff ID TextField
                  TextField(
                    controller: _idController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Student/Staff ID',
                      labelStyle: const TextStyle(color: Colors.greenAccent),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.greenAccent),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: Colors.greenAccent, width: 2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  
                  
                  
                  
                  
                  // Status Dropdown
                  DropdownButtonFormField<String>(
                    dropdownColor: Colors.black,
                    value: _selectedStatus,
                    items: _statusOptions
                        .map((status) => DropdownMenuItem(
                              value: status,
                              child: Text(
                                status,
                                style:
                                    const TextStyle(color: Colors.greenAccent),
                              ),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Status',
                      labelStyle: const TextStyle(color: Colors.greenAccent),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.greenAccent),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: Colors.greenAccent, width: 2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  
                  
                  
                  
                  
                  // Department Dropdown
                  DropdownButtonFormField<String>(
                    dropdownColor: Colors.black,
                    value: _selectedDepartment,
                    items: _departmentOptions
                        .map((department) => DropdownMenuItem(
                              value: department,
                              child: Text(
                                department,
                                style:
                                    const TextStyle(color: Colors.greenAccent),
                              ),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedDepartment = value;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Department',
                      labelStyle: const TextStyle(color: Colors.greenAccent),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.greenAccent),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: Colors.greenAccent, width: 2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  
                  
                  
                  
                  
                  
                  // Continue Button
                  Center(
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _onContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 100, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.black),
                              ),
                            )
                          : const Text(
                              'Continue',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 18),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
