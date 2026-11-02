import 'package:flutter/material.dart';

import '../models/flashcard.dart';
import '../models/flashcard_set.dart';
import '../repositories/flash_mind_repository.dart';
import 'add_card_page.dart';
import 'edit_set_page.dart';
import 'detail_card_page.dart';
import 'study_session_continue_page.dart';
import 'study_session_start_page.dart';
import 'ai_card_review_page.dart';

import '../widgets/confirm_delete_dialog.dart';
import '../widgets/responsive_scale.dart';
enum _AddCardMode { manual, ai }

class DetailSetPage extends StatefulWidget {
  const DetailSetPage({
    super.key,
    required this.setId,
    this.showCreatedNotification = false,
  });

  final String setId;
  final bool showCreatedNotification;

  @override
  State<DetailSetPage> createState() => _DetailSetPageState();
}

class _DetailSetPageState extends State<DetailSetPage> {
  static const Color _primaryColor = Color(0xFF192A3A);
  static const Color _accentColor  = Color(0xFFF3C279);
  static const Color _dangerColor  = Color(0xFFEF5350);

  static TextStyle _cardBodyStyle(double s) => TextStyle(
    fontSize: 15 * s,
    fontWeight: FontWeight.w600,
    color: _primaryColor,
    height: 1.25,
  );

  static const String _ellipsis = ' ...';
  static const double _bodyToActionsGap = 12;

  final FlashMindRepository _repository = FlashMindRepository.instance;

  bool _isDeleting = false;
  bool _notificationShown = false;

  final Set<String> _backVisibleCardIds = <String>{};

  static String _truncateToFitWords(
    String text,
    TextStyle style,
    double maxWidth,
    TextScaler textScaler, {
    int maxLines = 1,
  }) {
    bool fits(String value) {
      final painter = TextPainter(
        text: TextSpan(text: value, style: style),
        maxLines: maxLines,
        textDirection: TextDirection.ltr,
        textScaler: textScaler,
      )..layout(maxWidth: maxWidth);
      final bool exceeded = painter.didExceedMaxLines;
      painter.dispose();
      return !exceeded;
    }

    if (fits(text)) return text;

    final words = text.trim().split(RegExp(r'\s+'));
    for (int count = words.length - 1; count >= 1; count--) {
      final candidate = '${words.sublist(0, count).join(' ')}$_ellipsis';
      if (fits(candidate)) return candidate;
    }

    return text;
  }

  @override
  void initState() {
    super.initState();
    if (widget.showCreatedNotification) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _notificationShown) return;
        _notificationShown = true;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Set berhasil dibuat.'),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.fromLTRB(20, 0, 20, 10),
          ),
        );
      });
    }
  }

  Future<void> _confirmDelete(FlashcardSet set) async {
    if (_isDeleting) return;

    final bool? confirmed = await showConfirmDeleteDialog(
      context,
      title: 'Hapus Set',
      message:'Set dan kartu di dalamnya akan dihapus.',
      itemName: set.title,
      confirmLabel: 'Hapus',
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isDeleting = true);
    await _repository.deleteSet(set.id);
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  Future<void> _openEditSet(FlashcardSet set) async {
    if (_isDeleting) return;
    final edited = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(builder: (_) => EditSetPage(set: set)),
    );
    if (edited == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Set berhasil diperbarui.'),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.fromLTRB(20, 0, 20, 10),
        ),
      );
    }
  }

  Future<void> _openAddCard() async {
    if (_isDeleting) return;
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(builder: (_) => AddCardPage(setId: widget.setId)),
    );
    if (created == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kartu berhasil dibuat.'),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.fromLTRB(20, 0, 20, 10),
        ),
      );
    }
  }

  Future<void> _openDetailCard(Flashcard card) async {
    if (_isDeleting) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => DetailCardPage(setId: card.setId, cardId: card.id),
      ),
    );
  }

  Future<void> _openAddCardOptions() async {
    if (_isDeleting) return;

    final _AddCardMode? choice = await showModalBottomSheet<_AddCardMode>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final double s = ResponsiveScale.of(ctx);
        final double bottomPadding = MediaQuery.of(ctx).viewPadding.bottom;
        return SafeArea(
          top: false,
          child: Center(
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                    24, 20, 24, 28 + (bottomPadding > 0 ? 0 : 8)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8E4DB),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Tambah Kartu',
                      style: TextStyle(
                        fontSize: 22 * s,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'serif',
                        color: _primaryColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Pilih cara yang ingin kamu gunakan untuk membuat kartu.',
                      style: TextStyle(
                        fontSize: 14 * s,
                        color: Colors.grey,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 54 * s,
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            Navigator.of(ctx).pop(_AddCardMode.manual),
                        icon: Icon(Icons.edit_outlined, size: 22 * s),
                        label: const Text('Buat Kartu Sendiri'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _accentColor,
                          foregroundColor: _primaryColor,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(27 * s),
                          ),
                          textStyle: TextStyle(
                              fontSize: 16 * s, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 54 * s,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.of(ctx).pop(_AddCardMode.ai),
                        icon: Icon(Icons.auto_awesome, size: 22 * s),
                        label: const Text('Gunakan Bantuan AI'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(27 * s),
                          ),
                          textStyle: TextStyle(
                              fontSize: 16 * s, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Bantuan AI membaca dokumen PDF dan membuat kartu secara otomatis. '
                      'Kamu bisa meninjau kartunya sebelum disimpan.',
                      style: TextStyle(
                        fontSize: 12 * s,
                        color: Colors.grey,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    if (choice == null || !mounted) return;

    switch (choice) {
      case _AddCardMode.manual:
        await _openAddCard();
      case _AddCardMode.ai:
        await Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (_) => AiCardReviewPage(
                setId: widget.setId, fileName: 'dokumen.pdf'),
          ),
        );
    }
  }

  Future<void> _openStudySessionStart() async {
    if (_isDeleting) return;
    final inProgressSession = _repository.getInProgressStudySessionForSet(widget.setId);
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => inProgressSession == null
            ? StudySessionStartPage(setId: widget.setId)
            : StudySessionContinuePage(setId: widget.setId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F6),
      appBar: _buildAppBar(),
      body: AnimatedBuilder(
        animation: _repository,
        builder: (context, _) {
          final set = _repository.getSetById(widget.setId);
          if (set == null) {
            return const Center(child: Text('Set tidak ditemukan.'));
          }
          return _buildContent(set);
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final double s = ResponsiveScale.of(context);
    return AppBar(
      backgroundColor: const Color(0xFFFBF9F6),
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      toolbarHeight: 60 * s,
      leading: IconButton(
        onPressed: _isDeleting ? null : () => Navigator.of(context).pop(),
        icon: Icon(Icons.arrow_back, size: 28 * s),
        color: _primaryColor,
        tooltip: 'Kembali',
      ),
      title: Text(
        'Detail Set',
        style: TextStyle(
          fontSize: 25 * s,
          fontWeight: FontWeight.bold,
          fontFamily: 'serif',
          color: _primaryColor,
        ),
      ),
      centerTitle: false,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 14, top: 10, bottom: 10),
          child: TextButton(
            onPressed: _isDeleting
                ? null
                : () {
                    final set = _repository.getSetById(widget.setId);
                    if (set != null) _openEditSet(set);
                  },
            style: TextButton.styleFrom(
              backgroundColor: _primaryColor,
              foregroundColor: Colors.white,
              minimumSize: Size(100 * s, 35 * s),
              padding: EdgeInsets.symmetric(horizontal: 15 * s),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              textStyle: TextStyle(
                fontSize: 14 * s,
                fontWeight: FontWeight.w700,
              ),
            ),
            child: const Text('Edit Set'),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(FlashcardSet set) {
    final double s = ResponsiveScale.of(context);
    final bool isEmpty = set.cardCount == 0;

    return SafeArea(
      top: false,
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              set.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 22 * s,
                fontWeight: FontWeight.bold,
                color: _primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              set.description.isEmpty ? 'Tidak ada deskripsi set.' : set.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.justify,
              style: TextStyle(fontSize: 13 * s, color: Colors.grey, height: 1.25),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(child: _buildDeleteButton(set, s)),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStudyButton(
                    s: s,
                    enabled: !isEmpty,
                    hasInProgressSession:
                        _repository.getInProgressStudySessionForSet(set.id) != null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildAddCardButton(s),
            const SizedBox(height: 28),
            if (isEmpty)
              _buildEmptyState(s)
            else
              _buildCardList(set.cards, s),
          ],
        ),
      ),
    );
  }

  Widget _buildCardList(List<Flashcard> cards, double s) {
    return Column(
      children: [
        for (int i = 0; i < cards.length; i++) ...[
          _buildFlashcardCard(cards[i], s),
          if (i < cards.length - 1) const SizedBox(height: 14),
        ],
      ],
    );
  }

  Widget _buildFlashcardCard(Flashcard card, double s) {
    final bool isBackVisible  = _backVisibleCardIds.contains(card.id);
    final String text         = isBackVisible ? card.backText : card.frontText;
    final String sideLabel    = isBackVisible ? 'Sisi Belakang' : 'Sisi Depan';
    final String flipTooltip  = isBackVisible ? 'Tampilkan sisi depan' : 'Balikkan kartu';

    final TextStyle bodyStyle = _cardBodyStyle(s);
    final TextStyle effectiveBodyStyle = DefaultTextStyle.of(context).style.merge(bodyStyle);
    final TextScaler textScaler        = MediaQuery.textScalerOf(context);

    return Container(
      width: double.infinity,
      height: 155 * s,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE8E4DB), width: 1.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            sideLabel,
            style: TextStyle(
              fontSize: 12 * s,
              fontWeight: FontWeight.bold,
              fontFamily: 'serif',
              color: const Color(0xFF9A9894),
            ),
          ),
          const SizedBox(height: 5),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double lineHeight =
                    effectiveBodyStyle.fontSize! * (effectiveBodyStyle.height ?? 1.0);
                final int availableLines =
                    (constraints.maxHeight / lineHeight).floor().clamp(1, 10);
                final String displayText = _truncateToFitWords(
                  text,
                  effectiveBodyStyle,
                  constraints.maxWidth,
                  textScaler,
                  maxLines: availableLines,
                );
                return Text(
                  displayText,
                  maxLines: availableLines,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.justify,
                  style: bodyStyle,
                );
              },
            ),
          ),
          const SizedBox(height: _bodyToActionsGap),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Tooltip(
                message: flipTooltip,
                child: TextButton.icon(
                  onPressed: () {
                    setState(() {
                      if (isBackVisible) {
                        _backVisibleCardIds.remove(card.id);
                      } else {
                        _backVisibleCardIds.add(card.id);
                      }
                    });
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF9A9894),
                    padding: EdgeInsets.symmetric(horizontal: 2 * s, vertical: 2 * s),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  icon: Icon(Icons.swap_horiz, size: 24 * s),
                  label: Text('Balikkan Kartu', style: TextStyle(fontSize: 13 * s)),
                ),
              ),
              TextButton(
                onPressed: () => _openDetailCard(card),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFD97745),
                  padding: EdgeInsets.symmetric(horizontal: 2 * s, vertical: 2 * s),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Lihat Detail →',
                  style: TextStyle(fontSize: 13 * s, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddCardButton(double s) {
    return SizedBox(
      width: double.infinity,
      height: 45 * s,
      child: OutlinedButton.icon(
        onPressed: _isDeleting ? null : _openAddCardOptions,
        icon: Icon(Icons.add_rounded, size: 22 * s),
        label: const Text('Tambah Kartu'),
        style: OutlinedButton.styleFrom(
          foregroundColor: _primaryColor,
          backgroundColor: Colors.white,
          side: const BorderSide(color: _primaryColor, width: 1.3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22 * s)),
          textStyle: TextStyle(fontSize: 14 * s, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _buildDeleteButton(FlashcardSet set, double s) {
    return SizedBox(
      height: 40 * s,
      child: ElevatedButton(
        onPressed: _isDeleting ? null : () => _confirmDelete(set),
        style: ButtonStyle(
          backgroundColor: const WidgetStatePropertyAll(_dangerColor),
          foregroundColor: const WidgetStatePropertyAll(Colors.white),
          elevation: const WidgetStatePropertyAll(0),
          padding: const WidgetStatePropertyAll(
              EdgeInsets.symmetric(horizontal: 12)),
          minimumSize: WidgetStatePropertyAll(Size(0, 40 * s)),
          shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(22))),
          textStyle: WidgetStatePropertyAll(
              TextStyle(fontSize: 14 * s, fontWeight: FontWeight.w700)),
        ),
        child: _isDeleting
            ? SizedBox(
                width: 14 * s,
                height: 14 * s,
                child: const CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : const Text('Hapus Set'),
      ),
    );
  }

  Widget _buildStudyButton({
    required double s,
    required bool enabled,
    required bool hasInProgressSession,
  }) {
    return SizedBox(
      height: 40 * s,
      child: ElevatedButton(
        onPressed: enabled && !_isDeleting ? _openStudySessionStart : null,
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (!enabled || states.contains(WidgetState.disabled)) {
              return Colors.grey.shade200;
            }
            return _accentColor;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (!enabled || states.contains(WidgetState.disabled)) {
              return Colors.grey.shade400;
            }
            return _primaryColor;
          }),
          elevation: const WidgetStatePropertyAll(0),
          padding: const WidgetStatePropertyAll(
              EdgeInsets.symmetric(horizontal: 12)),
          minimumSize: WidgetStatePropertyAll(Size(0, 40 * s)),
          shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
          textStyle: WidgetStatePropertyAll(TextStyle(fontSize: 14 * s, fontWeight: FontWeight.w700)),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(hasInProgressSession ? 'Lanjut Belajar' : 'Mulai Belajar'),
        ),
      ),
    );
  }

  Widget _buildEmptyState(double s) {
    return SizedBox(
      height: 250,
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Belum ada kartu dalam set ini.',
              style: TextStyle(fontSize: 14 * s, color: Colors.grey),
            ),
          ),
          const Spacer(),
          Text(
            'Tekan tombol Tambah Kartu di atas untuk menambahkan kartu ke dalam set.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13 * s, color: const Color(0xFF9A9894), height: 1.35),
          ),
        ],
      ),
    );
  }
}