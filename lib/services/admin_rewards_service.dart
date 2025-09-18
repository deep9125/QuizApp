// services/admin_rewards_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Model/reward_item.dart';

class AdminRewardsService {
  final CollectionReference _storeRef = FirebaseFirestore.instance.collection('rewards_store');

  /// Provides a real-time stream of all reward items.
  Stream<List<RewardItem>> getRewardItemsStream() {
    return _storeRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => RewardItem.fromFirestore(doc)).toList();
    });
  }

  /// Adds a new reward item to the store.
  Future<void> addRewardItem(RewardItem item) {
    return _storeRef.add({
      'itemName': item.itemName,
      'description': item.description,
      'cost': item.cost,
      'imageUrl': item.imageUrl,
    });
  }

  /// Updates an existing reward item.
  Future<void> updateRewardItem(RewardItem item) {
    return _storeRef.doc(item.id).update({
      'itemName': item.itemName,
      'description': item.description,
      'cost': item.cost,
      'imageUrl': item.imageUrl,
    });
  }

  /// Deletes a reward item from the store.
  Future<void> deleteRewardItem(String itemId) {
    return _storeRef.doc(itemId).delete();
  }
}