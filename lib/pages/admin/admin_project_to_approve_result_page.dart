import 'package:flutter/material.dart';

class AdminProjectToApproveResultPage extends StatelessWidget {
  final String ownerName;
  final String ownerId;
  final String ownerStatus;
  final bool ownerVerified;
  final String projectStatus;

  const AdminProjectToApproveResultPage({
    super.key,
    required this.ownerName,
    required this.ownerId,
    required this.ownerStatus,
    required this.ownerVerified,
    required this.projectStatus,
  });

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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
              Text(
                "Name : $ownerName\n"
                "ID : $ownerId\n"
                "Status : $ownerStatus\n"
                "Verified : ${ownerVerified ? "YES" : "NO"}",
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Project Status
              const Text(
                "Project Status",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                projectStatus.toUpperCase(),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: projectStatus.toLowerCase() == "approved"
                      ? const Color(0xFFC0FCC2) // Green for approved
                      : const Color(0xFFFCC0C0), // Red for deleted
                ),
              ),
              const SizedBox(height: 50),

              // Home Button
              ElevatedButton(
                onPressed: () {
                  if (projectStatus.toLowerCase() == "approved") {
                    Navigator.pop(context);
                    Navigator.pop(context);
                    Navigator.pop(context);
                    Navigator.pop(context);
                    Navigator.pop(context);
                  } else {
                    Navigator.pop(context);
                    Navigator.pop(context);
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC0FCFC),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  "Home",
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
