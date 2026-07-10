import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:loyaya/services/ad_service.dart';
import 'package:loyaya/services/api_client.dart';
import 'package:loyaya/theme/app_theme.dart';
import 'package:loyaya/widgets/dinga_page_header.dart';

class TicTacToeScreen extends StatefulWidget {
  const TicTacToeScreen({super.key, required this.api});

  final ApiClient api;

  @override
  State<TicTacToeScreen> createState() => _TicTacToeScreenState();
}

class _TicTacToeScreenState extends State<TicTacToeScreen> {
  static const _cooldownMinutes = 5;

  late String _matchId;
  final List<String?> _board = List.filled(9, null);
  bool _loading = true;
  int _cooldownSeconds = 0;
  Timer? _cooldownTimer;
  bool _userTurn = true;
  bool _gameOver = false;
  bool _claiming = false;
  bool _bonusClaimed = false;
  bool _winClaimed = false;
  String? _status;

  bool get _onCooldown => _cooldownSeconds > 0;

  @override
  void initState() {
    super.initState();
    _matchId = _newMatchId();
    _loadStatus();
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }

  String _newMatchId() =>
      '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(99999)}';

  Future<void> _loadStatus() async {
    setState(() => _loading = true);
    try {
      final status = await widget.api.gamesStatus();
      if (mounted) {
        _applyCooldown(status['tic_tac_toe_cooldown_seconds'] as int? ?? 0);
        setState(() => _loading = false);
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _status = apiErrorMessage(e.error);
        });
      }
    }
  }

  void _applyCooldown(int seconds) {
    _cooldownTimer?.cancel();
    _cooldownSeconds = seconds.clamp(0, _cooldownMinutes * 60);
    if (_cooldownSeconds <= 0) return;

    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _cooldownSeconds = (_cooldownSeconds - 1).clamp(0, _cooldownMinutes * 60);
      });
      if (_cooldownSeconds <= 0) {
        _cooldownTimer?.cancel();
      }
    });
  }

  String _formatCooldown(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes}m ${seconds.toString().padLeft(2, '0')}s';
  }

  void _reset() {
    if (_onCooldown) return;
    setState(() {
      _matchId = _newMatchId();
      _board.fillRange(0, 9, null);
      _userTurn = true;
      _gameOver = false;
      _bonusClaimed = false;
      _winClaimed = false;
      _status = null;
    });
  }

  void _tapCell(int index) {
    if (_onCooldown || _loading || _gameOver || !_userTurn || _board[index] != null) {
      return;
    }

    setState(() {
      _board[index] = 'X';
      _userTurn = false;
    });

    final winner = _checkWinner();
    if (winner != null) {
      _finishGame(winner);
      return;
    }
    if (!_board.contains(null)) {
      _finishGame('draw');
      return;
    }

    Future.delayed(const Duration(milliseconds: 400), _aiMove);
  }

  void _aiMove() {
    if (!mounted || _gameOver) return;

    final move = _bestMove();
    setState(() {
      _board[move] = 'O';
      _userTurn = true;
    });

    final winner = _checkWinner();
    if (winner != null) {
      _finishGame(winner);
      return;
    }
    if (!_board.contains(null)) {
      _finishGame('draw');
    }
  }

  int _bestMove() {
    for (var i = 0; i < 9; i++) {
      if (_board[i] == null) {
        _board[i] = 'O';
        if (_checkWinner() == 'O') {
          _board[i] = null;
          return i;
        }
        _board[i] = null;
      }
    }
    for (var i = 0; i < 9; i++) {
      if (_board[i] == null) {
        _board[i] = 'X';
        if (_checkWinner() == 'X') {
          _board[i] = null;
          return i;
        }
        _board[i] = null;
      }
    }
    const preferred = [4, 0, 2, 6, 8, 1, 3, 5, 7];
    for (final i in preferred) {
      if (_board[i] == null) return i;
    }
    return _board.indexWhere((c) => c == null);
  }

  String? _checkWinner() {
    const lines = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];
    for (final line in lines) {
      final a = _board[line[0]];
      if (a != null && a == _board[line[1]] && a == _board[line[2]]) {
        return a;
      }
    }
    return null;
  }

  Future<void> _finishGame(String result) async {
    setState(() {
      _gameOver = true;
      if (result == 'X') {
        _status = 'You won! Claiming +1 point...';
      } else if (result == 'O') {
        _status = 'You lost. Try again!';
      } else {
        _status = 'Draw. Play again!';
      }
    });

    if (result != 'X' || _winClaimed) return;

    setState(() => _claiming = true);
    try {
      await widget.api.ticTacToeWin(_matchId);
      if (mounted) {
        setState(() {
          _winClaimed = true;
          _status = 'You won! +1 point added.';
        });
        _applyCooldown(_cooldownMinutes * 60);
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _status = apiErrorMessage(e.error));
        if (e.error == 'TIC_TAC_TOE_COOLDOWN') {
          _loadStatus();
        }
      }
    } finally {
      if (mounted) setState(() => _claiming = false);
    }
  }

  Future<void> _claimBonus() async {
    if (!_winClaimed || _bonusClaimed || _claiming) return;

    setState(() => _claiming = true);

    final rewarded = await AdService.instance.showRewarded(
      onAdNotReady: () {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ad is loading. Please try again.')),
          );
        }
      },
    );

    if (!mounted) return;
    if (!rewarded) {
      setState(() => _claiming = false);
      return;
    }

    try {
      await widget.api.ticTacToeBonus(_matchId);
      if (mounted) {
        setState(() {
          _bonusClaimed = true;
          _status = 'Bonus +1 point claimed!';
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _status = apiErrorMessage(e.error));
      }
    } finally {
      if (mounted) setState(() => _claiming = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              DingaPageHeader(
                title: 'Tic Tac Toe',
                subtitle:
                    'Beat the AI. Win +1 pt. Wait $_cooldownMinutes minutes between wins. Bonus +1 after ad.',
                onBack: () => Navigator.pop(context),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Game Status',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_loading)
                        const LinearProgressIndicator()
                      else if (_onCooldown)
                        Text(
                          'Next game in ${_formatCooldown(_cooldownSeconds)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      else
                        const Text(
                          'You can play now',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              AspectRatio(
                aspectRatio: 1,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: 9,
                  itemBuilder: (context, index) {
                    final mark = _board[index];
                    final enabled = !_onCooldown && !_loading && !_gameOver;
                    return Material(
                      color: enabled ? Colors.white : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: enabled ? () => _tapCell(index) : null,
                        borderRadius: BorderRadius.circular(12),
                        child: Center(
                          child: Text(
                            mark ?? '',
                            style: TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                              color: mark == 'X'
                                  ? AppColors.primary
                                  : AppColors.accentBlue,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              if (_status != null)
                Text(
                  _status!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: _status!.contains('+')
                        ? AppColors.accentGreen
                        : AppColors.textPrimary,
                  ),
                ),
              const SizedBox(height: 12),
              if (_winClaimed && !_bonusClaimed)
                FilledButton(
                  onPressed: _claiming ? null : _claimBonus,
                  child: _claiming
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Watch Ad for Bonus +1'),
                ),
              if (_gameOver && !_onCooldown) ...[
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: _reset,
                  child: const Text('New Game'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
