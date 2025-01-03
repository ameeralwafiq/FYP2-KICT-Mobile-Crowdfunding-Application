import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:kict_crowdfunding/models/project.dart';
import 'package:kict_crowdfunding/pages/admin/admin_project_to_approve_result_page.dart';

class AdminProjectToApproveConfirmationPage extends StatefulWidget {
  final Project project;

  const AdminProjectToApproveConfirmationPage({
    super.key,
    required this.project,
  });

  @override
  State<AdminProjectToApproveConfirmationPage> createState() =>
      _AdminProjectToApproveConfirmationPageState();
}

class _AdminProjectToApproveConfirmationPageState
    extends State<AdminProjectToApproveConfirmationPage> {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  Map<String, dynamic>? ownerData;
  bool isLoadingOwner = true;

  @override
  void initState() {
    super.initState();
    _fetchOwnerDetails();
  }

  Future<void> _fetchOwnerDetails() async {
    try {
      final snapshot =
          await _databaseRef.child('users/${widget.project.createdBy}').get();
      if (snapshot.exists) {
        setState(() {
          ownerData = Map<String, dynamic>.from(snapshot.value as Map);
          isLoadingOwner = false;
        });
      } else {
        setState(() {
          isLoadingOwner = false;
        });
      }
    } catch (e) {
      print("Error fetching owner details: $e");
      setState(() {
        isLoadingOwner = false;
      });
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
          "Projects List to Approve",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 30),

            // Confirmation Text
            const Text(
              "Are you sure ?",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              "Please make sure everything is evaluated before confirming.",
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            // Yes and No Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _updateProjectStatus(context, "approved");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC0FCC2),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    "Yes",
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF8383),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    "No",
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 50),

            // Project Owner Details
            const Text(
              "Project Owner",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            isLoadingOwner
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFC0FCFC),
                    ),
                  )
                : ownerData != null
                    ? Text(
                        "Name : ${ownerData!['fullName'] ?? "N/A"}\n"
                        "ID : ${ownerData!['studentId'] ?? "N/A"}\n"
                        "Status : ${ownerData!['status'] ?? "N/A"}\n"
                        "Verified : ${ownerData!['verified'] == true ? "YES" : "NO"}",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.left,
                      )
                    : const Text(
                        "Owner details not available.",
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
            const SizedBox(height: 20),

            // Recommendation Note
            Text(
              ownerData != null &&
                      ownerData!['fullName'] != null &&
                      ownerData!['studentId'] != null &&
                      ownerData!['status'] != null &&
                      ownerData!['verified'] != null
                  ? "All Requirement Filled :\nRecommended to Approve"
                  : "Not All Requirement Filled :\nNot Recommended to Approve",
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _updateProjectStatus(BuildContext context, String status) async {
    try {
      // Update the project's status in Firebase
      await FirebaseDatabase.instance
          .ref()
          .child('projects/${widget.project.projectId}')
          .update({'status': status});

      // Generate a unique notification ID
      final notificationRef =
          FirebaseDatabase.instance.ref().child('notifications').push();

      // Create a notification message
      String notificationMessage = status == "approved"
          ? "Your project '${widget.project.title}' has been approved."
          : "Your project '${widget.project.title}' has been deleted.";

      String notificationTitle =
          status == "approved" ? "Project Approved" : "Project Deleted";
      // Get the current UTC time
      final DateTime utcTime = DateTime.now().toUtc();

      // Add 8 hours to convert to Malaysia Time
      final DateTime malaysiaTime = utcTime.add(const Duration(hours: 8));

      // Format the Malaysia Time
      final String formattedTimestamp =
          DateFormat('yyyy-MM-dd hh:mm a').format(malaysiaTime);
      // Add the notification to Firebase
      await notificationRef.set({
        'message': notificationMessage,
        'timestamp': formattedTimestamp,
        'title': notificationTitle,
        'userId': widget.project.createdBy, // The project owner's userId
      });

      // Show a success message
      if (!mounted) return;
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => AdminProjectToApproveResultPage(
                    ownerName: ownerData!['fullName'],
                    ownerId: ownerData!['studentId'],
                    ownerStatus: ownerData!['status'],
                    ownerVerified: ownerData!['verified'] ?? false,
                    projectStatus: 'APPROVED',
                  )));
    } catch (e) {
      // Handle errors during the Firebase update
      print("Error updating project status: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to update project status."),
        ),
      );
    }
  }
}
