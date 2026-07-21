import 'package:flutter/material.dart';
import 'package:loyaya/services/api_client.dart';
import 'package:loyaya/theme/app_theme.dart';

class LeaderboardTab extends StatefulWidget {
  const LeaderboardTab({
    super.key,
    required this.api,
    required this.loading,
  });

  final ApiClient api;
  final bool loading;

  @override
  State<LeaderboardTab> createState() => _LeaderboardTabState();
}

class _LeaderboardTabState extends State<LeaderboardTab> {
  List<Map<String, dynamic>> _rows = [];
  bool _fetching = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant LeaderboardTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.loading && oldWidget.loading) {
      _load();
    }
  }

  Future<void> _load() async {
    setState(() {
      _fetching = true;
      _error = null;
    });
    try {
      final rows = await widget.api.leaderboard();
      if (mounted) setState(() => _rows = rows);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = apiErrorMessage(e.error));
    } catch (_) {
      if (mounted) setState(() => _error = 'Could not load leaderboard.');
    } finally {
      if (mounted) setState(() => _fetching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final busy = widget.loading || _fetching;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.leaderboard, color: Colors.white),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Leaderboard',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Top users by lifetime points earned.',
                        style: TextStyle(color: AppColors.primary, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF263238), Color(0xFF455A64)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'WHO IS FIRST?',
                          style: TextStyle(
                            color: Color(0xFFFFEB3B),
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Collect points daily and climb the ranks!',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white,
                    child: Text(
                      'LSO',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (busy)
              const Center(child: CircularProgressIndicator())
            else if (_error != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(_error!, textAlign: TextAlign.center),
                ),
              )
            else
              Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    Container(
                      color: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      child: const Row(
                        children: [
                          Expanded(flex: 1, child: Text('No.', style: _headerStyle)),
                          Expanded(flex: 2, child: Text('Name', style: _headerStyle)),
                          Expanded(flex: 3, child: Text('Email', style: _headerStyle)),
                          Expanded(flex: 2, child: Text('Points', style: _headerStyle)),
                        ],
                      ),
                    ),
                    if (_rows.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('No rankings yet. Be the first to earn points!'),
                      )
                    else
                      for (final row in _rows)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.grey.shade200),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Text('${row['rank']}'),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(row['name']?.toString() ?? ''),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(row['email_masked']?.toString() ?? ''),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  _formatScore(row['score']),
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  static String _formatScore(dynamic value) {
    final n = value is int ? value : int.tryParse('$value') ?? 0;
    return n.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
  }

  static const _headerStyle = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    fontSize: 12,
  );
}
