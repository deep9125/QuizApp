// screens/Admin/manage_rewards_screen.dart
import 'package:flutter/material.dart';
import '../../services/admin_rewards_service.dart';
import '../../Model/reward_item.dart';
import 'add_edit_reward_screen.dart';

class AdminManageRewardsScreen extends StatefulWidget {
  const AdminManageRewardsScreen({super.key});

  @override
  State<AdminManageRewardsScreen> createState() => _AdminManageRewardsScreenState();
}

class _AdminManageRewardsScreenState extends State<AdminManageRewardsScreen> {
  final AdminRewardsService _rewardsService = AdminRewardsService();

  void _navigateToAddOrEdit([RewardItem? item]) async {
    final result = await Navigator.push<RewardItem>(
      context,
      MaterialPageRoute(builder: (context) => AddEditRewardScreen(itemToEdit: item)),
    );

    if (result != null) {
      if (item != null) { // Editing
        await _rewardsService.updateRewardItem(result);
      } else { // Adding
        await _rewardsService.addRewardItem(result);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Rewards Store')),
      body: StreamBuilder<List<RewardItem>>(
        stream: _rewardsService.getRewardItemsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No reward items found.'));
          }

          final items = snapshot.data!;
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                leading: const Icon(Icons.card_giftcard),
                title: Text(item.itemName),
                subtitle: Text('${item.cost} points'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _navigateToAddOrEdit(item),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _rewardsService.deleteRewardItem(item.id),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddOrEdit,
        child: const Icon(Icons.add),
        tooltip: 'Add New Reward Item',
      ),
    );
  }
}