import 'dart:math';

import 'package:flutter/material.dart';
import 'package:loyaya/services/api_client.dart';

class MathQuizScreen extends StatefulWidget {
  const MathQuizScreen({super.key, required this.api});

  final ApiClient api;

  @override
  State<MathQuizScreen> createState() => _MathQuizScreenState();
}

class _MathQuizScreenState extends State<MathQuizScreen> {
  final _random = Random();
  late int _a;
  late int _b;
  final _answerController = TextEditingController();
  bool _loading = false;
  String? _message;
  bool? _correct;

  @override
  void initState() {
    super.initState();
    _newQuestion();
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  void _newQuestion() {
    _a = _random.nextInt(12) + 1;
    _b = _random.nextInt(12) + 1;
    _answerController.clear();
    setState(() {
      _message = null;
      _correct = null;
    });
  }

  Future<void> _submit() async {
    final answer = int.tryParse(_answerController.text.trim());
    if (answer == null) {
      setState(() => _message = 'Enter a number');
      return;
    }

    if (answer != _a + _b) {
      setState(() {
        _correct = false;
        _message = 'Wrong answer — try again';
      });
      _newQuestion();
      return;
    }

    setState(() {
      _loading = true;
      _message = null;
    });

    try {
      final result = await widget.api.earnMathQuiz();
      setState(() {
        _correct = true;
        _message = result['duplicate'] == true
            ? 'Points already earned for this quiz'
            : 'Correct! +2 points';
      });
    } on ApiException catch (e) {
      setState(() => _message = e.error);
    } catch (_) {
      setState(() => _message = 'NETWORK_ERROR');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E7),
      appBar: AppBar(
        title: const Text('Math Quiz'),
        backgroundColor: const Color(0xFFD4A017),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      '$_a + $_b = ?',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFB8860B),
                          ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _answerController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Answer',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _loading ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFB8860B),
                minimumSize: const Size.fromHeight(48),
              ),
              child: _loading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Submit (+2 pts)'),
            ),
            if (_message != null) ...[
              const SizedBox(height: 16),
              Text(
                _message!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _correct == true
                      ? Colors.green.shade700
                      : Colors.red.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
