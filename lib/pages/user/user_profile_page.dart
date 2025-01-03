import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  UserProfilePageState createState() => UserProfilePageState();
}

class UserProfilePageState extends State<UserProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  String username = "Name";
  int fundraised = 0;
  int rewards = 0;
  int bookmarks = 0;

  @override
  void initState() {
    super.initState();
    _fetchUsername();
  }

  void _fetchUsername() async {
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        final DataSnapshot snapshot =
            await _dbRef.child('users/${user.uid}').get();

        if (snapshot.value != null) {
          final data = Map<String, dynamic>.from(snapshot.value as Map);
          setState(() {
            username = data['username'] ??
                "Guest"; // Use 'fullName' or default to 'Guest'
          });
        }
      }
    } catch (e) {
      print("Error fetching username: $e");
      setState(() {
        username = "Guest"; // Fallback in case of error
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
          "Profile",
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            height: 100,
          ),
          CircleAvatar(
            radius: MediaQuery.sizeOf(context).height * 0.1,
            backgroundColor: const Color(0xFFC0FCC2),
            child: Icon(
              Icons.person,
              size: MediaQuery.sizeOf(context).height * 0.15,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            username,
            style: const TextStyle(
              color: Color(0xFFC0FCC2),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ProfileStat(label: "Fundraised", value: fundraised.toString()),
              const SizedBox(width: 50),
              _ProfileStat(label: "Rewards", value: rewards.toString()),
              const SizedBox(width: 50),
              _ProfileStat(label: "Bookmarks", value: bookmarks.toString()),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
