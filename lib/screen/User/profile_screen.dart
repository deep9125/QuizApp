// screens/User/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/user_service.dart';
import '../../Model/quiz_attempt.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService();
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  late Future<List<QuizAttempt>> _historyFuture;

  @override
  void initState() {
    super.initState();
    if (_currentUser != null) {
      _historyFuture = _userService.getUserQuizHistory(_currentUser!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: _currentUser == null
          ? const Center(child: Text('User not logged in.'))
          : ListView(
              children: [
                _buildProfileHeader(),
                const SizedBox(height: 24),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text('Quiz History', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                _buildQuizHistoryList(),
              ],
            ),
    );
  }

  Widget _buildProfileHeader() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(_currentUser!.uid).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        
        final userData = snapshot.data!.data() as Map<String, dynamic>;
        final rewards = userData['rewards'] ?? 0;

        return Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
                const SizedBox(height: 12),
                Text(_currentUser!.email ?? 'No email', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Chip(
                  avatar: const Icon(Icons.star, color: Colors.amber),
                  label: Text('$rewards Reward Points'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuizHistoryList() {
    return FutureBuilder<List<QuizAttempt>>(
      future: _historyFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Text('You haven\'t taken any quizzes yet!'),
          ));
        }

        final history = snapshot.data!;
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: history.length,
          itemBuilder: (context, index) {
            final attempt = history[index];
            return ListTile(
              leading: const Icon(Icons.history_edu),
              title: Text(attempt.quizTitle),
              subtitle: Text('Completed on ${attempt.completedAt.toLocal().toString().substring(0, 10)}'),
              trailing: Text(
                '${attempt.score}/${attempt.totalQuestions}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            );
          },
        );
      },
    );
  }
}