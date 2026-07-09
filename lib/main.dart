import 'package:flutter/material.dart';
import 'package:loyaya/screens/auth_screen.dart';
import 'package:loyaya/screens/shell_screen.dart';
import 'package:loyaya/services/api_client.dart';
import 'package:loyaya/services/progress_service.dart';
import 'package:loyaya/services/session_service.dart';
import 'package:loyaya/theme/app_theme.dart';

void main() {
  runApp(const LotayaShweOhApp());
}

class LotayaShweOhApp extends StatelessWidget {
  const LotayaShweOhApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lotaya Shwe Oh',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const AppRoot(),
    );
  }
}

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  final _api = ApiClient();
  final _session = SessionService();
  final _progress = ProgressService();
  bool _ready = false;
  bool _loggedIn = false;
  String? _bootMessage;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    setState(() => _bootMessage = 'Connecting to server...');

    final wakeFuture = _api.wakeServer();
    final token = await _session.loadToken();

    await wakeFuture;

    if (token != null) {
      _api.setToken(token);
      try {
        await _api.me();
        _loggedIn = true;
        await _syncProgress();
      } on ApiException catch (e) {
        if (e.statusCode == 401) {
          await _session.clear();
          _api.setToken(null);
        } else {
          // Keep session on temporary server errors.
          _loggedIn = true;
        }
      } catch (_) {
        // Keep session when offline or server is waking up.
        _loggedIn = true;
      }
    }
    if (mounted) {
      setState(() {
        _ready = true;
        _bootMessage = null;
      });
    }
  }

  Future<void> _syncProgress() async {
    try {
      final history = await _api.history();
      await _progress.syncFromHistory(history);
    } catch (_) {
      // Non-blocking.
    }
  }

  void _onLoggedIn() {
    setState(() => _loggedIn = true);
    _syncProgress();
  }

  void _onLogout() => setState(() => _loggedIn = false);

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: AppColors.primary),
              if (_bootMessage != null) ...[
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    _bootMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    if (!_loggedIn) {
      return AuthScreen(
        api: _api,
        session: _session,
        onLoggedIn: _onLoggedIn,
      );
    }

    return ShellScreen(
      api: _api,
      session: _session,
      progress: _progress,
      onLogout: _onLogout,
    );
  }
}
