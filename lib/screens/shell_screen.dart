import 'package:flutter/material.dart';
import 'package:loyaya/screens/tabs/classroom_tab.dart';
import 'package:loyaya/screens/tabs/home_tab.dart';
import 'package:loyaya/screens/tabs/leaderboard_tab.dart';
import 'package:loyaya/screens/tabs/profile_tab.dart';
import 'package:loyaya/services/api_client.dart';
import 'package:loyaya/services/progress_service.dart';
import 'package:loyaya/services/session_service.dart';
import 'package:loyaya/theme/app_theme.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({
    super.key,
    required this.api,
    required this.session,
    required this.progress,
    required this.onLogout,
  });

  final ApiClient api;
  final SessionService session;
  final ProgressService progress;
  final VoidCallback onLogout;

  @override
  State<ShellScreen> createState() => ShellScreenState();
}

class ShellScreenState extends State<ShellScreen> {
  int _tabIndex = 0;
  Map<String, dynamic>? _user;
  int _balance = 0;
  int _rate = 3;
  String _tier = 'bronze';
  String _publicId = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCachedUser();
    refresh();
  }

  Future<void> _loadCachedUser() async {
    final cached = await widget.session.loadUser();
    if (cached != null && mounted) {
      setState(() {
        _user = cached;
        _publicId = cached['public_id'] as String? ?? '';
      });
    }
  }

  Future<void> refresh() async {
    setState(() => _loading = true);
    try {
      final me = await widget.api.me();
      final balance = await widget.api.balance();
      final history = await widget.api.history();
      final user = me['user'] as Map<String, dynamic>;
      await widget.session.saveUser(user);
      await widget.progress.syncFromHistory(history);
      await widget.progress.syncLocksFromApi(widget.api);
      if (mounted) {
        setState(() {
          _user = user;
          _balance = balance['balance'] as int? ?? 0;
          _tier = balance['tier'] as String? ?? 'bronze';
          _rate = balance['rate'] as int? ?? 3;
          _publicId = user['public_id'] as String? ?? '';
        });
      }
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        await widget.session.clear();
        widget.onLogout();
      }
    } catch (_) {
      // Keep last known data on transient errors.
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _logout() async {
    await widget.session.clear();
    widget.api.setToken(null);
    widget.onLogout();
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      HomeTab(
        api: widget.api,
        balance: _balance,
        tier: _tier,
        rate: _rate,
        loading: _loading,
        onRefresh: refresh,
      ),
      LeaderboardTab(loading: _loading),
      ClassroomTab(balance: _balance, loading: _loading),
      ProfileTab(
        user: _user,
        balance: _balance,
        publicId: _publicId,
        onLogout: _logout,
        onRefresh: refresh,
      ),
    ];

    return Scaffold(
      body: IndexedStack(index: _tabIndex, children: tabs),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tabIndex,
        onTap: (i) => setState(() => _tabIndex = i),
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.primary,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events),
            label: 'Leaderboard',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Classroom'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
