import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:kict_crowdfunding/models/project.dart';

class UserPaymentPage extends StatefulWidget {
  final Project project;

  const UserPaymentPage({super.key, required this.project});

  @override
  UserPaymentPageState createState() => UserPaymentPageState();
}

class UserPaymentPageState extends State<UserPaymentPage> {
  bool isChecked = false;
  String? pdfUrl; // To store the uploaded PDF's URL
  TextEditingController _amountController = TextEditingController();

  bool isUploading = false;
  bool isPaying = false;

  // Reference to Firebase Database
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();

  // Supabase client (ensure it is already initialized in main.dart)
  final SupabaseClient supabase = Supabase.instance.client;

  Future<void> _pickAndUploadPDF() async {
    try {
      // Pick the file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (result == null) return; // user canceled picking a file

      setState(() {
        isUploading = true;
      });

      File file = File(result.files.single.path!);
      // Get the current user's ID
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("User not logged in.");
      }
      final userId = user.uid;

      // Create file name: userId_projectId_timestamp.pdf
      final fileName =
          '${userId}_${widget.project.projectId}_${DateTime.now().millisecondsSinceEpoch}.pdf';

      final uploadedPath = await supabase.storage
          .from('payment_receipts') // Replace with your actual bucket
          .upload(fileName, file);

      // If we reach here, upload is successful
      final publicURL =
          supabase.storage.from('payment_receipts').getPublicUrl(fileName);
      setState(() {
        pdfUrl = publicURL;
      });
    } catch (e) {
      print("Error picking/uploading PDF: $e");
    } finally {
      setState(() {
        isUploading = false;
      });
    }
  }

  Future<void> _payNow() async {
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter an amount.")),
      );
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid amount.")),
      );
      return;
    }

    if (pdfUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please upload a payment receipt first.")),
      );
      return;
    }

    setState(() {
      isPaying = true;
    });

    try {
      // Get the currently logged-in user
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User not logged in.")),
        );
        return;
      }

      final userId = user.uid;

      // Create a payment record in Firebase Realtime Database
      final paymentRef = _databaseRef.child('payments').push();
      await paymentRef.set({
        'userId': userId,
        'projectId': widget.project.projectId,
        'amount': amount,
        'pdfUrl': pdfUrl,
        'timestamp': ServerValue.timestamp, // current server timestamp
      });

      // Update the project's progress
      final projectRef =
          _databaseRef.child('projects/${widget.project.projectId}');
      final projectSnapshot = await projectRef.get();

      if (projectSnapshot.exists) {
        final currentProgress = projectSnapshot.child('progress').value as int;
        final updatedProgress = currentProgress + amount;

        await projectRef.update({
          'progress': updatedProgress,
        });

        // Generate a unique notification ID
        final notificationRef1 =
            FirebaseDatabase.instance.ref().child('notifications').push();

        // Get the current UTC time
        final DateTime utcTime1 = DateTime.now().toUtc();

        // Add 8 hours to convert to Malaysia Time
        final DateTime malaysiaTime1 = utcTime1.add(const Duration(hours: 8));

        // Format the Malaysia Time
        final String formattedTimestamp1 =
            DateFormat('yyyy-MM-dd hh:mm a').format(malaysiaTime1);

        // Add the notification to Firebase
        await notificationRef1.set({
          'message':
              "Received payment for your project ${widget.project.title} for RM${amount.toString()}.",
          'timestamp': formattedTimestamp1,
          'title': "Payment Received",
          'userId': widget.project.createdBy,
        });

        // Generate a unique notification ID
        final notificationRef2 =
            FirebaseDatabase.instance.ref().child('notifications').push();

        // Get the current UTC time
        final DateTime utcTime2 = DateTime.now().toUtc();

        // Add 8 hours to convert to Malaysia Time
        final DateTime malaysiaTime2 = utcTime2.add(const Duration(hours: 8));

        // Format the Malaysia Time
        final String formattedTimestamp2 =
            DateFormat('yyyy-MM-dd hh:mm a').format(malaysiaTime2);

        // Add the notification to Firebase
        await notificationRef2.set({
          'message':
              "Your payment for Project ${widget.project.title} is successful.",
          'timestamp': formattedTimestamp2,
          'title': "Payment Received",
          'userId': userId,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Payment recorded and project updated.")),
        );
      } else {
        throw Exception("Project not found.");
      }

      // Optionally navigate back or reset fields
      if (!mounted) return;
      Navigator.pop(context);
      Navigator.pop(context);
    } catch (e) {
      print("Error processing payment: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error processing payment.")),
      );
    } finally {
      setState(() {
        isPaying = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFFC0FCC2),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Payment",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.1,
              ),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Amount (RM)",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: "Enter amount (e.g., 10)",
                        hintStyle: const TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(
                          flex: 3,
                          child: Text(
                            "Bank :",
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                        ),
                        Expanded(
                          flex: 5,
                          child: Text(
                            widget.project.bank,
                            style: const TextStyle(
                                fontSize: 16, color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(
                          flex: 3,
                          child: Text(
                            "Account No. :",
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                        ),
                        Expanded(
                          flex: 5,
                          child: Text(
                            widget.project.accountNo,
                            style: const TextStyle(
                                fontSize: 16, color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "*Upload Payment Receipt (.pdf)",
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: isUploading ? null : _pickAndUploadPDF,
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: pdfUrl != null
                                    ? Colors.green[100]
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: isUploading
                                    ? const CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.black),
                                      )
                                    : Text(
                                        pdfUrl == null
                                            ? "Upload File"
                                            : "File Uploaded",
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: isUploading ? null : _pickAndUploadPDF,
                          child: Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.upload,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Expanded(
                          child: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                "I agree to the ",
                                style: TextStyle(
                                    fontSize: 14, color: Colors.black),
                              ),
                              Text(
                                "terms and conditions",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              Text(
                                " as set out by the user agreement",
                                style: TextStyle(
                                    fontSize: 14, color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                        Checkbox(
                          value: isChecked,
                          activeColor: Colors.green,
                          onChanged: (bool? value) {
                            setState(() {
                              isChecked = value ?? false;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: (!isChecked || isPaying)
                            ? null
                            : _payNow, // Disable button if not checked or paying
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC0FCC2),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: isPaying
                            ? const CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.black),
                              )
                            : const Text(
                                "Pay Now",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
