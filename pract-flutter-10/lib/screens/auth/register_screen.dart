import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await _authService.register(
        _emailController.text.trim(),
        _passwordController.text,
      );
      // После регистрации Firebase автоматически авторизует пользователя,
      // StreamBuilder в main.dart перенаправит на PostsListScreen
    } catch (e) {
      setState(() => _error = _friendlyError(e.toString()));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _friendlyError(String raw) {
    if (raw.contains('email-already-in-use')) return 'Email уже используется';
    if (raw.contains('invalid-email')) return 'Неверный формат email';
    if (raw.contains('weak-password')) return 'Слишком слабый пароль';
    return raw;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: const Color(0xFF08080A),
            ),
          ),
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00E5FF).withOpacity(0.08),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6C63FF).withOpacity(0.2),
                              blurRadius: 40,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.connect_without_contact_rounded,
                          size: 80,
                          color: Color(0xFF6C63FF),
                        ),
                      ),
                      const SizedBox(height: 48),
                      const Text(
                        'NEW_ORIGIN',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 8,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'CREATE IDENTITY',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4,
                          color: const Color(0xFF00E5FF).withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 64),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          hintText: 'NEW_IDENTIFIER (EMAIL)',
                          prefixIcon: Icon(Icons.email_outlined, size: 20),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(letterSpacing: 1.5, fontSize: 14),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'IDENTIFIER REQUIRED' : null,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                          hintText: 'SECURE_KEY (PASSWORD)',
                          prefixIcon: Icon(Icons.security_rounded, size: 20),
                        ),
                        obscureText: true,
                        style: const TextStyle(letterSpacing: 4, fontSize: 14),
                        validator: (v) => v == null || v.length < 6
                            ? 'KEY TOO WEAK'
                            : null,
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 24),
                        Text(
                          _error!.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      const SizedBox(height: 48),
                      _isLoading
                          ? const CircularProgressIndicator(color: Color(0xFF6C63FF))
                          : SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: _register,
                                child: const Text('GENERATE'),
                              ),
                            ),
                      const SizedBox(height: 32),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'EXISTING USER? RETURN_TO_LOGIN',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 10,
                            letterSpacing: 2,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
