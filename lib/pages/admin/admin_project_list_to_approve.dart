import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:kict_crowdfunding/models/project.dart';
import 'package:kict_crowdfunding/pages/admin/admin_project_to_approve_details_page.dart';

class AdminProjectsListToApprovePage extends StatefulWidget {
  const AdminProjectsListToApprovePage({super.key});

  @override
  AdminProjectsListOnCategoryState createState() =>
      AdminProjectsListOnCategoryState();
}

class AdminProjectsListOnCategoryState
    extends State<AdminProjectsListToApprovePage> {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  List<Project> projects = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProjects();
  }

  void _fetchProjects() async {
    try {
      // Query all projects
      final DatabaseEvent event = await _databaseRef.child('projects').once();

      final DataSnapshot snapshot = event.snapshot;
      if (snapshot.value != null) {
        // Parse the fetched data into a list of Project objects
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        final fetchedProjects = data.entries
            .map((entry) {
              final projectData = Map<String, dynamic>.from(entry.value);
              return Project.fromJson(entry.key, projectData);
            })
            .where((project) =>
                project.status == "pending") // Filter by pending status
            .toList();

        setState(() {
          projects = fetchedProjects;
          isLoading = false;
        });
      } else {
        setState(() {
          projects = [];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error fetching projects: $e");
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
          style: TextStyle(color: Colors.black),
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
                color: Color(0xFFC0FCFC),
              ),
            )
          : projects.isEmpty
              ? const Center(
                  child: Text(
                    "No projects found with pending status.",
                    style: TextStyle(color: Colors.white),
                  ),
                )
              : ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  itemCount: projects.length,
                  itemBuilder: (context, index) {
                    final project = projects[index];
                    return GestureDetector(
                      onTap: () {
                        // Navigate to project details or perform another action
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    AdminProjectsToApproveDetailsPage(
                                      project: project,
                                    )));
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 15),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: const Color(0xFFC0FCFC), width: 2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Text(
                              "Project ID: ${project.projectId}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
