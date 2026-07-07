import 'package:flutter/material.dart';
import 'package:loyaya/services/api_client.dart';
import 'package:loyaya/services/session_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({
    super.key,
    required this.api,
    required this.session,
    required this.onLoggedIn,
  });

  final ApiClient api;
  final SessionService session;
  final VoidCallback onLoggedIn;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final Map<String, dynamic> result;
      if (_isLogin) {
        result = await widget.api.login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      } else {
        result = await widget.api.register(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      }

      final token = result['token'] as String;
      await widget.session.saveToken(token);
      widget.api.setToken(token);
      widget.onLoggedIn();
    } on ApiException catch (e) {
      setState(() => _error = e.error);
    } catch (_) {
      setState(() => _error = 'NETWORK_ERROR');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Text(
                'Lotaya Shwe Oh',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: const Color(0xFFB8860B),
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                _isLogin ? 'အကောင့်ဝင်ပါ' : 'အကောင့်ဖွင့်ပါ',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              if (!_isLogin)
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'အမည်',
                    border: OutlineInputBorder(),
                  ),
                ),
              if (!_isLogin) const SizedBox(height: 12),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _loading ? null : _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFB8860B),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_isLogin ? 'ဝင်မယ်' : 'ဖွင့်မယ်'),
              ),
              TextButton(
                onPressed: _loading
                    ? null
                    : () => setState(() => _isLogin = !_isLogin),
                child: Text(
                  _isLogin
                      ? 'အကောင့်မရှိသေးဘူး? ဖွင့်မယ်'
                      : 'အကောင့်ရှိပြီးသား? ဝင်မယ်',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
