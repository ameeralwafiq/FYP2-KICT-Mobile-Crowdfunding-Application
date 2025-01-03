import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class AdminUserDetailsPage extends StatefulWidget {
  final String userUid;

  const AdminUserDetailsPage({super.key, required this.userUid});

  @override
  AdminUserDetailsPageState createState() => AdminUserDetailsPageState();
}

class AdminUserDetailsPageState extends State<AdminUserDetailsPage> {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  late Future<Map<String, dynamic>?> _userFuture;
  bool? _isVerified; // Track verification status

  @override
  void initState() {
    super.initState();
    _userFuture = _fetchUserDetails();
  }

  Future<Map<String, dynamic>?> _fetchUserDetails() async {
    final snapshot = await _databaseRef.child('users/${widget.userUid}').get();
    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      _isVerified = data['verified'] == true;
      return data;
    }
    return null;
  }

  Future<void> _deleteUser() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirm Deletion"),
          content: const Text("Are you sure you want to delete this user?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false); // Return false if canceled
              },
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.black),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true); // Return true if confirmed
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text(
                "Delete",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        await _databaseRef.child('users/${widget.userUid}').remove();
        // After deletion, navigate back
        Navigator.pop(context);
      } catch (e) {
        print("Error deleting user: $e");
        // Handle error, for example by showing a Snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to delete user.")),
        );
      }
    }
  }

  Future<void> _verifyUser() async {
    try {
      await _databaseRef.child('users/${widget.userUid}').update({
        'verified': true,
      });
      setState(() {
        _isVerified = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User verified successfully.")),
      );
    } catch (e) {
      print("Error verifying user: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to verify user.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFFC0FCFC),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "User List",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Still loading
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFC0FCFC)),
            );
          } else if (snapshot.hasError) {
            // Error occurred while fetching data
            return const Center(
              child: Text(
                "Error fetching user details.",
                style: TextStyle(color: Colors.white),
              ),
            );
          } else {
            final userData = snapshot.data;
            if (userData == null) {
              // No user data found
              return const Center(
                child: Text(
                  "User not found.",
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            // Extract user fields
            final userId = userData['userId'] ?? 'N/A';
            final fullName = userData['fullName'] ?? 'N/A';
            final studentId = userData['studentId'] ?? 'N/A';
            final status = userData['status'] ?? '';
            final department = userData['department'] ?? '';
            final combinedStatus = (status.isNotEmpty && department.isNotEmpty)
                ? "$status - $department"
                : status.isNotEmpty
                    ? status
                    : 'N/A';

            // Hardcoded activity (adjust if needed)
            const activity = "Active User";

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // "USER DETAILS" heading
                  const Center(
                    child: Text(
                      "USER DETAILS",
                      style: TextStyle(
                        color: Color(0xFFBDFCFD),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Name
                  const Text(
                    "Name :",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    fullName.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ID
                  const Text(
                    "ID :",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    userId,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Text(
                    "Student ID :",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    studentId,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Status
                  const Text(
                    "Status :",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    combinedStatus,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Activity
                  const Text(
                    "Activity :",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    activity,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Verified status
                  const Text(
                    "Verified :",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 5),
                  _isVerified == true
                      ? const Text(
                          "User is Verified",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        )
                      : const Text(
                          "User is Not Verified",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),

                  const SizedBox(height: 60),

                  // Buttons Row: Verify User and Delete User
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Verify User Button (only if not verified)
                      if (_isVerified != true)
                        Expanded(
                          child: SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _verifyUser,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.greenAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: const Text(
                                "Verify User",
                                style: TextStyle(
                                    color: Colors.black, fontSize: 16),
                              ),
                            ),
                          ),
                        ),

                      const SizedBox(width: 10), // Add spacing between buttons

                      // Delete User Button
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _deleteUser,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF7E7E),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text(
                              "Delete User",
                              style:
                                  TextStyle(color: Colors.black, fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
