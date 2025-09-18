// screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_auth_service.dart';
import 'Manager/dashboard_screen.dart';
import 'User/dashboard_screen.dart';
import 'Admin/dashboard_screen.dart';
import 'Manager/pending_approval_screen.dart'; // FIXED: Added missing import

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuthService _authService = FirebaseAuthService();

  bool _isLoading = false;
  String? _errorMessage;
  bool _isLoginMode = true;
  String _selectedRole = 'User';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      User? user;
      if (_isLoginMode) {
        user = await _authService.loginWithEmailPassword(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
        if (user != null) {
          await _navigateToDashboardByRole(user);
        }
      } else {
        user = await _authService.registerWithEmailPassword(
          _emailController.text.trim(),
          _passwordController.text.trim(),
          _selectedRole,
        );
        if (user != null) {
          // FIXED: Pass both the role and the initial status after registration
          String initialStatus = _selectedRole == 'Manager' ? 'pending' : 'approved';
          _navigateDirectlyToDashboard(_selectedRole, initialStatus);
        }
      }

      if (mounted) {
         setState(() => _isLoading = false);
      }

      if (user == null && mounted) {
        setState(() {
          _errorMessage = _isLoginMode
              ? 'Login failed. Please check your credentials.'
              : 'Registration failed. The email might already be in use.';
        });
      }
    }
  }

  void _toggleMode() {
    setState(() {
      _isLoginMode = !_isLoginMode;
      _errorMessage = null;
    });
  }

  Future<void> _navigateToDashboardByRole(User user) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        final role = data['role'] ?? 'User'; // Default to User if role is null
        final status = data['status'] ?? 'pending'; // Default to pending if status is null
        _navigateDirectlyToDashboard(role, status);
      } else {
        if(mounted) setState(() => _errorMessage = "User details not found.");
        FirebaseAuthService().signOut();
      }
    } catch (e) {
      if(mounted) setState(() => _errorMessage = "Could not verify user role.");
    }
  }

  void _navigateDirectlyToDashboard(String role, String status) {
    // Ensure navigation happens only if the widget is still mounted
    if (!mounted) return;

    if (role == 'admin') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminDashboardScreen()));
    } else if (role == 'Manager' && status == 'approved') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) =>  ManagerDashboardScreen()));
    } else if (role == 'Manager' && (status == 'pending' || status == 'rejected')) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const PendingApprovalScreen()));
    } else if (role == 'User' && status == 'approved') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) =>  UserDashboardScreen()));
    } else {
      FirebaseAuthService().signOut();
      // Setting state here might not be visible if sign-out triggers rebuild
      // The login screen will reappear with no error message, which is fine.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLoginMode ? 'Login' : 'Sign Up'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  _isLoginMode ? 'Welcome Back!' : 'Create an Account',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 32.0),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => (v == null || !v.contains('@')) ? 'Please enter a valid email' : null,
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: (v) => (v == null || v.length < 6) ? 'Password must be at least 6 characters' : null,
                ),
                if (!_isLoginMode) ...[
                  const SizedBox(height: 16.0),
                  DropdownButtonFormField<String>(
                    value: _selectedRole,
                    decoration: InputDecoration(
                      labelText: 'Select Role',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                      prefixIcon: const Icon(Icons.person_outline),
                    ),
                    items: ['User', 'Manager'].map((String role) {
                      return DropdownMenuItem<String>(value: role, child: Text(role));
                    }).toList(),
                    onChanged: (newValue) => setState(() => _selectedRole = newValue!),
                  ),
                ],
                const SizedBox(height: 24.0),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(_errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
                  ),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton.icon(
                        icon: Icon(_isLoginMode ? Icons.login_rounded : Icons.person_add),
                        label: Text(_isLoginMode ? 'Login' : 'Sign Up'),
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14.0),
                          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                        ),
                      ),
                TextButton(
                  onPressed: _toggleMode,
                  child: Text(
                    _isLoginMode
                        ? 'Don\'t have an account? Sign Up'
                        : 'Already have an account? Login',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}