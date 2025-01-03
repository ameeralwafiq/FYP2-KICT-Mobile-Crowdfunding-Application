import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:kict_crowdfunding/pages/user/user_fill_details_page.dart';

class UserRegisterPage extends StatefulWidget {
  const UserRegisterPage({super.key});

  @override
  UserRegisterPageState createState() => UserRegisterPageState();
}

class UserRegisterPageState extends State<UserRegisterPage> {
  final _auth = FirebaseAuth.instance;
  final _database = FirebaseDatabase.instance.ref();

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  Future<void> _registerUser() async {
    String fullName = _fullNameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (fullName.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Firebase Auth: Create User
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Generate the next userId based on the existing users
      DatabaseEvent event = await _database.child('users').once();
      Map<dynamic, dynamic>? users =
          event.snapshot.value as Map<dynamic, dynamic>?;

      int nextUserId = 1;
      if (users != null) {
        List<int> userIds = users.values
            .map((user) => user['userId']?.toString() ?? '')
            .where((userId) => userId.startsWith('user_'))
            .map(
                (userId) => int.tryParse(userId.replaceFirst('user_', '')) ?? 0)
            .toList();
        nextUserId =
            (userIds.isEmpty ? 1 : userIds.reduce((a, b) => a > b ? a : b) + 1);
      }

      String formattedUserId = 'user_${nextUserId.toString().padLeft(3, '0')}';

      // Store Full Name in Firebase Realtime Database
      await _database.child('users').child(userCredential.user!.uid).set({
        'fullName': fullName,
        'email': email,
        'password': password,
        'userId': formattedUserId,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration successful!')),
      );

      // Navigate to another page or clear the form
      _fullNameController.clear();
      _emailController.clear();
      _passwordController.clear();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const UserFillDetailsPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
            
            
            // Register title
            const Text(
              'Register',
              style: TextStyle(
                color: Colors.greenAccent,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40), // Add spacing
            
            
            
            // Full Name TextField
            TextField(
              controller: _fullNameController,
              style: const TextStyle(color: Colors.white),
             
             
             decoration: InputDecoration(
                labelText: 'Full Name',
                labelStyle: const TextStyle(color: Colors.greenAccent),
                
                
                // Add hint text
                hintText: '(Enter your full name in capital letters)',
                hintStyle: const TextStyle(color: Color.fromARGB(255, 68, 81, 75)),


                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.greenAccent),
                  borderRadius: BorderRadius.circular(10),
                ),
                
                
                focusedBorder: OutlineInputBorder(
                  borderSide:
                      const BorderSide(color: Colors.greenAccent, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20), // Add spacing
            
            
            
            
            
            
            // Email TextField
            TextField(
              controller: _emailController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: const TextStyle(color: Colors.greenAccent),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.greenAccent),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide:
                      const BorderSide(color: Colors.greenAccent, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20), // Add spacing
            // Password TextField
            TextField(
              controller: _passwordController,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: const TextStyle(color: Colors.greenAccent),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.greenAccent),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide:
                      const BorderSide(color: Colors.greenAccent, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 30), // Add spacing
            // Continue Button
            Center(
              child: ElevatedButton(
                onPressed: _isLoading ? null : _registerUser,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text(
                        'Continue',
                        style: TextStyle(color: Colors.black, fontSize: 18),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
