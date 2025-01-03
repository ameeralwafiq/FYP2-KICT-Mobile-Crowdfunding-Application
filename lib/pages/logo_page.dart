import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kict_crowdfunding/pages/choose_role_page.dart';

class LogoPage extends StatefulWidget {
  const LogoPage({super.key});

  @override
  LogoPageState createState() => LogoPageState();
}

class LogoPageState extends State<LogoPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller for the fade-in
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Define the fade-in animation
    _fadeInAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    // Start the fade-in animation
    _controller.forward();

    // Navigate to the ChooseRolePage after 3 seconds
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ChooseRolePage()),
      );
    });
  }

  @override
  void dispose() {
    // Always dispose animation controllers to free resources
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: FadeTransition(
          opacity: _fadeInAnimation,
          child: Image.asset(
            'assets/images/logo.png',
            width: screenWidth,
          ),
        ),
      ),
    );
  }
}
