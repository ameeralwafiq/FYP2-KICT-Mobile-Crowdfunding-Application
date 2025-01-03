import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:kict_crowdfunding/pages/logo_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const supabaseUrl = 'https://voiqdskbrcejouwkqjxf.supabase.co';
const supabaseKey =
    "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZvaXFkc2ticmNlam91d2txanhmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzQxOTc1NjQsImV4cCI6MjA0OTc3MzU2NH0.WSvhICHCQAmxZ4CcKXbKg9Xv_MSX3uNGQ8i7EAgzXeM";
void main() async {
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyBFWaRd81UBhR2fOUbWkwOg98Fu4vR_WLY',
      appId: '1:432800643120:android:7e8e852281c5735b9d15f5',
      messagingSenderId: '432800643120',
      projectId: 'kict-crowdfunding',
      storageBucket: 'kict-crowdfunding.firebasestorage.app',
      databaseURL:
          'https://kict-crowdfunding-default-rtdb.asia-southeast1.firebasedatabase.app',
    ),
  );

  runApp(
    const MyApp(),
  );

  // runApp(DevicePreview(
  //   enabled: true,
  //   builder: (context) => const MyApp(), // Wrap your app
  // ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LogoPage(),
    );
  }
}
