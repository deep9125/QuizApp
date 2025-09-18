// screens/User/user_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/user_service.dart';
import '../../services/firebase_auth_service.dart';
import '../../Model/quiz_summary.dart';
import 'quiz_taking_screen.dart'; 
import 'rewards_store_screen.dart';
import 'profile_screen.dart';
import 'leaderboard_screen.dart';
class UserDashboardScreen extends StatefulWidget {
  const UserDashboardScreen({super.key});

  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
  final UserService _userService = UserService();
  final String? _userId = FirebaseAuth.instance.currentUser?.uid;
  List<ManagerQuizSummary> _quizzes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuizzes();
  }

  Future<void> _loadQuizzes() async {
    setState(() => _isLoading = true);
    final quizzes = await _userService.getAvailableQuizzes();
    if (mounted) {
      setState(() {
        _quizzes = quizzes;
        _isLoading = false;
      });
    }
  }

  void _navigateToQuiz(ManagerQuizSummary quiz) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizTakingScreen(quiz: quiz),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quizzes'),
        actions: [
          // --- NEW: Real-time Reward Counter ---
          if (_userId != null)
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('users').doc(_userId).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.exists) {
                  final userData = snapshot.data!.data() as Map<String, dynamic>;
                  final rewards = userData['rewards'] ?? 0;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Chip(
                      avatar: const Icon(Icons.star, color: Colors.amber),
                      label: Text(rewards.toString()),
                    ),
                  );
                }
                return const Padding(
                  padding: EdgeInsets.only(right: 16.0),
                  child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                );
              },
            ),
            IconButton(
            icon: const Icon(Icons.leaderboard),
            tooltip: 'Leaderboard',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LeaderboardScreen()),
              );
            },
          ),
            IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'My Profile',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => FirebaseAuthService().signOut(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadQuizzes,
              child: ListView( // Changed to ListView to easily add a header
                padding: const EdgeInsets.all(8.0),
                children: [
                  // --- NEW: Rewards Store Tile ---
                  Card(
                    color: Colors.deepPurple[50],
                    child: ListTile(
                      leading: const Icon(Icons.storefront, color: Colors.deepPurple),
                      title: const Text('Rewards Store', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text('Redeem your points for cool stuff!'),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded),
                      onTap: () {
                        // TODO: Navigate to the RewardsStoreScreen
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const RewardsStoreScreen()),
                            );
                      },
                    ),
                  ),
                  const SizedBox(height: 8), // Spacer
                  // Existing quiz list
                  ..._quizzes.map((quiz) {
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.quiz_rounded, color: Colors.deepPurple),
                        title: Text(quiz.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${quiz.category} | ${quiz.questionCount} Questions'),
                        trailing: const Icon(Icons.arrow_forward_ios_rounded),
                        onTap: () => _navigateToQuiz(quiz),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
    );
  }
}