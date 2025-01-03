import 'package:flutter/material.dart';
import 'package:kict_crowdfunding/pages/choose_role_page.dart';

class AdminSettingPage extends StatelessWidget {
  const AdminSettingPage({super.key});

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
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Center(child: SettingSectionTitle(title: "Language")),
              SettingButton(label: "English", onPressed: () {}),
              SettingButton(label: "Bahasa Melayu", onPressed: () {}),
              const SizedBox(height: 20),
              const Center(child: SettingSectionTitle(title: "Notification")),
              SettingButton(label: "Always On", onPressed: () {}),
              SettingButton(label: "Mute", onPressed: () {}),
              const SizedBox(height: 20),
              const Center(child: SettingSectionTitle(title: "Account")),
              SettingButton(
                  label: "Logout",
                  onPressed: () async {
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
            border: Border.all(color: const Color(0xFFC0FCFC), width: 2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFFC0FCFC),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
