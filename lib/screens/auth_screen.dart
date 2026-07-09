import 'package:flutter/material.dart';
import 'package:loyaya/services/api_client.dart';
import 'package:loyaya/services/session_service.dart';
import 'package:loyaya/theme/app_theme.dart';

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
  String? _loadingMessage;

  @override
  void initState() {
    super.initState();
    widget.api.wakeServer();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _setLoadingMessage(String message) {
    if (mounted) setState(() => _loadingMessage = message);
  }

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = null;
      _loadingMessage = 'Connecting to server...';
    });

    final slowTimer = Future<void>.delayed(const Duration(seconds: 5), () {
      if (_loading) {
        _setLoadingMessage(
          'Server is starting up. First request can take up to 60 seconds...',
        );
      }
    });

    try {
      final Map<String, dynamic> result;
      if (_isLogin) {
        result = await widget.api.login(
          email: _emailController.text.trim().toLowerCase(),
          password: _passwordController.text,
        );
      } else {
        result = await widget.api.register(
          name: _nameController.text.trim(),
          email: _emailController.text.trim().toLowerCase(),
          password: _passwordController.text,
        );
      }

      final token = result['token'] as String;
      final user = result['user'] as Map<String, dynamic>;
      await widget.session.saveToken(token);
      await widget.session.saveUser(user);
      widget.api.setToken(token);
      widget.onLoggedIn();
    } on ApiException catch (e) {
      setState(() => _error = apiErrorMessage(e.error));
    } catch (_) {
      setState(() => _error = apiErrorMessage('NETWORK_ERROR'));
    } finally {
      await slowTimer;
      if (mounted) {
        setState(() {
          _loading = false;
          _loadingMessage = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.monetization_on,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Lotaya Shwe Oh',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                _isLogin ? 'Sign in to your account' : 'Create an account',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),
              if (!_isLogin)
                TextField(
                  controller: _nameController,
                  enabled: !_loading,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              if (!_isLogin) const SizedBox(height: 12),
              TextField(
                controller: _emailController,
                enabled: !_loading,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                enabled: !_loading,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: const TextStyle(color: AppColors.primary),
                  textAlign: TextAlign.center,
                ),
              ],
              if (_loading && _loadingMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  _loadingMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _loading ? null : _submit,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(_isLogin ? 'Sign In' : 'Sign Up'),
              ),
              TextButton(
                onPressed: _loading
                    ? null
                    : () => setState(() => _isLogin = !_isLogin),
                child: Text(
                  _isLogin
                      ? "Don't have an account? Sign up"
                      : 'Already have an account? Sign in',
                  style: const TextStyle(color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
