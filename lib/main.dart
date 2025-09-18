// main.dart
import 'package:flutter/material.dart';// Update path if needed
// You might need to import firebase_core if you haven't removed it completely
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // If you are fully on dummy data and not using Firebase for anything yet,
  // you can comment out Firebase.initializeApp for now.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const AuthWrapper(), // Start with the LoginScreen
      // You might want to define routes for easier navigation later:
      // routes: {
      //   '/login': (context) => const LoginScreen(),
      //   '/admin_dashboard': (context) => const AdminDashboardScreen(),
      //   // ... other routes
      // },
    );
  }
}
