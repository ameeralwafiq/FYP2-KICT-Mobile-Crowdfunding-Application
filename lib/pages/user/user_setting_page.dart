import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kict_crowdfunding/pages/choose_role_page.dart';

class UserSettingPage extends StatelessWidget {
  const UserSettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Settings",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            
            
            children: [
              const Center(child: SettingSectionTitle(title: "Language")),
              SettingButton(label: "English", onPressed: () {}),
              SettingButton(label: "Bahasa Melayu", onPressed: () {}),
              const SizedBox(height: 20),
              const Center(child: SettingSectionTitle(title: "Notification")),
              SettingButton(label: "Always On", onPressed: () {}),
              SettingButton(label: "Mute", onPressed: () {}),
              const SizedBox(height: 20),
              const Center(child: SettingSectionTitle(title: "Contact Us")),
              SettingButton(label: " 📧   support@gmail.com ", onPressed: () {}),
              SettingButton(label: " 📞   + 603 - 5555 7474 ", onPressed: () {}),
              const SizedBox(height: 20),
              const Center(child: SettingSectionTitle(title: "Account")),
              
              
              // Logout Button - to go to 'Choose Role' page
              SettingButton(
                  label: "Logout",
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ChooseRolePage()),
                      (route) => false,
                    );
                  }),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingSectionTitle extends StatelessWidget {
  final String title;

  const SettingSectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 30,
        ),
      ),
    );
  }
}

class SettingButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const SettingButton(
      {super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          alignment: Alignment.center,
          height: 50,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFC2F8CE), width: 2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFFC2F8CE),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
