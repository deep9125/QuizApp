// auth_wrapper.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'screen/login_screen.dart';
import 'screen/Admin/dashboard_screen.dart';
import 'screen/Manager/dashboard_screen.dart';
import 'screen/User/dashboard_screen.dart';
import 'screen/Manager/pending_approval_screen.dart'; // Corrected from your previous code

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasData) {
          return RoleBasedRedirect(uid: snapshot.data!.uid);
        }
        return const LoginScreen();
      },
    );
  }
}

class RoleBasedRedirect extends StatelessWidget {
  final String uid;
  const RoleBasedRedirect({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
          // This can happen if the user is in Auth but not in Firestore.
          // Signing them out is a safe fallback.
          FirebaseAuth.instance.signOut(); 
          return const LoginScreen();
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        
        // FIXED: Make the checks more robust
        final role = (data['role'] as String? ?? 'User').trim().toLowerCase();
        final status = (data['status'] as String? ?? 'pending').trim().toLowerCase();

        if (role == 'admin') {
          return const AdminDashboardScreen();
        }
        if (role == 'manager' && status == 'approved') {
          return  ManagerDashboardScreen();
        }
        if (role == 'manager' && (status == 'pending' || status == 'rejected')) {
          return const PendingApprovalScreen();
        }
        
        // Default for 'user' role or any other unexpected case
        return  UserDashboardScreen();
      },
    );
  }
}