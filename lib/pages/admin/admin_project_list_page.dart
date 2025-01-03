import 'package:flutter/material.dart';
import 'package:kict_crowdfunding/pages/admin/admin_project_list_on_category_page.dart';

class AdminProjectsListPage extends StatelessWidget {
  const AdminProjectsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          'Projects List',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 20.0),
        child: ListView(
          children: [
            ProjectCard(
              imagePath: 'assets/images/education.png',
              title: 'Education',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AdminProjectsListOnCategory(
                            category: "Education",
                          )),
                );
                print('Education card tapped!');
              },
            ),
            const SizedBox(height: 20),
            ProjectCard(
              imagePath: 'assets/images/personal.png',
              title: 'Personal',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AdminProjectsListOnCategory(
                            category: "Personal",
                          )),
                );
                print('Personal card tapped!');
              },
            ),
            const SizedBox(height: 20),
            ProjectCard(
              imagePath: 'assets/images/food.png',
              title: 'Food',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AdminProjectsListOnCategory(
                            category: "Food",
                          )),
                );
                print('Food card tapped!');
              },
            ),
          ],
        ),
      ),
      backgroundColor: Colors.black,
    );
  }
}

class ProjectCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final VoidCallback onTap;

  const ProjectCard(
      {super.key,
      required this.imagePath,
      required this.title,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.black.withOpacity(0.5),
          ),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
