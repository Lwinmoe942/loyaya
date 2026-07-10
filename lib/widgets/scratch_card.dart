import 'package:flutter/material.dart';

/// Finger-scratch overlay. Calls [onRevealed] once enough scratches are made.
class ScratchCard extends StatefulWidget {
  const ScratchCard({
    super.key,
    required this.prizeText,
    required this.onRevealed,
  });

  final String prizeText;
  final VoidCallback onRevealed;

  @override
  State<ScratchCard> createState() => _ScratchCardState();
}

class _ScratchCardState extends State<ScratchCard> {
  final List<Offset> _scratches = [];
  bool _revealed = false;

  void _addScratch(Offset local) {
    if (_revealed) return;
    setState(() => _scratches.add(local));
    if (_scratches.length >= 24) {
      _revealed = true;
      widget.onRevealed();
    }
  }

  @override
  Widget build(BuildContext context) {
    final coverOpacity = _revealed
        ? 0.0
        : (1 - (_scratches.length / 24)).clamp(0.0, 1.0);

    return AspectRatio(
      aspectRatio: 1.6,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFFD54F), Color(0xFFFF8F00)],
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                widget.prizeText,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [Shadow(color: Colors.black26, blurRadius: 4)],
                ),
              ),
            ),
            AnimatedOpacity(
              opacity: coverOpacity,
              duration: const Duration(milliseconds: 200),
              child: Listener(
                onPointerDown: (e) => _addScratch(e.localPosition),
                onPointerMove: (e) => _addScratch(e.localPosition),
                child: Container(
                  color: const Color(0xFFB0BEC5),
                  alignment: Alignment.center,
                  child: const Text(
                    'Scratch here!',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
