import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class UserNotificationPage extends StatefulWidget {
  const UserNotificationPage({super.key});

  @override
  UserNotificationPageState createState() => UserNotificationPageState();
}

class UserNotificationPageState extends State<UserNotificationPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _notificationRef =
      FirebaseDatabase.instance.ref().child('notifications');
  List<Map<String, dynamic>> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  void _fetchNotifications() async {
    try {
      // Get the current user's ID
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception("User not logged in.");
      }

      final String userId = currentUser.uid;

      // Listen to notifications for the logged-in user
      _notificationRef
          .orderByChild('userId')
          .equalTo(userId)
          .onValue
          .listen((event) {
        if (event.snapshot.value != null) {
          final data = Map<String, dynamic>.from(
              event.snapshot.value as Map<dynamic, dynamic>);
          final fetchedNotifications = data.entries.map((entry) {
            final notificationData = Map<String, dynamic>.from(entry.value);
            return {
              'id': entry.key,
              ...notificationData,
            };
          }).toList();

          // Sort notifications by timestamp in descending order
          final dateFormat = DateFormat('yyyy-MM-dd hh:mm a');
          fetchedNotifications.sort((a, b) {
            final aTimestamp = dateFormat.parse(a['timestamp']);
            final bTimestamp = dateFormat.parse(b['timestamp']);
            return bTimestamp.compareTo(aTimestamp); // Descending order
          });

          setState(() {
            notifications = fetchedNotifications;
            isLoading = false;
          });
        } else {
          setState(() {
            notifications = [];
            isLoading = false;
          });
        }
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error fetching notifications: $e");
    }
  }

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
          "Notifications",
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
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF34A853),
              ),
            )
          : notifications.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_none,
                        size: 200,
                        color: Color(0xFF34A853),
                      ),
                      SizedBox(height: 20),
                      Text(
                        "No Notifications",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "All notifications will appear here",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notification['title'] ?? 'No Title',
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            notification['message'] ?? 'No Message',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            notification['timestamp'] ?? 'Unknown Time',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
