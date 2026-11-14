import 'dart:math' show pi;

import 'package:flutter/material.dart';

import '../models/flashcard.dart';
import '../models/flashcard_set.dart';
import '../models/study_session.dart';
import '../repositories/flash_mind_repository.dart';
import '../utils/app_colors.dart';
import '../utils/responsive_scale.dart';
import '../widgets/study_session_layout.dart';
import 'study_session_end_screen.dart';

/// Layar pelaksanaan sesi belajar.
class StudySessionScreen extends StatefulWidget {
  const StudySessionScreen({super.key, required this.setId, this.sessionId});

  final String setId;
  final String? sessionId;

  @override
  State<StudySessionScreen> createState() => _StudySessionScreenState();
}

class _StudySessionScreenState extends State<StudySessionScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  // Ukuran area bawah berisikan petunjuk dan tombol
  static const double _bottomSectionHeight = 50;

  // ── Repository & state ────────────────────────────────────────────────────
  final FlashMindRepository _repository = FlashMindRepository.instance;

  String? _sessionId;
  bool _isInitializing = true;
  bool _isEvaluating = false;
  bool _answerVisible = false;

  // ── Animasi flip ─────────────────────────────────────────────────────────
  late final AnimationController _flipController;
  late final Animation<double> _flipAnimation;
  bool _isFrontFacing = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

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
    WidgetsBinding.instance.removeObserver(this);
    _flipController.dispose();
    super.dispose();
  }

  // timer berhenti saat aplikasi masuk latar belakang, lanjut saat kembali.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final id = _sessionId;
    if (id == null) return;
    if (state == AppLifecycleState.paused) {
      _repository.pauseStudySession(id);
    } else if (state == AppLifecycleState.resumed) {
      _ensureFrontTimestamp();
    }
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
      _sessionId = session?.id;
      _isInitializing = false;
      _answerVisible = alreadyRevealed;
      _isFrontFacing = !alreadyRevealed;
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
    final set = _set;
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
        _isFrontFacing = false;
        _answerVisible = true;
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
    final card = _currentCard;
    if (session == null || card == null || _isEvaluating) return;

    setState(() => _isEvaluating = true);

    final updatedSession = _repository.evaluateCurrentCard(
      sessionId: session.id,
      cardId: card.id,
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
          builder: (_) => StudySessionEndScreen(
            setId: updatedSession.setId,
            sessionId: updatedSession.id,
            returnToStart: true,
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
      _isEvaluating = false;
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
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    final session = _session;
    final set = _set;
    final card = _currentCard;

    if (session == null || set == null || card == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(context),
        body: const Center(
          child: Text('Sesi belajar tidak dapat ditampilkan.'),
        ),
      );
    }

    return PopScope<bool>(
      canPop: !_isEvaluating,
      onPopInvokedWithResult: (didPop, _) {
        // Sesi dihentikan sebelum selesai: simpan dan hentikan timer.
        if (didPop) {
          final sid = _sessionId;
          if (sid != null) _repository.pauseStudySession(sid);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(context),
        body: _buildBody(context, session, set, card),
      ),
    );
  }

  // AppBar
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return StudySessionAppBar(
      onBack: _isEvaluating ? null : () => Navigator.of(context).pop(),
      backgroundColor: AppColors.background,
      showDivider: true,
    );
  }

  // ── Body ──────────────────────────────────────────────────────────────────
  Widget _buildBody(
    BuildContext context,
    StudySession session,
    FlashcardSet set,
    Flashcard card,
  ) {
    final double s = context.scale;
    final totalCards = session.cardOrder.length;
    final currentNumber = session.nextCardIndex + 1;

    return SafeArea(
      top: false,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 600 * s),
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
                  style: TextStyle(
                    fontSize: AppFont.caption * s,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: AppColors.link,
                  ),
                ),

                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: currentNumber / totalCards,
                    minHeight: 3 * s,
                    backgroundColor: AppColors.border,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.link,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Kartu flip akan mengisi seluruh sisa ruang
                Expanded(child: _buildFlipCard(card, s)),

                const SizedBox(height: 20),

                // Area bawah berisikan Petunjuk dan tombol evaluasi
                _buildBottomSection(s),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Kartu flip 3D ────────────────────────────────────────────────────────
  Widget _buildFlipCard(Flashcard card, double s) {
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
              s: s,
              faceId: '${card.id}-front',
              text: card.frontText,
              color: AppColors.primary,
              textColor: Colors.white,
              hint: 'KETUK UNTUK LIHAT JAWABAN',
              hintColor: Colors.white38,
            );
          } else {
            face = Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY(pi),
              child: _buildCardFace(
                s: s,
                faceId: '${card.id}-back',
                text: card.backText,
                color: AppColors.accent,
                textColor: AppColors.primary,
                hint: 'KETUK UNTUK LIHAT PERTANYAAN',
                hintColor: AppColors.primary.withValues(alpha: 0.4),
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
    required double s,
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
              fontSize: 11 * s,
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
  Widget _buildBottomSection(double s) {
    return SizedBox(
      height: _bottomSectionHeight * s,
      child: _answerVisible
          ? Row(
              children: [
                Expanded(
                  child: _buildEvaluationButton(
                    s: s,
                    label: 'Salah',
                    backgroundColor: AppColors.dangerSoft,
                    textColor: AppColors.danger,
                    onPressed: _isEvaluating ? null : () => _evaluateCard(false),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _buildEvaluationButton(
                    s: s,
                    label: 'Benar',
                    backgroundColor: AppColors.success,
                    textColor: Colors.white,
                    onPressed: _isEvaluating ? null : () => _evaluateCard(true),
                  ),
                ),
              ],
            )
          : Center(
              child: Text(
                'Pikirkan jawabannya, lalu ketuk kartu untuk membalik.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: AppFont.small * s, color: AppColors.muted),
              ),
            ),
    );
  }

  Widget _buildEvaluationButton({
    required double s,
    required String label,
    required Color backgroundColor,
    required Color textColor,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      height: _bottomSectionHeight * s,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(backgroundColor),
          foregroundColor: WidgetStatePropertyAll(textColor),
          elevation: const WidgetStatePropertyAll(0),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 14),
          ),
          shape: const WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(26)),
            ),
          ),
          textStyle: WidgetStatePropertyAll(
            TextStyle(fontSize: AppFont.bodyLarge * s, fontWeight: FontWeight.w700),
          ),
        ),
        child: _isEvaluating
            ? SizedBox(
                width: 18 * s,
                height: 18 * s,
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
    final double s = context.scale;
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
                        fontSize: _fontSizeFor(text.length) * s,
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