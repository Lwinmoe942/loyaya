import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:loyaya/services/ad_service.dart';
import 'package:loyaya/services/api_client.dart';
import 'package:loyaya/theme/app_theme.dart';
import 'package:loyaya/widgets/dinga_page_header.dart';

enum TttDifficulty { easy, hard, superHard }

extension on TttDifficulty {
  String get apiValue => switch (this) {
        TttDifficulty.easy => 'easy',
        TttDifficulty.hard => 'hard',
        TttDifficulty.superHard => 'super_hard',
      };

  int get points => switch (this) {
        TttDifficulty.easy => 1,
        TttDifficulty.hard => 2,
        TttDifficulty.superHard => 3,
      };

  String get label => switch (this) {
        TttDifficulty.easy => 'Easy +1',
        TttDifficulty.hard => 'Hard +2',
        TttDifficulty.superHard => 'Super Hard +3',
      };
}

class TicTacToeScreen extends StatefulWidget {
  const TicTacToeScreen({super.key, required this.api});

  final ApiClient api;

  @override
  State<TicTacToeScreen> createState() => _TicTacToeScreenState();
}

class _TicTacToeScreenState extends State<TicTacToeScreen> {
  static const _lossCooldownSeconds = 60;
  static const _bonusAdCount = 3;

  final _random = Random();
  late String _matchId;
  final List<String?> _board = List.filled(9, null);
  TttDifficulty _difficulty = TttDifficulty.easy;

  bool _loading = true;
  int _waitSeconds = 0;
  Timer? _waitTimer;
  bool _userTurn = true;
  bool _gameOver = false;
  bool _claiming = false;
  bool _winClaimed = false;
  String? _status;

  bool get _locked => _waitSeconds > 0;

  @override
  void initState() {
    super.initState();
    _matchId = _newMatchId();
    _loadStatus();
  }

  @override
  void dispose() {
    _waitTimer?.cancel();
    super.dispose();
  }

  String _newMatchId() =>
      '${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(99999)}';

  Future<void> _loadStatus() async {
    setState(() => _loading = true);
    try {
      final status = await widget.api.gamesStatus();
      if (mounted) {
        _applyWait(status['tic_tac_toe_loss_cooldown_seconds'] as int? ?? 0);
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

  void _applyWait(int seconds) {
    _waitTimer?.cancel();
    _waitSeconds = seconds.clamp(0, _lossCooldownSeconds);
    if (_waitSeconds <= 0) return;

    _waitTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _waitSeconds = (_waitSeconds - 1).clamp(0, _lossCooldownSeconds);
      });
      if (_waitSeconds <= 0) {
        _waitTimer?.cancel();
        if (_gameOver) {
          setState(() {
            _gameOver = false;
            _status = null;
          });
        }
      }
    });
  }

  void _resetBoard() {
    setState(() {
      _matchId = _newMatchId();
      _board.fillRange(0, 9, null);
      _userTurn = true;
      _gameOver = false;
      _winClaimed = false;
      _status = null;
    });
  }

  void _tapCell(int index) {
    if (_locked || _loading || _gameOver || !_userTurn || _board[index] != null) {
      return;
    }

    setState(() {
      _board[index] = 'X';
      _userTurn = false;
    });

    final winner = _checkWinner(_board);
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

    final move = _pickAiMove();
    setState(() {
      _board[move] = 'O';
      _userTurn = true;
    });

    final winner = _checkWinner(_board);
    if (winner != null) {
      _finishGame(winner);
      return;
    }
    if (!_board.contains(null)) {
      _finishGame('draw');
    }
  }

  int _pickAiMove() {
    return switch (_difficulty) {
      TttDifficulty.easy => _easyMove(),
      TttDifficulty.hard => _hardMove(),
      TttDifficulty.superHard => _perfectMove(),
    };
  }

  int _easyMove() {
    if (_random.nextDouble() < 0.45) {
      final open = <int>[];
      for (var i = 0; i < 9; i++) {
        if (_board[i] == null) open.add(i);
      }
      return open[_random.nextInt(open.length)];
    }
    return _hardMove();
  }

  int _hardMove() {
    for (var i = 0; i < 9; i++) {
      if (_board[i] == null) {
        _board[i] = 'O';
        if (_checkWinner(_board) == 'O') {
          _board[i] = null;
          return i;
        }
        _board[i] = null;
      }
    }
    for (var i = 0; i < 9; i++) {
      if (_board[i] == null) {
        _board[i] = 'X';
        if (_checkWinner(_board) == 'X') {
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

  int _perfectMove() {
    var bestScore = -1000;
    var bestMove = 0;
    for (var i = 0; i < 9; i++) {
      if (_board[i] != null) continue;
      _board[i] = 'O';
      final score = _minimax(_board, false);
      _board[i] = null;
      if (score > bestScore) {
        bestScore = score;
        bestMove = i;
      }
    }
    return bestMove;
  }

  int _minimax(List<String?> board, bool maximizing) {
    final winner = _checkWinner(board);
    if (winner == 'O') return 10;
    if (winner == 'X') return -10;
    if (!board.contains(null)) return 0;

    if (maximizing) {
      var best = -1000;
      for (var i = 0; i < 9; i++) {
        if (board[i] != null) continue;
        board[i] = 'O';
        best = max(best, _minimax(board, false));
        board[i] = null;
      }
      return best;
    }

    var best = 1000;
    for (var i = 0; i < 9; i++) {
      if (board[i] != null) continue;
      board[i] = 'X';
      best = min(best, _minimax(board, true));
      board[i] = null;
    }
    return best;
  }

  String? _checkWinner(List<String?> board) {
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
      final a = board[line[0]];
      if (a != null && a == board[line[1]] && a == board[line[2]]) {
        return a;
      }
    }
    return null;
  }

  Future<void> _finishGame(String result) async {
    setState(() => _gameOver = true);

    if (result == 'X') {
      await _handleWin();
    } else if (result == 'O') {
      await _handleLoss();
    } else {
      setState(() => _status = 'Draw. You can play again.');
    }
  }

  Future<void> _handleWin() async {
    setState(() {
      _claiming = true;
      _status = 'You won! Claiming +${_difficulty.points} points...';
    });

    try {
      final result = await widget.api.ticTacToeWin(
        _matchId,
        difficulty: _difficulty.apiValue,
      );
      if (!mounted) return;

      final points = result['points'] as int? ?? _difficulty.points;
      setState(() {
        _winClaimed = true;
        _claiming = false;
        _status = 'You won! +$points points added.';
      });
      await _askBonusDialog();
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _claiming = false;
          _status = apiErrorMessage(e.error);
        });
      }
    }
  }

  Future<void> _handleLoss() async {
    setState(() => _status = 'You lost. Please wait 60 seconds...');

    try {
      final result = await widget.api.ticTacToeLoss(_matchId);
      if (!mounted) return;
      final seconds =
          result['loss_cooldown_seconds'] as int? ?? _lossCooldownSeconds;
      _applyWait(seconds);
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _status = apiErrorMessage(e.error));
        _applyWait(_lossCooldownSeconds);
      }
    }
  }

  Future<void> _askBonusDialog() async {
    if (!mounted || !_winClaimed) return;

    final takeBonus = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Bonus +1'),
        content: const Text(
          'Watch 3 reward ads to claim bonus +1 point?\n\n'
          'If you skip, you can play again right away.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No, play again'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes, watch ads'),
          ),
        ],
      ),
    );

    if (!mounted) return;

    if (takeBonus == true) {
      await _claimBonusWithAds();
    } else {
      _resetBoard();
    }
  }

  Future<void> _claimBonusWithAds() async {
    setState(() {
      _claiming = true;
      _status = 'Watch ad 1 of $_bonusAdCount...';
    });

    final rewarded = await AdService.instance.showRewardedMultiple(
      _bonusAdCount,
      onProgress: (current, total) {
        if (mounted) {
          setState(() => _status = 'Watch ad $current of $total...');
        }
      },
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
      setState(() {
        _claiming = false;
        _status = 'Bonus cancelled. You can play again.';
      });
      _resetBoard();
      return;
    }

    try {
      await widget.api.ticTacToeBonus(_matchId);
      if (mounted) {
        setState(() {
          _claiming = false;
          _status = 'Bonus +1 point claimed!';
        });
        await Future<void>.delayed(const Duration(seconds: 1));
        if (mounted) _resetBoard();
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _claiming = false;
          _status = apiErrorMessage(e.error);
        });
        _resetBoard();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final canPlay = !_locked && !_loading && !_gameOver && !_claiming;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              DingaPageHeader(
                title: 'Tic Tac Toe',
                subtitle: 'Improve your brain and get points.',
                onBack: () => Navigator.pop(context),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.emoji_events, color: Colors.amber.shade700),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Easy +1, Hard +2, Super Hard +3. '
                          'Watch rewarded ads for extra bonus. '
                          'If you lose, wait 60 seconds to play again.',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: TttDifficulty.values.map((level) {
                  final selected = _difficulty == level;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text(
                          level.label,
                          style: TextStyle(
                            fontSize: 11,
                            color: selected ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                        selected: selected,
                        onSelected: canPlay && !_winClaimed
                            ? (_) => setState(() => _difficulty = level)
                            : null,
                        selectedColor: AppColors.accentBlue,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              if (_locked)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.timer_outlined, color: AppColors.accentGreen),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Please wait $_waitSeconds seconds to play again.',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.accentGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 12),
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: 9,
                    itemBuilder: (context, index) {
                      final mark = _board[index];
                      final enabled = canPlay;
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
                                    : const Color(0xFFFF9800),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              if (_status != null) ...[
                const SizedBox(height: 8),
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
              ],
              const SizedBox(height: 12),
              if (_locked)
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: null,
                    child: Text('${_waitSeconds}s'),
                  ),
                )
              else if (_gameOver && !_winClaimed && !_claiming)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _resetBoard,
                    child: const Text('Play Again'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
