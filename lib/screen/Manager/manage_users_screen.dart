import 'package:flutter/material.dart';

// Mock User Data Model (very basic)
class AdminUser {
  final String id;
  final String email;
  final String role; // e.g., 'admin', 'taker'
  final DateTime lastLogin;

  AdminUser({
    required this.id,
    required this.email,
    required this.role,
    required this.lastLogin,
  });
}

class AdminManageUsersScreen extends StatefulWidget {
  const AdminManageUsersScreen({super.key});

  @override
  State<AdminManageUsersScreen> createState() => _AdminManageUsersScreenState();
}

class _AdminManageUsersScreenState extends State<AdminManageUsersScreen> {
  // MOCK DATA - Replace with actual data fetching later
  List<AdminUser> _users = [
    AdminUser(id: 'user1', email: 'deep@example.com', role: 'taker', lastLogin: DateTime.now().subtract(const Duration(hours: 1))),
    AdminUser(id: 'user2', email: 'ronak@example.com', role: 'taker', lastLogin: DateTime.now().subtract(const Duration(days: 1))),
    AdminUser(id: 'user3', email: 'testuser1@example.com', role: 'taker', lastLogin: DateTime.now().subtract(const Duration(minutes: 30))),
    AdminUser(id: 'user4', email: 'another.user@example.com', role: 'taker', lastLogin: DateTime.now().subtract(const Duration(days: 2))),
  ];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 400));
    // In a real app: _users = await _apiService.fetchAdminUsers();
    setState(() => _isLoading = false);
  }

  void _editUserRole(AdminUser user) {
    // TODO: Implement user role editing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit role for ${user.email} - Not implemented.')),
    );
  }

  void _viewUserActivity(AdminUser user) {
    // TODO: Implement navigation to a user activity/details screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('View activity for ${user.email} - Not implemented.')),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Users'),
        backgroundColor: Colors.blueGrey[700],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _users.isEmpty
          ? const Center(
        child: Text('No users found or feature not fully implemented.', style: TextStyle(fontSize: 16)),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 5.0),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: user.role == 'admin' ? Colors.amber[700] : Colors.green[600],
                child: Icon(
                  user.role == 'admin' ? Icons.security : Icons.person_outline,
                  color: Colors.white,
                ),
              ),
              title: Text(user.email, style: const TextStyle(fontWeight: FontWeight.w500)),
              subtitle: Text('Role: ${user.role} | Last Login: ${user.lastLogin.toLocal().toString().substring(0, 16)}'),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit_role') {
                    _editUserRole(user);
                  } else if (value == 'view_activity') {
                    _viewUserActivity(user);
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'edit_role',
                    child: Text('Edit Role'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'view_activity',
                    child: Text('View Activity'),
                  ),
                  // Add more actions like "Disable User", "Delete User" if needed
                ],
              ),
              onTap: () => _viewUserActivity(user), // Default action on tap
            ),
          );
        },
      ),
    );
  }
}
