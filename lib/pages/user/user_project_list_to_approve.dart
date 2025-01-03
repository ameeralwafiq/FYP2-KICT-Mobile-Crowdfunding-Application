import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:kict_crowdfunding/models/project.dart';
import 'package:kict_crowdfunding/pages/user/user_project_details_page.dart';

class UserProjectsListToApprove extends StatefulWidget {
  final String category;

  const UserProjectsListToApprove({super.key, required this.category});

  @override
  UserProjectsListToApproveState createState() =>
      UserProjectsListToApproveState();
}

class UserProjectsListToApproveState extends State<UserProjectsListToApprove> {
  // final FirebaseAuth _auth = FirebaseAuth.instance;
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
      // Query projects by category
      final DatabaseEvent event = await _databaseRef
          .child('projects')
          .orderByChild('category')
          .equalTo(widget.category)
          .once();

      final DataSnapshot snapshot = event.snapshot;
      if (snapshot.value != null) {
        // Parse the fetched data into a list of Project objects
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        final fetchedProjects = data.entries.map((entry) {
          final projectData = Map<String, dynamic>.from(entry.value);
          return Project.fromJson(entry.key, projectData);
        }).toList();

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
        backgroundColor: const Color(0xFFC2F8CE),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "${widget.category} Projects",
          style: const TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.black),
            onPressed: () {
              // Handle profile icon action
            },
          ),
        ],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFC2F8CE),
              ),
            )
          : projects.isEmpty
              ? const Center(
                  child: Text(
                    "No projects found in this category.",
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                UserProjectDetailsPage(project: project),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 15),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: const Color(0xFFC2F8CE), width: 2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          "Project ID : ${project.projectId}",
                          style: const TextStyle(
                            color: Color(0xFFC2F8CE),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
