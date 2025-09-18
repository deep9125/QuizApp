// screens/User/rewards_store_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/user_service.dart';
import '../../Model/reward_item.dart';

class RewardsStoreScreen extends StatefulWidget {
  const RewardsStoreScreen({super.key});

  @override
  State<RewardsStoreScreen> createState() => _RewardsStoreScreenState();
}

class _RewardsStoreScreenState extends State<RewardsStoreScreen> {
  final UserService _userService = UserService();
  final String? _userId = FirebaseAuth.instance.currentUser?.uid;
  late Future<List<RewardItem>> _rewardItemsFuture;

  @override
  void initState() {
    super.initState();
    _rewardItemsFuture = _userService.getRewardItems();
  }

  Future<void> _redeemItem(RewardItem item, int currentBalance) async {
    if (currentBalance < item.cost) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You do not have enough points!')),
      );
      return;
    }

    // Show a confirmation dialog before redeeming
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Redemption'),
        content: Text('Are you sure you want to redeem "${item.itemName}" for ${item.cost} points?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: const Text('Redeem'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final success = await _userService.redeemReward(_userId!, item);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Successfully redeemed ${item.itemName}!' : 'Redemption failed. Please try again.'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rewards Store'),
        actions: [
          if (_userId != null)
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('users').doc(_userId).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.exists) {
                  final rewards = (snapshot.data!.data() as Map<String, dynamic>)['rewards'] ?? 0;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Chip(
                      avatar: const Icon(Icons.star, color: Colors.amber, size: 18),
                      label: Text(rewards.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
        ],
      ),
      body: FutureBuilder<List<RewardItem>>(
        future: _rewardItemsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No reward items available.'));
          }

          final items = snapshot.data!;
          
          return StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('users').doc(_userId).snapshots(),
            builder: (context, userSnapshot) {
              final currentBalance = (userSnapshot.hasData && userSnapshot.data!.exists)
                ? (userSnapshot.data!.data() as Map<String, dynamic>)['rewards'] ?? 0
                : 0;

              return GridView.builder(
                padding: const EdgeInsets.all(16.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.75,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final canAfford = currentBalance >= item.cost;
                  return Card(
                    clipBehavior: Clip.antiAlias,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // FIXED: Displays the image from the URL if available, otherwise shows a fallback icon.
                          Expanded(
                            child: (item.imageUrl != null && item.imageUrl!.isNotEmpty)
                              ? Image.network(
                                  item.imageUrl!,
                                  fit: BoxFit.contain,
                                  loadingBuilder: (context, child, progress) {
                                    return progress == null ? child : const Center(child: CircularProgressIndicator());
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(Icons.broken_image, size: 50, color: Colors.grey);
                                  },
                                )
                              : const Icon(Icons.emoji_events, size: 50, color: Colors.orange),
                          ),
                          const SizedBox(height: 8),
                          Text(item.itemName, style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                          Text(item.description, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.star, size: 16),
                            label: Text(item.cost.toString()),
                            onPressed: canAfford ? () => _redeemItem(item, currentBalance) : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: canAfford ? Colors.deepPurple : Colors.grey,
                              foregroundColor: Colors.white
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          );
        },
      ),
    );
  }
}