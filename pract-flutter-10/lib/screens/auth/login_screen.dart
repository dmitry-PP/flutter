import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await _authService.signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );
    } catch (e) {
      setState(() => _error = _friendlyError(e.toString()));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _friendlyError(String raw) {
    if (raw.contains('user-not-found')) return 'Пользователь не найден';
    if (raw.contains('wrong-password') || raw.contains('invalid-credential')) {
      return 'Неверный email или пароль';
    }
    if (raw.contains('invalid-email')) return 'Неверный формат email';
    return 'Ошибка входа. Проверьте данные';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Динамический фон
          Positioned.fill(
            child: Container(
              color: const Color(0xFF08080A),
            ),
          ),
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF6C63FF).withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00E5FF).withOpacity(0.05),
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
                      // Логотип с неоновым свечением
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00E5FF).withOpacity(0.2),
                              blurRadius: 40,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.blur_on_rounded,
                          size: 80,
                          color: Color(0xFF00E5FF),
                        ),
                      ),
                      const SizedBox(height: 48),
                      const Text(
                        'NINEPRAKT',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 8,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'ENTER THE GRID',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4,
                          color: const Color(0xFF6C63FF).withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 64),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          hintText: 'IDENTIFIER (EMAIL)',
                          prefixIcon: Icon(Icons.alternate_email_rounded, size: 20),
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
                          hintText: 'ACCESS KEY (PASSWORD)',
                          prefixIcon: Icon(Icons.vpn_key_rounded, size: 20),
                        ),
                        obscureText: true,
                        style: const TextStyle(letterSpacing: 4, fontSize: 14),
                        validator: (v) => v == null || v.length < 6
                            ? 'KEY TOO SHORT'
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
                          ? const CircularProgressIndicator(color: Color(0xFF00E5FF))
                          : SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: _login,
                                child: const Text('INITIALIZE'),
                              ),
                            ),
                      const SizedBox(height: 32),
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RegisterScreen(),
                          ),
                        ),
                        child: Text(
                          'NEW USER? REGISTER_ACCOUNT',
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
