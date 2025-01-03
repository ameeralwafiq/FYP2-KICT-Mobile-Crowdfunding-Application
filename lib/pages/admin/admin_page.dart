import 'package:flutter/material.dart';
import 'package:kict_crowdfunding/pages/admin/admin_project_list_donation_page.dart';
import 'package:kict_crowdfunding/pages/admin/admin_project_list_to_approve.dart';
import 'package:kict_crowdfunding/pages/admin/admin_user_list_page.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Admin Page',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: const Color(0xFFC0FCFC),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(50.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              IntrinsicWidth(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildButton(context, 'List of Projects', () {
                      // Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const AdminProjectsListToApprovePage()));
                    }),
                    const SizedBox(height: 30),
                    _buildButton(context, 'List of Users', () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AdminUserListPage()));
                    }),
                    const SizedBox(height: 30),
                    _buildButton(context, 'List of Donation', () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const AdminProjectsListDonationPage()));
                    }),
                  ],
                ),
              ),
              const Spacer(),
              _buildButton(context, 'Home', () {
                Navigator.pop(context);
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(
      BuildContext context, String label, void Function()? onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFC0FCFC),
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        fixedSize:
            const Size.fromWidth(200), // All buttons will have the same width.
      ),
      child: Text(label),
    );
  }
}
