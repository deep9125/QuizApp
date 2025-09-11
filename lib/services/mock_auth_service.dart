// lib/services/mock_auth_service.dart

// Represents a dummy user model. In a real app, this would be more complex.
class DummyUser {
  final String uid;
  final String email;
  final String role; // e.g., 'admin', 'user'

  DummyUser({required this.uid, required this.email, required this.role});
}

class MockAuthService {
  // Hardcoded dummy admin credentials
  static const String _adminEmail = 'admin@example.com';
  static const String _adminPassword = 'password123';

  DummyUser? _currentUser;

  DummyUser? get currentUser => _currentUser;
  bool get isAdmin => _currentUser?.role == 'admin';

  Future<DummyUser?> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay

    if (email.toLowerCase() == _adminEmail && password == _adminPassword) {
      _currentUser = DummyUser(uid: 'dummy_admin_uid', email: _adminEmail, role: 'admin');
      return _currentUser;
    } else {
      // You could add more dummy users here if needed
      // e.g., else if (email == 'user@example.com' && password == 'userpass') ...
      _currentUser = null;
      return null; // Login failed
    }
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _currentUser = null;
  }
}
