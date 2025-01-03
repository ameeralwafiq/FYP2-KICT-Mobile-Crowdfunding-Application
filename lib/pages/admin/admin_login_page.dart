import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:kict_crowdfunding/pages/admin/admin_homepage.dart';
import 'package:kict_crowdfunding/pages/admin/admin_password_reset_page.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  AdminLoginPageState createState() => AdminLoginPageState();
}

class AdminLoginPageState extends State<AdminLoginPage> {
  final TextEditingController _adminIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref('admins');

  bool _isLoading = false;
  String _errorMessage = '';

  void _loginAdmin() async {
    await FirebaseAuth.instance.signOut();
    final adminId = _adminIdController.text.trim();
    final password = _passwordController.text.trim();

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Fetch the admin credentials from the database
      final snapshot = await _dbRef.get();
      if (snapshot.exists) {
        Map<dynamic, dynamic> admins = snapshot.value as Map<dynamic, dynamic>;

        bool loginSuccess = admins.entries.any((entry) {
          return entry.value['adminID'] == adminId &&
              entry.value['password'] == password;
        });

        if (loginSuccess) {
          // Navigate to the admin dashboard or desired page
          print('Login successful');
          if (!mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AdminHomePage()),
          );
        } else {
          setState(() {
            _errorMessage = 'Invalid Admin ID or Password';
          });
        }
      }
    } catch (error) {
      setState(() {
        _errorMessage = 'Error: $error';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _adminIdController.text = "admin";
    _passwordController.text = "admin";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Admin Login',
              style: TextStyle(
                color: Color(0xFFC0FCFC),
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            TextField(
              controller: _adminIdController,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration('Admin ID'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration('Password'),
            ),
            const SizedBox(height: 20),
            if (_errorMessage.isNotEmpty)
              Center(
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            const SizedBox(height: 20),
            Center(
              child: _isLoading
                  ? const CircularProgressIndicator(color: Color(0xFFC0FCFC))
                  : ElevatedButton(
                      onPressed: _loginAdmin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC0FCFC),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 100, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(color: Colors.black, fontSize: 18),
                      ),
                    ),
            ),
            const SizedBox(height: 20),
            Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AdminPasswordResetPage()),
                  );
                },
                child: const Text(
                  'Forgot password?',
                  style: TextStyle(
                    color: Color(0xFFC0FCFC),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFFC0FCFC)),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFFC0FCFC)),
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFFC0FCFC), width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
