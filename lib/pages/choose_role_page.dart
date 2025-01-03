import 'package:flutter/material.dart';
import 'package:kict_crowdfunding/pages/admin/admin_login_page.dart';
import 'package:kict_crowdfunding/pages/user/user_login_page.dart';

class ChooseRolePage extends StatelessWidget {
  const ChooseRolePage({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.sizeOf(context).width;

    return Scaffold(
      backgroundColor:
          Colors.black, // Match the black background of your design
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display the logo
            Image.asset(
              'assets/images/logochooserole.png', // Update to your actual image path
              width: screenWidth * 0.8, // Adjust size relative to screen width
            ),
            const SizedBox(height: 50), // Add spacing between logo and buttons
            // User Button
            ElevatedButton(
              onPressed: () {
                // Navigate to User Page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const UserLoginPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent, // Button color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30), // Rounded corners
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
              ),
              child: const Text(
                'User',
                style: TextStyle(color: Colors.black, fontSize: 18),
              ),
            ),
            const SizedBox(height: 20), // Add spacing between buttons
            // Admin Button
            ElevatedButton(
              onPressed: () {
                // Navigate to Admin Page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AdminLoginPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent, // Button color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30), // Rounded corners
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
              ),
              child: const Text(
                'Admin',
                style: TextStyle(color: Colors.black, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
