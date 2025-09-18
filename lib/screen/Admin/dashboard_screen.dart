// screens/Admin/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/admin_service.dart';
import '../../services/firebase_auth_service.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Number of tabs
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
              Tab(icon: Icon(Icons.pending_actions), text: 'Manager Requests'),
              Tab(icon: Icon(Icons.people), text: 'All Users'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            ManagerRequestsTab(),
            AllUsersTab(),
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
            return Card(
              child: ListTile(
                title: Text(doc['email']),
                subtitle: Text('UID: ${doc['uid']}'),
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
            return Card(
              child: ListTile(
                title: Text(doc['email']),
                subtitle: Text('Role: ${doc['role']} | Status: ${doc['status']}'),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}