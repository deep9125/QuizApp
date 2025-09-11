// screens/login_screen.dart
import 'package:flutter/material.dart';
import '../services/mock_auth_service.dart'; // Import your auth service
import './Admin/dashboard_screen.dart';   // Import the Admin Dashboard

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  // Initialize controllers here
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final MockAuthService _authService = MockAuthService();

  bool _isLoading = false;
  String? _errorMessage;

  // --- ADD initState to set default values ---
  @override
  void initState() {
    super.initState();
   _emailController.text = 'admin@example.com';
    _passwordController.text = 'password123';
  }
  // --- End of initState ---

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loginUser() async {
    // Hide keyboard when login is attempted
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Use the values from the controllers
      final user = await _authService.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      // Check if the widget is still mounted before calling setState
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (user != null && _authService.isAdmin) {
        // Navigate to Admin Dashboard on successful admin login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminDashboardScreen()), // AdminDashboardScreen might not be const
        );
      } else {
        if (!mounted) return;
        setState(() {
          _errorMessage = 'Invalid email or password, or not an admin.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Login'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
                  'Welcome, Admin!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 32.0), // Increased spacing
                TextFormField(
                  controller: _emailController, // Controller is already initialized
                  decoration: InputDecoration(
                    labelText: 'Email',

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0), // Softer corners
                    ),
                    prefixIcon: const Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email], // For autofill
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    // Basic email validation: contains '@' and '.'
                    if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _passwordController, // Controller is already initialized
                  decoration: InputDecoration(
                    labelText: 'Password',
                    // hintText: 'password123', // Hint text is less necessary if pre-filled
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    prefixIcon: const Icon(Icons.lock_outline),
                    // TODO: Add a suffix icon to toggle password visibility
                  ),
                  obscureText: true,
                  autofillHints: const [AutofillHints.password], // For autofill
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24.0),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0), // Increased padding
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 14,
                          fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
                  ),
                _isLoading
                    ? const Center(child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0), // Add padding around indicator
                  child: CircularProgressIndicator(),
                ))
                    : ElevatedButton.icon(
                  icon: const Icon(Icons.login_rounded), // Slightly different icon
                  label: const Text('Login'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14.0), // Increased padding
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    backgroundColor: Theme.of(context).colorScheme.primary, // Themed button
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0), // Match text field borders
                    ),
                  ),
                  onPressed: _loginUser,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

