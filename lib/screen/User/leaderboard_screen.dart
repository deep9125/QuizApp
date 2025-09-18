// screens/User/leaderboard_screen.dart
import 'package:flutter/material.dart';
import '../../services/user_service.dart';
import '../../Model/quiz_user.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final UserService _userService = UserService();
  late Future<List<QuizUser>> _leaderboardFuture;

  @override
  void initState() {
    super.initState();
    _leaderboardFuture = _userService.getLeaderboardUsers();
  }

  Widget _getRankIcon(int rank) {
    if (rank == 1) return const Icon(Icons.emoji_events, color: Colors.amber);
    if (rank == 2) return Icon(Icons.emoji_events, color: Colors.grey[400]);
    if (rank == 3) return Icon(Icons.emoji_events, color: Color(0xFFCD7F32));
    return Text('${rank}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Leaderboard')),
      body: FutureBuilder<List<QuizUser>>(
        future: _leaderboardFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Leaderboard data is not available yet.'));
          }

          final users = snapshot.data!;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final rank = index + 1;
              return ListTile(
                leading: CircleAvatar(
                  child: _getRankIcon(rank),
                ),
                title: Text(user.email),
                trailing: Text(
                  user.rewards.toString(),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              );
            },
          );
        },
      ),
    );
  }
}