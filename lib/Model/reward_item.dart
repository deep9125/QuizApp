// lib/Model/reward_item.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class RewardItem {
  final String id;
  final String itemName;
  final String description;
  final int cost;
  final String? imageUrl;

  RewardItem({
    required this.id,
    required this.itemName,
    required this.description,
    required this.cost,
    this.imageUrl,
  });

  factory RewardItem.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return RewardItem(
      id: doc.id,
      itemName: data['itemName'] ?? 'No Name',
      description: data['description'] ?? 'No Description',
      cost: data['cost'] ?? 9999,
      imageUrl: data['imageUrl'],
    );
  }
}