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

class _StudySessionPageState extends State<StudySessionPage> {
  static const Color _primaryColor = Color(0xFF192A3A);
  static const Color _accentColor = Color(0xFFF3C279);
  static const Color _headerColor = Color(0xFFFFE5B4);
  static const Color _backgroundColor = Color(0xFFFBF9F6);
  static const Color _dangerColor = Color(0xFFEF5350);
  static const Color _successColor = Color(0xFF4CAF50);

  static const TextStyle _cardBodyStyle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: _primaryColor,
    height: 1.35,
  );

  final FlashMindRepository _repository = FlashMindRepository.instance;

  String? _sessionId;
  bool _isInitializing = true;
  bool _isEvaluating = false;
  bool _answerVisible = false;

  @override
  void initState() {
    super.initState();
    _initializeSession();
  }

  Future<void> _initializeSession() async {
    final existingSession = widget.sessionId == null
        ? _repository.getInProgressStudySessionForSet(widget.setId)
        : _repository.getStudySessionById(widget.sessionId!);

    StudySession? session = existingSession;
    if (session == null) {
      session = await _repository.startStudySession(widget.setId);
    }

    if (!mounted) return;

    setState(() {
      _sessionId = session?.id;
      _isInitializing = false;
      _answerVisible = session?.currentCardAnswerRevealedAt != null;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _ensureFrontTimestamp();
    });
  }

  StudySession? get _session {
    final sessionId = _sessionId;
    if (sessionId == null) return null;
    return _repository.getStudySessionById(sessionId);
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

  void _showAnswer() {
    final session = _session;
    if (session == null || _isEvaluating || _answerVisible) return;

    _repository.markAnswerRevealed(session.id);
    if (!mounted) return;

    setState(() {
      _answerVisible = true;
    });
  }

  Future<void> _evaluateCard(bool isCorrect) async {
    final session = _session;
    final card = _currentCard;
    if (session == null || card == null || _isEvaluating) return;

    setState(() {
      _isEvaluating = true;
    });

    final updatedSession = _repository.evaluateCurrentCard(
      sessionId: session.id,
      cardId: card.id,
      isCorrect: isCorrect,
    );

    if (!mounted) return;

    if (updatedSession == null) {
      setState(() {
        _isEvaluating = false;
      });
      return;
    }

    if (updatedSession.status == StudySessionStatus.completed) {
      await Navigator.of(context).pushReplacement<void, void>(
        MaterialPageRoute<void>(
          builder: (_) => StudySessionEndPage(
            setId: updatedSession.setId,
            sessionId: updatedSession.id,
          ),
        ),
      );

      return;
    }

    setState(() {
      _answerVisible = false;
      _isEvaluating = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _ensureFrontTimestamp();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return const Scaffold(
        backgroundColor: _backgroundColor,
        body: Center(child: CircularProgressIndicator(color: _primaryColor)),
      );
    }

    final session = _session;
    final set = _set;
    final card = _currentCard;

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
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          final sessionId = _sessionId;
          if (sessionId != null) {
            _repository.pauseStudySession(sessionId);
          }
        }
      },
      child: Scaffold(
        backgroundColor: _backgroundColor,
        appBar: _buildAppBar(context),
        body: _buildBody(context, session, card),
        floatingActionButton: _buildHomeButton(context),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: _headerColor,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      leading: IconButton(
        onPressed: _isEvaluating ? null : () => Navigator.of(context).pop(),
        icon: const Icon(Icons.arrow_back, size: 28),
        color: _primaryColor,
        tooltip: 'Kembali',
      ),
      title: const Text(
        'Sesi Belajar',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          fontFamily: 'serif',
          color: _primaryColor,
        ),
      ),
      centerTitle: false,
    );
  }

  Widget _buildBody(
    BuildContext context,
    StudySession session,
    Flashcard card,
  ) {
    final totalCards = session.cardOrder.length;
    final currentNumber = session.nextCardIndex + 1;
    final sideLabel = _answerVisible ? 'Sisi Belakang' : 'Sisi Depan';
    final text = _answerVisible ? card.backText : card.frontText;

    return SafeArea(
      top: false,
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 30, 20, 88),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    sideLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'serif',
                      color: _primaryColor,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8),
                  child: Text(
                    '$currentNumber/$totalCards',
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildStudyCard(text: text),
            const SizedBox(height: 24),
            if (!_answerVisible)
              Center(child: _buildShowAnswerButton())
            else
              _buildEvaluationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildStudyCard({required String text}) {
    return Container(
      width: double.infinity,
      height: 400,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE8E4DB), width: 1.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: SingleChildScrollView(
        child: SizedBox(
          width: double.infinity,
          child: Text(
            text,
            textAlign: TextAlign.justify,
            style: _cardBodyStyle,
          ),
        ),
      ),
    );
  }

  Widget _buildShowAnswerButton() {
    return SizedBox(
      height: 32,
      child: ElevatedButton(
        onPressed: _isEvaluating ? null : _showAnswer,
        style: ButtonStyle(
          backgroundColor: const WidgetStatePropertyAll(_accentColor),
          foregroundColor: const WidgetStatePropertyAll(_primaryColor),
          elevation: const WidgetStatePropertyAll(0),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 18),
          ),
          minimumSize: const WidgetStatePropertyAll(Size(95, 35)),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          ),
          textStyle: const WidgetStatePropertyAll(
            TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
        ),
        child: const Text('Lihat Jawaban'),
      ),
    );
  }

  Widget _buildEvaluationButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildEvaluationButton(
            label: 'Salah',
            backgroundColor: _dangerColor,
            onPressed: _isEvaluating ? null : () => _evaluateCard(false),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildEvaluationButton(
            label: 'Benar',
            backgroundColor: _successColor,
            onPressed: _isEvaluating ? null : () => _evaluateCard(true),
          ),
        ),
      ],
    );
  }

  Widget _buildEvaluationButton({
    required String label,
    required Color backgroundColor,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      height: 32,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(backgroundColor),
          foregroundColor: const WidgetStatePropertyAll(Colors.white),
          elevation: const WidgetStatePropertyAll(0),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 14),
          ),
          minimumSize: const WidgetStatePropertyAll(Size(0, 32)),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          ),
          textStyle: const WidgetStatePropertyAll(
            TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
        ),
        child: _isEvaluating
            ? const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  color: Colors.white,
                ),
              )
            : Text(label),
      ),
    );
  }

  Widget _buildHomeButton(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 56,
            height: 56,
            child: FloatingActionButton(
              onPressed: _isEvaluating
                  ? null
                  : () =>
                        Navigator.of(context)
                            .popUntil((route) => route.isFirst),
              backgroundColor: _primaryColor,
              foregroundColor: Colors.white,
              shape: const CircleBorder(),
              elevation: 3,
              child: const Icon(Icons.home_rounded, size: 30),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Beranda',
            style: TextStyle(
              fontSize: 9,
              color: _primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomAppBar(
      color: Colors.white,
      elevation: 2,
      height: 65,
      padding: const EdgeInsets.symmetric(horizontal: 36),
      shape: const CircularNotchedRectangle(),
      notchMargin: 6,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildBottomNavItem(
            icon: Icons.article_outlined,
            label: 'Berkas',
            onTap: _isEvaluating
                ? null
                : () =>
                      Navigator.of(context).popUntil((route) => route.isFirst),
          ),
          const SizedBox(width: 72),
          _buildBottomNavItem(
            icon: Icons.timer_outlined,
            label: 'Statistik',
            onTap: null,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavItem({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
  }) {
    final color = label == 'Berkas' ? _primaryColor : Colors.grey.shade400;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 64,
        height: 65,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}