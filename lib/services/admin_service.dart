// services/admin_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get a stream of managers awaiting approval
  Stream<QuerySnapshot> getPendingManagerRequests() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'Manager')
        .where('status', isEqualTo: 'pending')
        .snapshots();
  }
  
  // Get a stream of all users (for the user management tab)
  Stream<QuerySnapshot> getAllUsers() {
    return _firestore.collection('users').snapshots();
  }

  // Approve a manager's request
  Future<void> approveManager(String uid) {
    return _firestore.collection('users').doc(uid).update({'status': 'approved'});
  }

  // Reject a manager's request (you can change status or delete)
  Future<void> rejectManager(String uid) {
    return _firestore.collection('users').doc(uid).update({'status': 'rejected'});
  }
}