// screens/Admin/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/admin_service.dart';
import '../../services/firebase_auth_service.dart';
import 'manage_rewards_screen.dart'; // ADDED: Import for the new screen

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      // CHANGED: Number of tabs is now 3
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => FirebaseAuthService().signOut(),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.pending_actions), text: 'Requests'),
              Tab(icon: Icon(Icons.people), text: 'Users'),
              // ADDED: New tab for managing rewards
              Tab(icon: Icon(Icons.storefront), text: 'Rewards'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            ManagerRequestsTab(),
            AllUsersTab(),
            // ADDED: New tab view for the rewards management screen
            AdminManageRewardsScreen(),
          ],
        ),
      ),
    );
  }
}

// Tab for pending manager requests
class ManagerRequestsTab extends StatelessWidget {
  const ManagerRequestsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final AdminService adminService = AdminService();

    return StreamBuilder<QuerySnapshot>(
      stream: adminService.getPendingManagerRequests(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No pending manager requests.'));
        }

        return ListView(
          padding: const EdgeInsets.all(8),
          children: snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Card(
              child: ListTile(
                title: Text(data['email'] ?? 'No email'),
                subtitle: Text('UID: ${doc.id}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check_circle, color: Colors.green),
                      onPressed: () => adminService.approveManager(doc.id),
                      tooltip: 'Approve',
                    ),
                    IconButton(
                      icon: const Icon(Icons.cancel, color: Colors.red),
                      onPressed: () => adminService.rejectManager(doc.id),
                      tooltip: 'Reject',
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

// Tab for viewing all users
class AllUsersTab extends StatelessWidget {
  const AllUsersTab({super.key});

  @override
  Widget build(BuildContext context) {
    final AdminService adminService = AdminService();

    return StreamBuilder<QuerySnapshot>(
      stream: adminService.getAllUsers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData) {
          return const Center(child: Text('Could not load users.'));
        }

        return ListView(
          padding: const EdgeInsets.all(8),
          children: snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Card(
              child: ListTile(
                title: Text(data['email'] ?? 'No email'),
                subtitle: Text('Role: ${data['role']} | Status: ${data['status']}'),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}