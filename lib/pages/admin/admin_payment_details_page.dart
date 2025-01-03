import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:kict_crowdfunding/pages/admin/admin_payment_pdf.dart';

class AdminPaymentDetailsPage extends StatelessWidget {
  final String userId;
  final Map<String, dynamic> paymentDetails;

  const AdminPaymentDetailsPage({
    Key? key,
    required this.userId,
    required this.paymentDetails,
  }) : super(key: key);

  Future<Map<String, dynamic>?> _fetchUserDetails(String userId) async {
    final DatabaseReference usersRef =
        FirebaseDatabase.instance.ref().child('users/$userId');
    final DatabaseEvent event = await usersRef.once();
    if (event.snapshot.value != null) {
      return Map<String, dynamic>.from(event.snapshot.value as Map);
    }
    return null;
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
          "List of Donation",
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
        future: _fetchUserDetails(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFC0FCFC),
              ),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                "Failed to load user details.",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final userDetails = snapshot.data;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),
                  const Text(
                    "DONATION",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "RM ${paymentDetails['amount']}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 50),
                  if (userDetails != null) ...[
                    Text(
                      "Name: ${userDetails['fullName']}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "ID: ${userId}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Status: ${userDetails['status'] ?? 'N/A'} - ${userDetails['department'] ?? 'N/A'}", // Status could be null
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      userDetails['verified'] == null
                          ? 'Verified: No'
                          : userDetails['verified']
                              ? "Verified: Yes"
                              : "Verified: No",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ] else ...[
                    const Text(
                      "User details not available.",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                  const SizedBox(height: 50),
                  GestureDetector(
                      onTap: () {
                        // Add functionality to open the proof of payment URL
                        print(
                            "Opening proof of payment: ${paymentDetails['pdfUrl']}");
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AdminPaymentPdfPage(
                                      pdfUrl: paymentDetails['pdfUrl'],
                                    )));
                      },
                      child: RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: "Proof of Payment: ",
                              style: TextStyle(
                                color: Color(0xFFC0FCFC),
                                fontSize: 16,
                              ),
                            ),
                            TextSpan(
                              text: "payment.pdf",
                              style: TextStyle(
                                color: Color(0xFFC0FCFC),
                                fontSize: 16,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
