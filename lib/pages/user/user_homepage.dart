import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:kict_crowdfunding/models/project.dart';
import 'package:kict_crowdfunding/pages/user/user_chat_page.dart';
import 'package:kict_crowdfunding/pages/user/user_create_project_page.dart';
import 'package:kict_crowdfunding/pages/user/user_notification_page.dart';
import 'package:kict_crowdfunding/pages/user/user_profile_page.dart';
import 'package:kict_crowdfunding/pages/user/user_project_details_page.dart';
import 'package:kict_crowdfunding/pages/user/user_project_list.dart';
import 'package:kict_crowdfunding/pages/user/user_setting_page.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  UserHomePageState createState() => UserHomePageState();
}

class UserHomePageState extends State<UserHomePage> {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  late StreamSubscription<DatabaseEvent> _projectsSubscription;

  // Keep a full list of all projects
  List<Project> allProjects = [];

  // Trending and latest projects derived from allProjects
  List<Project> trendingProjects = [];
  List<Project> latestProjects = [];

  // For search
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';
  List<Project> searchResults = [];

  bool isLoading = true;

  // This variable will track if we are currently viewing the "expanded" view of a section
  // Possible values: 'Trending', 'Latest', or null for the default homepage view
  String? expandedSection;

  @override
  void initState() {
    super.initState();
    _listenToProjects();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _projectsSubscription.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      searchQuery = _searchController.text.trim();
    });
    _filterProjects(searchQuery);
  }

  void _filterProjects(String query) {
    if (query.isEmpty) {
      searchResults.clear();
    } else {
      searchResults = allProjects.where((project) {
        final title = (project.title).toString().toLowerCase();
        return title.contains(query.toLowerCase());
      }).toList();
    }
    setState(() {});
  }

  // Listen for changes in the 'projects' node
  void _listenToProjects() {
    _projectsSubscription = _databaseRef.child('projects').onValue.listen(
      (event) {
        final snapshot = event.snapshot;
        if (snapshot.exists) {
          try {
            // Convert snapshot data to a Map
            final data = Map<String, dynamic>.from(snapshot.value as Map);

            // Parse data into a list of Project objects
            allProjects = data.entries.map((entry) {
              print('data ${entry.key.toString()} ${entry.value.toString()}');

              final projectData = Map<String, dynamic>.from(entry.value);
              return Project.fromJson(entry.key, projectData);
            }).toList();

            // Sort for trending (by clicked count) and latest (by createdAt)
            trendingProjects = List<Project>.from(allProjects)
              ..sort((a, b) => b.clicked.compareTo(a.clicked));
            latestProjects = List<Project>.from(allProjects)
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

            setState(() {
              isLoading = false;
            });

            // Re-apply filter if searching
            if (searchQuery.isNotEmpty) {
              _filterProjects(searchQuery);
            }
          } catch (e) {
            print("Error parsing projects: $e");
            setState(() {
              allProjects = [];
              trendingProjects = [];
              latestProjects = [];
              isLoading = false;
            });
          }
        } else {
          setState(() {
            allProjects = [];
            trendingProjects = [];
            latestProjects = [];
            isLoading = false;
          });
        }
      },
      onError: (error) {
        print("Error fetching projects: $error");
        setState(() {
          isLoading = false;
        });
      },
    );
  }

  Widget _buildMainContent(BuildContext context) {
    // If the search query is not empty, show the search results
    if (searchQuery.isNotEmpty) {
      return _buildSearchResults(context, searchResults);
    }

    // If expandedSection is set, show that section in a list
    if (expandedSection == 'Trending') {
      return _buildSearchResults(context, trendingProjects);
    } else if (expandedSection == 'Latest') {
      return _buildSearchResults(context, latestProjects);
    }

    // Otherwise, show the default homepage view with Trending and Latest sections
    return SingleChildScrollView(
      child: SizedBox(
        width: MediaQuery.sizeOf(context).width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Stack(
              children: [
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: const DecorationImage(
                      image: AssetImage('assets/images/homepage1.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const Positioned(
                  bottom: 10,
                  left: 10,
                  right: 10,
                  child: Text(
                    '"No one has ever become poor from giving."',
                    style: TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: Colors.white,
                      backgroundColor: Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Section(
              title: 'Trending',
              projects: trendingProjects,
              onProjectTap: _onProjectTap,
              onViewMoreTap: () {
                setState(() {
                  expandedSection = 'Trending';
                });
              },
            ),
            const SizedBox(height: 20),
            Section(
              title: 'Latest',
              projects: latestProjects,
              onProjectTap: _onProjectTap,
              onViewMoreTap: () {
                setState(() {
                  expandedSection = 'Latest';
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(
      BuildContext context, List<Project> projectsToDisplay) {
    if (projectsToDisplay.isEmpty) {
      return const Center(
        child: Text(
          'No matching projects found.',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    // Display projects in a list, similar to the search results view
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: projectsToDisplay.map((project) {
          return GestureDetector(
            onTap: () => _onProjectTap(project),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: NetworkImage(project.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
              height: 150,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  color: Colors.black.withOpacity(0.6),
                  padding: const EdgeInsets.all(5),
                  child: Text(
                    project.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _onProjectTap(Project project) {
    // Increment clicked count
    int currentClicked = project.clicked;
    final projectId = project.projectId;
    _databaseRef
        .child('projects/$projectId')
        .update({'clicked': currentClicked + 1});

    // Navigate to project details page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserProjectDetailsPage(project: project),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        toolbarHeight: MediaQuery.sizeOf(context).height * 0.05,
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFC0FCC2),
        elevation: 0,
        title: const Text(
          'KICT Crowdfunding',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        leading: expandedSection != null || searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  setState(() {
                    expandedSection = null;
                    searchQuery = '';
                    _searchController.clear();
                  });
                },
              )
            : null,
        actions: [
          IconButton(
            icon: Icon(
              Icons.notifications_outlined,
              color: Colors.black,
              size: MediaQuery.sizeOf(context).height * 0.03,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const UserNotificationPage()),
              );
            },
          ),
          IconButton(
            icon: Icon(
              Icons.settings_outlined,
              color: Colors.black,
              size: MediaQuery.sizeOf(context).height * 0.03,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const UserSettingPage()),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFC0FCC2)),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Search bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Search Projects...',
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(child: _buildMainContent(context)),
                ],
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFFC0FCC2),
        selectedIconTheme: const IconThemeData(color: Colors.white),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
        currentIndex: 0,
        onTap: (index) {
          // Handle navigation here
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const UserProjectsListPage()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const UserCreateProjectPage()),
            );
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const UserChatPage()),
            );
          } else if (index == 4) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const UserProfilePage()),
            );
          }
        },
      ),
    );
  }
}

class Section extends StatelessWidget {
  final String title;
  final List<Project> projects;
  final void Function(Project) onProjectTap;
  final void Function() onViewMoreTap;

  const Section({
    super.key,
    required this.title,
    required this.projects,
    required this.onProjectTap,
    required this.onViewMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            GestureDetector(
              onTap: onViewMoreTap,
              child: const Text(
                'View More...',
                style: TextStyle(
                  color: Color(0xFFC0FCC2),
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: projects.length,
            itemBuilder: (context, index) {
              final project = projects[index];
              return GestureDetector(
                onTap: () => onProjectTap(project),
                child: Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: Container(
                    width: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: NetworkImage(project.imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        width: double.infinity,
                        color: Colors.black.withOpacity(0.6),
                        padding: const EdgeInsets.all(5),
                        child: Text(
                          project.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
