import 'dart:math';
import 'package:flutter/material.dart';
import '../models/flashcard.dart';
import '../services/storage_service.dart';

class FlashcardScreen extends StatefulWidget {
  const FlashcardScreen({super.key});

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen>
    with TickerProviderStateMixin {
  List<Flashcard> _cards = [];
  int _currentIndex = 0;
  bool _showAnswer = false;
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _flipAnimation = Tween<double>(begin: 0, end: pi)
        .animate(CurvedAnimation(parent: _flipController, curve: Curves.easeInOut));
    _loadCards();
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  Future<void> _loadCards() async {
    final cards = await StorageService.loadFlashcards();
    if (mounted) setState(() => _cards = cards);
  }

  Future<void> _saveCards() => StorageService.saveFlashcards(_cards);

  void _flipCard() {
    if (_showAnswer) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
    setState(() => _showAnswer = !_showAnswer);
  }

  void _nextCard() {
    if (_cards.isEmpty) return;
    if (_showAnswer) {
      _flipController.reverse();
      setState(() => _showAnswer = false);
    }
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() => _currentIndex = (_currentIndex + 1) % _cards.length);
      }
    });
  }

  void _prevCard() {
    if (_cards.isEmpty) return;
    if (_showAnswer) {
      _flipController.reverse();
      setState(() => _showAnswer = false);
    }
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() => _currentIndex =
            (_currentIndex - 1 + _cards.length) % _cards.length);
      }
    });
  }

  void _addCard() {
    final qController = TextEditingController();
    final aController = TextEditingController();
    final sController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          left: 24,
          right: 24,
          top: 24,
        ),
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A2E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('New Flashcard',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            _inputField(qController, 'Question', Icons.help_outline_rounded),
            const SizedBox(height: 12),
            _inputField(aController, 'Answer', Icons.lightbulb_outline_rounded, maxLines: 3),
            const SizedBox(height: 12),
            _inputField(sController, 'Subject (e.g. Math)', Icons.book_outlined),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (qController.text.trim().isEmpty || aController.text.trim().isEmpty) return;
                  final card = Flashcard(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    question: qController.text.trim(),
                    answer: aController.text.trim(),
                    subject: sController.text.trim().isEmpty ? 'General' : sController.text.trim(),
                    createdAt: DateTime.now(),
                  );
                  setState(() => _cards.add(card));
                  _saveCards();
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Add Card', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputField(TextEditingController c, String hint, IconData icon, {int maxLines = 1}) {
    return TextField(
      controller: c,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
        prefixIcon: Icon(icon, color: const Color(0xFF6366F1), size: 20),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF6366F1), width: 1.5)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Flashcards',
                  style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(
                _cards.isEmpty ? 'No cards yet' : '${_currentIndex + 1} of ${_cards.length}',
                style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 14),
              ),
              const SizedBox(height: 32),
              if (_cards.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.style_rounded, size: 80, color: Colors.white.withOpacity(0.1)),
                        const SizedBox(height: 16),
                        Text('Add your first flashcard!',
                            style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 16)),
                      ],
                    ),
                  ),
                )
              else ...[
                // Card
                Expanded(
                  child: GestureDetector(
                    onTap: _flipCard,
                    child: AnimatedBuilder(
                      animation: _flipAnimation,
                      builder: (ctx, child) {
                        final angle = _flipAnimation.value;
                        final showFront = angle < pi / 2;
                        return Transform(
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.001)
                            ..rotateY(angle),
                          alignment: Alignment.center,
                          child: showFront
                              ? _CardFace(
                                  text: _cards[_currentIndex].question,
                                  label: 'QUESTION',
                                  subject: _cards[_currentIndex].subject,
                                  color: const Color(0xFF6366F1),
                                  icon: Icons.help_outline_rounded,
                                  hint: 'Tap to reveal answer',
                                )
                              : Transform(
                                  transform: Matrix4.identity()..rotateY(pi),
                                  alignment: Alignment.center,
                                  child: _CardFace(
                                    text: _cards[_currentIndex].answer,
                                    label: 'ANSWER',
                                    subject: _cards[_currentIndex].subject,
                                    color: const Color(0xFF10B981),
                                    icon: Icons.lightbulb_rounded,
                                    hint: 'Tap to flip back',
                                  ),
                                ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Navigation
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _NavBtn(icon: Icons.arrow_back_rounded, onTap: _prevCard),
                    const SizedBox(width: 20),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _cards.removeAt(_currentIndex);
                          if (_currentIndex >= _cards.length && _currentIndex > 0) {
                            _currentIndex--;
                          }
                          _showAnswer = false;
                          _flipController.reset();
                        });
                        _saveCards();
                      },
                      child: Container(
                        width: 48, height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFEF4444).withOpacity(0.1),
                          border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.3)),
                        ),
                        child: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 20),
                      ),
                    ),
                    const SizedBox(width: 20),
                    _NavBtn(icon: Icons.arrow_forward_rounded, onTap: _nextCard),
                  ],
                ),
              ],
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCard,
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}

class _CardFace extends StatelessWidget {
  final String text;
  final String label;
  final String subject;
  final Color color;
  final IconData icon;
  final String hint;

  const _CardFace({
    required this.text,
    required this.label,
    required this.subject,
    required this.color,
    required this.icon,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(icon, color: color, size: 14),
                      const SizedBox(width: 4),
                      Text(label,
                          style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(subject,
                      style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11)),
                ),
              ],
            ),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                height: 1.5,
              ),
            ),
            Text(
              hint,
              style: TextStyle(color: Colors.white.withOpacity(0.25), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _NavBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56, height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.05),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Icon(icon, color: Colors.white.withOpacity(0.7)),
      ),
    );
  }
}
