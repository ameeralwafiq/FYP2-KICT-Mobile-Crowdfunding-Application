import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class AdminPaymentPdfPage extends StatefulWidget {
  final String pdfUrl;

  const AdminPaymentPdfPage({
    super.key,
    required this.pdfUrl,
  });

  @override
  AdminPaymentPdfPageState createState() => AdminPaymentPdfPageState();
}

class AdminPaymentPdfPageState extends State<AdminPaymentPdfPage> {
  String? localPath;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _downloadPdf();
  }

  Future<void> _downloadPdf() async {
    try {
      // Get the temporary directory
      final directory = await getTemporaryDirectory();
      final filePath = "${directory.path}/downloaded_pdf.pdf";

      // Download the PDF
      final dio = Dio();
      await dio.download(widget.pdfUrl, filePath);

      setState(() {
        localPath = filePath;
        isLoading = false;
      });
    } catch (e) {
      print("Error downloading PDF: $e");
      setState(() {
        isLoading = false;
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
          "PAYMENT SUCCESSFUL",
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
          : localPath == null
              ? const Center(
                  child: Text(
                    "Failed to load PDF.",
                    style: TextStyle(color: Colors.white),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: PDFView(
                      filePath: localPath,
                      enableSwipe: true,
                      swipeHorizontal: true,
                      autoSpacing: false,
                      pageFling: false,
                      onError: (error) {
                        print("PDF View Error: $error");
                      },
                      onRender: (pages) {
                        print("Document rendered with $pages pages.");
                      },
                    ),
                  ),
                ),
    );
  }
}
