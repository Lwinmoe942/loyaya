import 'package:flutter/material.dart';
import 'package:loyaya/screens/auth_screen.dart';
import 'package:loyaya/screens/region_blocked_screen.dart';
import 'package:loyaya/screens/shell_screen.dart';
import 'package:loyaya/services/ad_service.dart';
import 'package:loyaya/services/api_client.dart';
import 'package:loyaya/services/device_region_service.dart';
import 'package:loyaya/services/progress_service.dart';
import 'package:loyaya/services/session_service.dart';
import 'package:loyaya/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AdService.instance.init();
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
  final _deviceRegion = DeviceRegionService();
  bool _ready = false;
  bool _loggedIn = false;
  bool _regionAllowed = true;
  String? _bootMessage;
  String? _regionMessage;
  String? _regionCountry;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    setState(() {
      _ready = false;
      _bootMessage = 'Connecting to server...';
      _regionAllowed = true;
      _regionMessage = null;
      _regionCountry = null;
    });

    final wakeFuture = _api.wakeServer();
    final token = await _session.loadToken();

    await wakeFuture;

    setState(() => _bootMessage = 'Checking region...');

    final regionOk = await _checkRegionAccess();
    if (!regionOk) {
      if (mounted) {
        setState(() {
          _ready = true;
          _bootMessage = null;
          _loggedIn = false;
        });
      }
      return;
    }

    if (token != null) {
      _api.setToken(token);
      try {
        await _api.me();
        _loggedIn = true;
        await _syncProgress();
      } on ApiException catch (e) {
        if (e.error == 'REGION_BLOCKED') {
          _regionAllowed = false;
          _regionMessage = apiErrorMessage(e.error);
          _loggedIn = false;
        } else if (e.statusCode == 401) {
          await _session.clear();
          _api.setToken(null);
        } else {
          _loggedIn = true;
        }
      } catch (_) {
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

  Future<bool> _checkRegionAccess() async {
    // 1) Device-side check (phone's real public IP)
    final deviceCountry = await _deviceRegion.lookupCountryCode();
    if (_deviceRegion.isBlockedCountry(deviceCountry)) {
      _regionAllowed = false;
      _regionCountry = deviceCountry;
      _regionMessage = apiErrorMessage('REGION_BLOCKED');
      return false;
    }

    // 2) Server-side check (Laravel /api/region)
    try {
      final region = await _api.checkRegion();
      final allowed = region['allowed'] == true;
      final serverCountry = region['country']?.toString();
      _regionCountry = serverCountry ?? deviceCountry;

      if (!allowed || _deviceRegion.isBlockedCountry(serverCountry)) {
        _regionAllowed = false;
        _regionMessage =
            region['message']?.toString() ?? apiErrorMessage('REGION_BLOCKED');
        return false;
      }

      if ((serverCountry == null || serverCountry.isEmpty) &&
          (deviceCountry == null || deviceCountry.isEmpty)) {
        _regionAllowed = false;
        _regionMessage =
            'Could not verify your region. Please connect a VPN and try again.';
        return false;
      }

      _regionAllowed = true;
      _regionMessage = null;
      return true;
    } on ApiException catch (e) {
      if (e.error == 'REGION_BLOCKED') {
        _regionAllowed = false;
        _regionMessage = apiErrorMessage(e.error);
        return false;
      }

      if (deviceCountry != null && deviceCountry.isNotEmpty) {
        _regionAllowed = true;
        _regionCountry = deviceCountry;
        return true;
      }

      _regionAllowed = false;
      _regionMessage =
          'Could not verify your region. Please connect a VPN and try again.';
      return false;
    } catch (_) {
      if (deviceCountry != null && deviceCountry.isNotEmpty) {
        _regionAllowed = !_deviceRegion.isBlockedCountry(deviceCountry);
        _regionCountry = deviceCountry;
        if (!_regionAllowed) {
          _regionMessage = apiErrorMessage('REGION_BLOCKED');
        }
        return _regionAllowed;
      }

      _regionAllowed = false;
      _regionMessage =
          'Could not verify your region. Please connect a VPN and try again.';
      return false;
    }
  }

  Future<void> _syncProgress() async {
    try {
      final history = await _api.history();
      await _progress.syncFromHistory(history);
      await _progress.syncLocksFromApi(_api);
    } catch (_) {}
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

    if (!_regionAllowed) {
      return RegionBlockedScreen(
        message:
            _regionMessage ??
            'Lotaya Shwe Oh is not available from Myanmar network locations. Please connect a VPN and try again.',
        country: _regionCountry,
        onRetry: _bootstrap,
      );
    }

    if (!_loggedIn) {
      return AuthScreen(api: _api, session: _session, onLoggedIn: _onLoggedIn);
    }

    return ShellScreen(
      api: _api,
      session: _session,
      progress: _progress,
      onLogout: _onLogout,
    );
  }
}
