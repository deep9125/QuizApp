  // screens/User/user_dashboard_screen.dart
import 'package:flutter/material.dart';
import '../../services/firebase_auth_service.dart'; // Use the real auth service
import '../login_screen.dart';
class UserDashboardScreen extends StatelessWidget {
   UserDashboardScreen({super.key});
  final FirebaseAuthService _authService = FirebaseAuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // Call the real signOut method
              await _authService.signOut();

              // Navigate back to the login screen after logout
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (Route<dynamic> route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('Welcome, User!', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}