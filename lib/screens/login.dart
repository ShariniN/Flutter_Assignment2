import 'package:flutter/material.dart';
import 'package:assignment1/services/api_service.dart';
import 'package:assignment1/models/user.dart';
import 'package:assignment1/services/cart_manager.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'home_screen.dart';


class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();

  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();

  final _registerNameController = TextEditingController();
  final _registerEmailController = TextEditingController();
  final _registerPasswordController = TextEditingController();

  bool _isLogin = true;
  bool _loading = false;

  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _handleLogin() async {
    if (_loginFormKey.currentState!.validate()) {
      setState(() => _loading = true);
      try {
        User user = await _apiService.login(
          _loginEmailController.text.trim(),
          _loginPasswordController.text.trim(),
        );

        // Save token securely
        if (user.token != null) {
          await _secureStorage.write(key: 'auth_token', value: user.token);
        }

        _showMessage("Welcome back, ${user.name}!");

        // Load cart after successful login
        if (mounted) {
          await Provider.of<CartManager>(context, listen: false).loadCart();
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen()),
        );
      } catch (e) {
        _showMessage("Login failed: $e");
      } finally {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _handleRegister() async {
    if (_registerFormKey.currentState!.validate()) {
      setState(() => _loading = true);
      try {
        User user = await _apiService.register(
          _registerNameController.text.trim(),
          _registerEmailController.text.trim(),
          _registerPasswordController.text.trim(),
        );

        // Save token securely
        if (user.token != null) {
          await _secureStorage.write(key: 'auth_token', value: user.token);
        }

        _showMessage("Account created! Welcome, ${user.name}!");

        // Load cart after successful registration
        if (mounted) {
          await Provider.of<CartManager>(context, listen: false).loadCart();
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen()),
        );
      } catch (e) {
        _showMessage("Registration failed: $e");
      } finally {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () => setState(() => _isLogin = true),
                          child: Text(
                            "Login",
                            style: TextStyle(
                              fontWeight: _isLogin ? FontWeight.bold : FontWeight.normal,
                              color: _isLogin ? theme.primaryColor : Colors.grey,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => setState(() => _isLogin = false),
                          child: Text(
                            "Register",
                            style: TextStyle(
                              fontWeight: !_isLogin ? FontWeight.bold : FontWeight.normal,
                              color: !_isLogin ? theme.primaryColor : Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: SingleChildScrollView(
                        child: _isLogin
                            ? _buildLoginForm(theme)
                            : _buildRegisterForm(theme),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildLoginForm(ThemeData theme) {
    return Form(
      key: _loginFormKey,
      child: Column(
        children: [
          TextFormField(
            controller: _loginEmailController,
            decoration: const InputDecoration(labelText: "Email"),
            validator: (value) => value!.isEmpty ? "Enter email" : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _loginPasswordController,
            decoration: const InputDecoration(labelText: "Password"),
            obscureText: true,
            validator: (value) => value!.isEmpty ? "Enter password" : null,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _handleLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text(
              "Login",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterForm(ThemeData theme) {
    return Form(
      key: _registerFormKey,
      child: Column(
        children: [
          TextFormField(
            controller: _registerNameController,
            decoration: const InputDecoration(labelText: "Full Name"),
            validator: (value) => value!.isEmpty ? "Enter your name" : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _registerEmailController,
            decoration: const InputDecoration(labelText: "Email"),
            validator: (value) => value!.isEmpty ? "Enter email" : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _registerPasswordController,
            decoration: const InputDecoration(labelText: "Password"),
            obscureText: true,
            validator: (value) => value!.isEmpty ? "Enter password" : null,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _handleRegister,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text(
              "Create Account",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}