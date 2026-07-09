import 'package:flutter/material.dart';
import 'package:loyaya/screens/auth_screen.dart';
import 'package:loyaya/screens/home_screen.dart';
import 'package:loyaya/services/api_client.dart';
import 'package:loyaya/services/session_service.dart';

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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD4A017),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
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
      } catch (_) {
        await _session.clear();
        _api.setToken(null);
      }
    }
    if (mounted) {
      setState(() {
        _ready = true;
        _bootMessage = null;
      });
    }
  }

  void _onLoggedIn() => setState(() => _loggedIn = true);

  void _onLogout() => setState(() => _loggedIn = false);

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              if (_bootMessage != null) ...[
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    _bootMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Color(0xFF6B5F4D)),
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

    return HomeScreen(
      api: _api,
      session: _session,
      onLogout: _onLogout,
    );
  }
}
