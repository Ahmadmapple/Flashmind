import 'dart:math' show pi;

import 'package:flutter/material.dart';

import '../models/flashcard.dart';
import '../models/flashcard_set.dart';
import '../models/study_session.dart';
import '../repositories/flash_mind_repository.dart';
import 'study_session_end_page.dart';

/// Layar pelaksanaan sesi belajar.
class StudySessionPage extends StatefulWidget {
  const StudySessionPage({super.key, required this.setId, this.sessionId});

  final String setId;
  final String? sessionId;

  @override
  State<StudySessionPage> createState() => _StudySessionPageState();
}

class _StudySessionPageState extends State<StudySessionPage>
    with SingleTickerProviderStateMixin {
  // ── Warna ──────────────────────────────────────────────────────────────────
  static const Color _primaryColor   = Color(0xFF192A3A);
  static const Color _backgroundColor = Color(0xFFFBF9F6);
  static const Color _cardFrontColor  = Color(0xFF192A3A);   // biru gelap
  static const Color _cardBackColor   = Color(0xFFF3C279);   // kuning emas
  static const Color _dangerColor     = Color(0xFFEF5350);
  static const Color _successColor    = Color(0xFF2D6A4F);

  // ── Repository & state ────────────────────────────────────────────────────
  final FlashMindRepository _repository = FlashMindRepository.instance;

  String?  _sessionId;
  bool     _isInitializing = true;
  bool     _isEvaluating   = false;
  bool     _answerVisible  = false;

  // ── Animasi flip ─────────────────────────────────────────────────────────
  late final AnimationController _flipController;
  late final Animation<double>   _flipAnimation;
  bool _isFrontFacing = true;

  @override
  void initState() {
    super.initState();

    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );

    _initializeSession();
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  // ── Init sesi ─────────────────────────────────────────────────────────────
  Future<void> _initializeSession() async {
    final existingSession = widget.sessionId == null
        ? _repository.getInProgressStudySessionForSet(widget.setId)
        : _repository.getStudySessionById(widget.sessionId!);

    StudySession? session = existingSession;
    session ??= await _repository.startStudySession(widget.setId);

    if (!mounted) return;

    final alreadyRevealed = session?.currentCardAnswerRevealedAt != null;
    setState(() {
      _sessionId       = session?.id;
      _isInitializing  = false;
      _answerVisible   = alreadyRevealed;
      _isFrontFacing   = !alreadyRevealed;
    });

    if (alreadyRevealed) {
      _flipController.value = 1.0;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _ensureFrontTimestamp();
    });
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  StudySession? get _session {
    final id = _sessionId;
    if (id == null) return null;
    return _repository.getStudySessionById(id);
  }

  FlashcardSet? get _set {
    final session = _session;
    if (session == null) return null;
    return _repository.getSetById(session.setId);
  }

  Flashcard? get _currentCard {
    final session = _session;
    final set     = _set;
    if (session == null || set == null) return null;
    if (session.nextCardIndex >= session.cardOrder.length) return null;
    final cardId = session.cardOrder[session.nextCardIndex];
    for (final card in set.cards) {
      if (card.id == cardId) return card;
    }
    return null;
  }

  void _ensureFrontTimestamp() {
    final session = _session;
    if (session == null || session.currentCardFrontShownAt != null) return;
    _repository.markCurrentCardFrontShown(session.id);
  }

  // ── Flip kartu ────────────────────────────────────────────────────────────
  void _flipCard() {
    final session = _session;
    if (session == null || _isEvaluating) return;

    if (_isFrontFacing) {
      // Depan → belakang: tandai jawaban terlihat
      _repository.markAnswerRevealed(session.id);
      _flipController.forward();
      setState(() {
        _isFrontFacing  = false;
        _answerVisible  = true;
      });
    } else {
      // Belakang → depan
      _flipController.reverse();
      setState(() {
        _isFrontFacing = true;
        _answerVisible = false;
      });
    }
  }

  // ── Evaluasi ──────────────────────────────────────────────────────────────
  Future<void> _evaluateCard(bool isCorrect) async {
    final session = _session;
    final card    = _currentCard;
    if (session == null || card == null || _isEvaluating) return;

    setState(() => _isEvaluating = true);

    final updatedSession = _repository.evaluateCurrentCard(
      sessionId: session.id,
      cardId:    card.id,
      isCorrect: isCorrect,
    );

    if (!mounted) return;

    if (updatedSession == null) {
      setState(() => _isEvaluating = false);
      return;
    }

    if (updatedSession.status == StudySessionStatus.completed) {
      await Navigator.of(context).pushReplacement<void, void>(
        MaterialPageRoute<void>(
          builder: (_) => StudySessionEndPage(
            setId:     updatedSession.setId,
            sessionId: updatedSession.id,
          ),
        ),
      );
      return;
    }

    // Reset ke depan untuk kartu berikutnya
    _flipController.value = 0.0;
    setState(() {
      _answerVisible = false;
      _isFrontFacing = true;
      _isEvaluating  = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _ensureFrontTimestamp();
    });
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return const Scaffold(
        backgroundColor: _backgroundColor,
        body: Center(child: CircularProgressIndicator(color: _primaryColor)),
      );
    }

    final session = _session;
    final set     = _set;
    final card    = _currentCard;

    if (session == null || set == null || card == null) {
      return Scaffold(
        backgroundColor: _backgroundColor,
        appBar: _buildAppBar(context),
        body: const Center(
          child: Text('Sesi belajar tidak dapat ditampilkan.'),
        ),
      );
    }

    return PopScope<bool>(
      canPop: !_isEvaluating,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          final sid = _sessionId;
          if (sid != null) _repository.pauseStudySession(sid);
        }
      },
      child: Scaffold(
        backgroundColor: _backgroundColor,
        appBar: _buildAppBar(context),
        body: _buildBody(context, session, set, card),
      ),
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: _backgroundColor,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      leading: IconButton(
        onPressed: _isEvaluating ? null : () => Navigator.of(context).pop(),
        icon: const Icon(Icons.arrow_back_ios_new, size: 22),
        color: _primaryColor,
        tooltip: 'Kembali',
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: const Color(0xFFE8E4DB)),
      ),
    );
  }

  // ── Body ──────────────────────────────────────────────────────────────────
  Widget _buildBody(
    BuildContext context,
    StudySession session,
    FlashcardSet set,
    Flashcard card,
  ) {
    final totalCards    = session.cardOrder.length;
    final currentNumber = session.nextCardIndex + 1;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // Label: NAMA SET · KARTU N
            Text(
              '${set.title.toUpperCase()} · KARTU $currentNumber',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: Color(0xFFE87A5D),
              ),
            ),

            // Progress bar tipis
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: currentNumber / totalCards,
                minHeight: 3,
                backgroundColor: const Color(0xFFE8E4DB),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFFE87A5D),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Kartu flip
            Expanded(
              child: _buildFlipCard(card),
            ),

            const SizedBox(height: 20),

            // Hint / tombol evaluasi
            _buildBottomSection(),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ── Kartu flip 3D ────────────────────────────────────────────────────────
  Widget _buildFlipCard(Flashcard card) {
    return GestureDetector(
      onTap: _isEvaluating ? null : _flipCard,
      child: AnimatedBuilder(
        animation: _flipAnimation,
        builder: (context, _) {
          final angle = _flipAnimation.value * pi;
          final isFront = angle <= pi / 2;

          // Saat sudut > 90° tampilkan sisi belakang (diputar 180° lagi)
          Widget face;
          if (isFront) {
            face = _buildCardFace(
              text:      card.frontText,
              color:     _cardFrontColor,
              textColor: Colors.white,
              hint:      'KETUK UNTUK LIHAT JAWABAN',
              hintColor: Colors.white38,
              isBack:    false,
            );
          } else {
            face = Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY(pi),
              child: _buildCardFace(
                text:      card.backText,
                color:     _cardBackColor,
                textColor: _primaryColor,
                hint:      'KETUK UNTUK LIHAT PERTANYAAN',
                hintColor: const Color(0xFF192A3A66),
                isBack:    true,
              ),
            );
          }

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            child: face,
          );
        },
      ),
    );
  }

  Widget _buildCardFace({
    required String text,
    required Color color,
    required Color textColor,
    required String hint,
    required Color hintColor,
    required bool isBack,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'serif',
                color: textColor,
                height: 1.35,
              ),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            hint,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: hintColor,
            ),
          ),
        ],
      ),
    );
  }

  // ── Bagian bawah ─────────────────────────────────────────────────────────
  Widget _buildBottomSection() {
    if (!_answerVisible) {
      // Sebelum flip: teks panduan
      return Center(
        child: RichText(
          text: const TextSpan(
            style: TextStyle(fontSize: 13, color: Colors.grey),
            children: [
              TextSpan(text: 'Pikirkan jawabannya, lalu ketuk kartu untuk '),
              TextSpan(
                text: 'balik.',
                style: TextStyle(
                  color: Color(0xFFE87A5D),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Setelah flip: tombol evaluasi
    return Row(
      children: [
        Expanded(
          child: _buildEvaluationButton(
            label:           'Tidak Tahu',
            backgroundColor: const Color(0xFFFDE8E8),
            textColor:       _dangerColor,
            onPressed:       _isEvaluating ? null : () => _evaluateCard(false),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _buildEvaluationButton(
            label:           'Sudah Tahu',
            backgroundColor: _successColor,
            textColor:       Colors.white,
            onPressed:       _isEvaluating ? null : () => _evaluateCard(true),
          ),
        ),
      ],
    );
  }

  Widget _buildEvaluationButton({
    required String label,
    required Color backgroundColor,
    required Color textColor,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(backgroundColor),
          foregroundColor: WidgetStatePropertyAll(textColor),
          elevation:        const WidgetStatePropertyAll(0),
          padding:          const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 14),
          ),
          shape: const WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(26)),
            ),
          ),
          textStyle: const WidgetStatePropertyAll(
            TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
        ),
        child: _isEvaluating
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: textColor,
                ),
              )
            : Text(label),
      ),
    );
  }
}
