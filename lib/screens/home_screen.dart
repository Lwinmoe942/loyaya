import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loyaya/config/api_config.dart';
import 'package:loyaya/screens/math_quiz_screen.dart';
import 'package:loyaya/services/api_client.dart';
import 'package:loyaya/services/session_service.dart';
import 'package:url_launcher/url_launcher.dart';

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
  int _rate = 3;
  String _tier = 'bronze';
  String _publicId = '';
  List<Map<String, dynamic>> _history = [];
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
      final history = await widget.api.history();
      final user = me['user'] as Map<String, dynamic>;
      setState(() {
        _user = user;
        _balance = balance['balance'] as int? ?? 0;
        _tier = balance['tier'] as String? ?? 'bronze';
        _rate = balance['rate'] as int? ?? 3;
        _publicId = user['public_id'] as String? ?? '';
        _history = history;
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
            ? 'Already checked in today'
            : 'Check-in successful! +10 points';
      });
      await _load();
    } on ApiException catch (e) {
      setState(() {
        _message = e.error == 'ALREADY_CLAIMED_TODAY'
            ? 'Already checked in today'
            : e.error;
      });
    }
  }

  Future<void> _copyId() async {
    await Clipboard.setData(ClipboardData(text: _publicId));
    setState(() => _message = 'ID copied to clipboard');
  }

  Future<void> _openExchangeInfo() async {
    final uri = Uri.parse(ApiConfig.exchangeUrl);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      setState(() => _message = 'Could not open exchange page');
    }
  }

  Future<void> _openQuiz() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MathQuizScreen(api: widget.api),
      ),
    );
    await _load();
  }

  Future<void> _logout() async {
    await widget.session.clear();
    widget.api.setToken(null);
    widget.onLogout();
  }

  String _historyLabel(Map<String, dynamic> row) {
    final type = row['type'] as String? ?? '';
    final amount = row['amount'] as int? ?? 0;
    final sign = amount >= 0 ? '+' : '';
    return '$type $sign$amount';
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
                          Chip(label: Text('Tier: $_tier · 1 pt = $_rate MMK')),
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
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Redeem Points',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Redemption is not available inside the app. '
                            'Copy your ID and redeem on the exchange website.',
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _copyId,
                                  icon: const Icon(Icons.copy),
                                  label: const Text('ID Copy'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: FilledButton.icon(
                                  onPressed: _openExchangeInfo,
                                  icon: const Icon(Icons.open_in_new),
                                  label: const Text('Exchange'),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: const Color(0xFFB8860B),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
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
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _openQuiz,
                    icon: const Icon(Icons.calculate),
                    label: const Text('Math Quiz (+2)'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                  ),
                  if (_message != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _message!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _message!.contains('successful') ||
                                _message!.contains('copied')
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  if (_history.isNotEmpty) ...[
                    const Text(
                      'Recent Activity',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _history.length.clamp(0, 10),
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, i) {
                          final row = _history[i];
                          final amount = row['amount'] as int? ?? 0;
                          return ListTile(
                            dense: true,
                            title: Text(_historyLabel(row)),
                            subtitle: Text(
                              row['created_at']?.toString() ?? '',
                            ),
                            trailing: Text(
                              '${amount >= 0 ? '+' : ''}$amount',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: amount >= 0
                                    ? Colors.green.shade700
                                    : Colors.red.shade700,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  if (_user != null)
                    Text(
                      'Welcome, ${_user!['name']}',
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
            ),
    );
  }
}
