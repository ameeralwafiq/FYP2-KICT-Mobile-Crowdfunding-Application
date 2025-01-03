import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:kict_crowdfunding/pages/admin/admin_payment_details_page.dart';

class AdminProjectsListDonationDetailsPage extends StatefulWidget {
  final String projectId;
  const AdminProjectsListDonationDetailsPage({
    super.key,
    required this.projectId,
  });

  @override
  AdminProjectsListDonationDetailsPageState createState() =>
      AdminProjectsListDonationDetailsPageState();
}

class AdminProjectsListDonationDetailsPageState
    extends State<AdminProjectsListDonationDetailsPage> {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  List<Map<String, dynamic>> payments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPayments();
  }

  void _fetchPayments() async {
    try {
      final DatabaseEvent event = await _databaseRef.child('payments').once();
      final DataSnapshot snapshot = event.snapshot;

      if (snapshot.value != null) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        final filteredPayments = data.entries
            .where((entry) =>
                entry.value['projectId'] ==
                widget.projectId) // Filter by projectId
            .map((entry) => {
                  'id': entry.key,
                  ...Map<String, dynamic>.from(entry.value),
                })
            .toList();

        setState(() {
          payments = filteredPayments;
          isLoading = false;
        });
      } else {
        setState(() {
          payments = [];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error fetching payments: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Reference to the specific project
    final DatabaseReference projectRef =
        _databaseRef.child('projects/${widget.projectId}');

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
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFC0FCFC),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FutureBuilder<DatabaseEvent>(
                  future: projectRef.once(), // Fetching the project data
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(
                          color: Color(0xFFC0FCFC),
                        ),
                      );
                    }
                    if (snapshot.hasError ||
                        !snapshot.hasData ||
                        snapshot.data!.snapshot.value == null) {
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          "Project details not available.",
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }
                    final projectData = Map<String, dynamic>.from(
                        snapshot.data!.snapshot.value as Map);
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 40),
                      child: Center(
                        child: Text(
                          'Donation for ${projectData['title']} (ID : ${widget.projectId})',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                Expanded(
                  child: payments.isEmpty
                      ? const Center(
                          child: Text(
                            "No payments found for this project.",
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 40),
                          itemCount: payments.length,
                          itemBuilder: (context, index) {
                            final payment = payments[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            AdminPaymentDetailsPage(
                                              paymentDetails: payment,
                                              userId: payment['userId'],
                                            )));
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 25),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: const Color(0xFFC0FCFC), width: 2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  "Donation RM${payment["amount"]}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
