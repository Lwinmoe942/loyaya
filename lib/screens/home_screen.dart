import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loyaya/services/api_client.dart';
import 'package:loyaya/services/session_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.api,
    required this.session,
    required this.onLogout,
  });

  final ApiClient api;
  final SessionService session;
  final VoidCallback onLogout;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? _user;
  int _balance = 0;
  String _tier = 'bronze';
  String _publicId = '';
  bool _loading = true;
  String? _message;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _message = null;
    });
    try {
      final me = await widget.api.me();
      final balance = await widget.api.balance();
      final user = me['user'] as Map<String, dynamic>;
      setState(() {
        _user = user;
        _balance = balance['balance'] as int? ?? 0;
        _tier = balance['tier'] as String? ?? 'bronze';
        _publicId = user['public_id'] as String? ?? '';
      });
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        await widget.session.clear();
        widget.onLogout();
      } else {
        setState(() => _message = e.error);
      }
    } catch (_) {
      setState(() => _message = 'NETWORK_ERROR');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _checkIn() async {
    setState(() => _message = null);
    try {
      final result = await widget.api.dailyCheckIn();
      setState(() {
        _balance = result['balance'] as int? ?? _balance;
        _message = result['duplicate'] == true
            ? 'ယနေ့ check-in လုပ်ပြီးသား'
            : 'Check-in အောင်မြင်! +10 points';
      });
      await _load();
    } on ApiException catch (e) {
      setState(() {
        _message = e.error == 'ALREADY_CLAIMED_TODAY'
            ? 'ယနေ့ check-in လုပ်ပြီးသား'
            : e.error;
      });
    }
  }

  Future<void> _copyId() async {
    await Clipboard.setData(ClipboardData(text: _publicId));
    setState(() => _message = 'ID ကူးပြီးပါပြီ');
  }

  Future<void> _logout() async {
    await widget.session.clear();
    widget.api.setToken(null);
    widget.onLogout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E7),
      appBar: AppBar(
        title: const Text('Lotaya Shwe Oh'),
        backgroundColor: const Color(0xFFD4A017),
        foregroundColor: Colors.white,
        actions: [
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout)),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Text(
                            '$_balance',
                            style: Theme.of(context)
                                .textTheme
                                .displaySmall
                                ?.copyWith(
                                  color: const Color(0xFFB8860B),
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const Text('Points'),
                          const SizedBox(height: 8),
                          Chip(label: Text('Tier: $_tier')),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: ListTile(
                      title: const Text('Your ID'),
                      subtitle: Text(_publicId),
                      trailing: IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: _copyId,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: _checkIn,
                    icon: const Icon(Icons.calendar_today),
                    label: const Text('Daily Check-in (+10)'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFB8860B),
                      minimumSize: const Size.fromHeight(48),
                    ),
                  ),
                  if (_message != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _message!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _message!.contains('အောင်မြင်')
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  if (_user != null)
                    Text(
                      'မင်္ဂလာပါ, ${_user!['name']}',
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
            ),
    );
  }
}
