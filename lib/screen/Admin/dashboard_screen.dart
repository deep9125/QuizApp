import 'package:flutter/material.dart';
import './manage_quizzes_screen.dart'; // For navigating to manage quizzes
import './manage_users_screen.dart';   // Import your Manage Users screen
import './analytics_screen.dart';    // Import your Analytics screen
import '../login_screen.dart';         // For logout
import '../../services/mock_auth_service.dart'; // For logout

class AdminDashboardScreen extends StatelessWidget {
  AdminDashboardScreen({super.key});

  final MockAuthService _authService = MockAuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        // Consider theming the AppBar as well for consistency
        // backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        // foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              // Consider a global auth service/provider for logout logic
              // await _authService.logout();

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
      body: GridView.count(
        crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2, // Responsive grid
        padding: const EdgeInsets.all(16.0),
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        children: <Widget>[
          _buildDashboardCard(
            context,
            icon: Icons.list_alt_rounded, // Good icon for quizzes
            title: 'Manage Quizzes',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AdminManageQuizzesScreen()),
              );
            },
          ),
          _buildDashboardCard(
            context,
            icon: Icons.people_alt_outlined, // Consistent outline style
            title: 'Manage Users',
            onTap: () {
              Navigator.push(
                context,
                // Ensure AdminManageUsersScreen is const constructible if possible
                MaterialPageRoute(builder: (context) => const AdminManageUsersScreen()),
              );
            },
          ),
          _buildDashboardCard(
            context,
            icon: Icons.analytics_outlined, // More specific icon for analytics
            title: 'View Analytics',
            onTap: () {
              Navigator.push(
                context,
                // Ensure AdminAnalyticsScreen is const constructible if possible
                MaterialPageRoute(builder: (context) => const AdminAnalyticsScreen()),
              );
            },
          ),
          // You could add more cards here if needed, e.g., "Settings", "Reports"
        ],
      ),
    );
  }

  Widget _buildDashboardCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required VoidCallback onTap,
      }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 2.0, // A flatter look can be more modern
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        // side: BorderSide(color: colorScheme.outlineVariant, width: 0.5), // Subtle border
      ),
      clipBehavior: Clip.antiAlias, // Ensures InkWell ripple respects border radius
      child: InkWell(
        onTap: onTap,
        // borderRadius: BorderRadius.circular(12.0), // Already handled by clipBehavior on Card
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Increased padding for better spacing
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(icon, size: 48.0, color: colorScheme.primary),
              const SizedBox(height: 12.0),
              Text(
                title,
                textAlign: TextAlign.center,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600, // Slightly bolder
                  color: colorScheme.onSurface, // Good contrast
                ),
                maxLines: 2, // Allow title to wrap if long
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

