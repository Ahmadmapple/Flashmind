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
  static const Color _primaryColor    = Color(0xFF192A3A);
  static const Color _backgroundColor = Color(0xFFFBF9F6);
  static const Color _cardFrontColor  = Color(0xFF192A3A);   // biru gelap
  static const Color _cardBackColor   = Color(0xFFF3C279);   // kuning emas
  static const Color _dangerColor     = Color(0xFFEF5350);
  static const Color _successColor    = Color(0xFF2D6A4F);
  static const Color _orangeColor     = Color(0xFFE87A5D);

  // Ukuran area bawah berisikan petunjuk dan tombol dibuat tetap
  static const double _bottomSectionHeight = 50;

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
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 45),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Label: NAMA SET · KARTU N
                Text(
                  '${set.title.toUpperCase()} · KARTU $currentNumber',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: _orangeColor,
                  ),
                ),

                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: currentNumber / totalCards,
                    minHeight: 3,
                    backgroundColor: const Color(0xFFE8E4DB),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      _orangeColor,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Kartu flip akan mengisi seluruh sisa ruang
                Expanded(child: _buildFlipCard(card)),

                const SizedBox(height: 20),

                // Area bawah berisikan Petunjuk dan tombol evaluasi
                _buildBottomSection(),
              ],
            ),
          ),
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

          Widget face;
          if (isFront) {
            face = _buildCardFace(
              faceId:    '${card.id}-front',
              text:      card.frontText,
              color:     _cardFrontColor,
              textColor: Colors.white,
              hint:      'KETUK UNTUK LIHAT JAWABAN',
              hintColor: Colors.white38,
            );
          } else {
            face = Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY(pi),
              child: _buildCardFace(
                faceId:    '${card.id}-back',
                text:      card.backText,
                color:     _cardBackColor,
                textColor: _primaryColor,
                hint:      'KETUK UNTUK LIHAT PERTANYAAN',
                hintColor: const Color(0x66192A3A),
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
    required String faceId,
    required String text,
    required Color color,
    required Color textColor,
    required String hint,
    required Color hintColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 18),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          Expanded(
            child: _CardFaceText(
              key: ValueKey<String>(faceId),
              text: text,
              textColor: textColor,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            hint,
            textAlign: TextAlign.center,
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
    return SizedBox(
      height: _bottomSectionHeight,
      child: _answerVisible
          ? Row(
              children: [
                Expanded(
                  child: _buildEvaluationButton(
                    label:           'Salah',
                    backgroundColor: const Color(0xFFFDE8E8),
                    textColor:       _dangerColor,
                    onPressed:       _isEvaluating ? null : () => _evaluateCard(false),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _buildEvaluationButton(
                    label:           'Benar',
                    backgroundColor: _successColor,
                    textColor:       Colors.white,
                    onPressed:       _isEvaluating ? null : () => _evaluateCard(true),
                  ),
                ),
              ],
            )
          : const Center(
              child: Text(
                'Pikirkan jawabannya, lalu ketuk kartu untuk membalik.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ),
    );
  }

  Widget _buildEvaluationButton({
    required String label,
    required Color backgroundColor,
    required Color textColor,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      height: _bottomSectionHeight,
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

class _CardFaceText extends StatefulWidget {
  const _CardFaceText({
    super.key,
    required this.text,
    required this.textColor,
  });

  final String text;
  final Color textColor;

  @override
  State<_CardFaceText> createState() => _CardFaceTextState();
}

class _CardFaceTextState extends State<_CardFaceText> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  static double _fontSizeFor(int length) {
    if (length <= 80) return 22;
    if (length <= 200) return 19;
    if (length <= 400) return 16;
    return 14;
  }

  @override
  Widget build(BuildContext context) {
    final String text = widget.text;
    final bool isLong = text.length > 120;

    return ScrollbarTheme(
      data: ScrollbarThemeData(
        thumbColor: WidgetStatePropertyAll(
          widget.textColor.withValues(alpha: 0.35),
        ),
        thickness: const WidgetStatePropertyAll(4),
        radius: const Radius.circular(4),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Scrollbar(
            controller: _scrollController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: _scrollController,
              child: ConstrainedBox(
                // Teks pendek tetap rata tengah.
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      text,
                      textAlign: isLong ? TextAlign.justify : TextAlign.center,
                      style: TextStyle(
                        fontSize: _fontSizeFor(text.length),
                        fontWeight: isLong ? FontWeight.w600 : FontWeight.bold,
                        fontFamily: 'serif',
                        color: widget.textColor,
                        height: 1.35,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
