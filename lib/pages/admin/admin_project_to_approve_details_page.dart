import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kict_crowdfunding/models/project.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:kict_crowdfunding/pages/admin/admin_project_to_approve_confirmation_page.dart';
import 'package:kict_crowdfunding/pages/admin/admin_project_to_approve_result_page.dart';
import 'package:kict_crowdfunding/pages/admin/admin_project_to_reject_confirmation_page.dart';
import 'package:share_plus/share_plus.dart';

class AdminProjectsToApproveDetailsPage extends StatefulWidget {
  final Project project;

  const AdminProjectsToApproveDetailsPage({super.key, required this.project});

  @override
  State<AdminProjectsToApproveDetailsPage> createState() =>
      _AdminProjectsToApproveDetailsPageState();
}

class _AdminProjectsToApproveDetailsPageState
    extends State<AdminProjectsToApproveDetailsPage> {
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
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.black),
            onPressed: () {
              String shareText = """
                Check out this project: ${widget.project.title}
                Goal: RM${widget.project.goal}
                Description: ${widget.project.description}
                Duration: ${widget.project.startDate} to ${widget.project.endDate}
                """;
              Share.share(shareText);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Project Image
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                widget.project.imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 10),

            // Category Tag
            Text(
              widget.project.category,
              style: const TextStyle(
                color: Color(0xFFC0FCFC),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),

            // Project Title
            Text(
              "${widget.project.title} (ID: ${widget.project.projectId})",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            // Project Description Heading
            const Text(
              "Project Description",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),

            // Project Description
            Text(
              widget.project.description,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),

            // Project Owner Details
            const Text(
              "Project Owner",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),

            // Show owner details if loaded, or a loading spinner
            isLoadingOwner
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFC0FCFC),
                    ),
                  )
                : ownerData != null
                    ? Text(
                        "Name: ${ownerData!['fullName'] ?? "N/A"}\n"
                        "ID: ${ownerData!['studentId'] ?? "N/A"}\n"
                        "Status: ${ownerData!['status'] ?? "N/A"}\n"
                        "Verified: ${ownerData!['verified'] == true ? "YES" : "NO"}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      )
                    : const Text(
                        "Owner details not available.",
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
            const SizedBox(height: 20),

            // Category Section
            Text(
              "Category: ${widget.project.category}",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),

            // Approve and Delete Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Approve Button
                ElevatedButton(
                  onPressed: () {
                    // _updateProjectStatus(context, "approved");
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                AdminProjectToApproveConfirmationPage(
                                  project: widget.project,
                                )));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC0FCC2),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    "Approve",
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                ),

                // Delete Button
                ElevatedButton(
                  onPressed: () {
                    // _updateProjectStatus(context, "deleted");
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                AdminProjectToRejectConfirmationPage(
                                  project: widget.project,
                                )));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF8383),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    "Delete",
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                ),
              ],
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
      // Get the current UTC time
      final DateTime utcTime = DateTime.now().toUtc();

      // Add 8 hours to convert to Malaysia Time
      final DateTime malaysiaTime = utcTime.add(const Duration(hours: 8));

      // Format the Malaysia Time
      final String formattedTimestamp =
          DateFormat('yyyy-MM-dd hh:mm a').format(malaysiaTime);
      // Generate a unique notification ID
      final notificationRef =
          FirebaseDatabase.instance.ref().child('notifications').push();

      // Create a notification message
      String notificationMessage = status == "approved"
          ? "Your project '${widget.project.title}' has been approved."
          : "Your project '${widget.project.title}' has been deleted.";

      String notificationTitle =
          status == "approved" ? "Project Approved" : "Project Deleted";

      // Add the notification to Firebase
      await notificationRef.set({
        'message': notificationMessage,
        'timestamp': formattedTimestamp,
        'title': notificationTitle,
        'userId': widget.project.createdBy, // The project owner's userId
      });

      if (status == "deleted") {
        // Navigate to the result page for deleted status
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AdminProjectToApproveResultPage(
              ownerName: ownerData!['fullName'],
              ownerId: ownerData!['studentId'],
              ownerStatus: ownerData!['status'],
              ownerVerified: ownerData!['verified'] ?? false,
              projectStatus: 'DELETED',
            ),
          ),
        );
        return;
      }

      // Show a confirmation message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "Project has been ${status == "approved" ? "approved" : "deleted"} and a notification has been sent."),
        ),
      );
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
