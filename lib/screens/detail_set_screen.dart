import 'package:flutter/material.dart';

import '../models/flashcard.dart';
import '../models/flashcard_set.dart';
import '../repositories/flash_mind_repository.dart';
import '../utils/app_colors.dart';
import 'add_card_screen.dart';
import 'edit_set_screen.dart';
import 'detail_card_screen.dart';
import 'study_session_continue_screen.dart';
import 'study_session_start_screen.dart';
import 'ai_card_review_screen.dart';

import '../widgets/app_top_bar.dart';
import '../widgets/confirm_delete_dialog.dart';
import '../utils/responsive_scale.dart';
import '../widgets/app_item_card.dart';
import '../widgets/app_button.dart';

enum _AddCardMode { manual, ai }

class DetailSetScreen extends StatefulWidget {
  const DetailSetScreen({
    super.key,
    required this.setId,
    this.showCreatedNotification = false,
  });

  final String setId;
  final bool showCreatedNotification;

  @override
  State<DetailSetScreen> createState() => _DetailSetScreenState();
}

class _DetailSetScreenState extends State<DetailSetScreen> {
  static TextStyle _cardBodyStyle(double s) => TextStyle(
    fontSize: AppFont.bodyLarge * s,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
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
      message: 'Set dan kartu di dalamnya akan dihapus.',
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
      MaterialPageRoute<bool>(builder: (_) => EditSetScreen(set: set)),
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
      MaterialPageRoute<bool>(builder: (_) => AddCardScreen(setId: widget.setId)),
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
        builder: (_) => DetailCardScreen(setId: card.setId, cardId: card.id),
      ),
    );
  }

  Future<void> _openAddCardOptions() async {
    if (_isDeleting) return;

    final _AddCardMode? choice = await showModalBottomSheet<_AddCardMode>(
      context: context,
      backgroundColor: AppColors.surface,
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
              constraints: BoxConstraints(maxWidth: 560 * s),
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
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Tambah Kartu',
                      style: TextStyle(
                        fontSize: AppFont.heading * s,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'serif',
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Pilih cara yang ingin kamu gunakan untuk membuat kartu.',
                      style: TextStyle(
                        fontSize: AppFont.body * s,
                        color: AppColors.muted,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 24),
                    AppButton(
                      label: 'Buat Kartu Sendiri',
                      icon: Icons.edit_outlined,
                      size: AppButtonSize.large,
                      expand: true,
                      onPressed: () => Navigator.of(ctx).pop(_AddCardMode.manual),
                    ),
                    const SizedBox(height: 12),
                    AppButton(
                      label: 'Gunakan Bantuan AI',
                      icon: Icons.auto_awesome,
                      tone: AppButtonTone.primary,
                      size: AppButtonSize.large,
                      expand: true,
                      onPressed: () => Navigator.of(ctx).pop(_AddCardMode.ai),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Bantuan AI membaca dokumen PDF dan membuat kartu secara otomatis. '
                      'Kamu bisa meninjau kartunya sebelum disimpan.',
                      style: TextStyle(
                        fontSize: AppFont.small * s,
                        color: AppColors.muted,
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
            builder: (_) => AiCardReviewScreen(
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
            ? StudySessionStartScreen(setId: widget.setId)
            : StudySessionContinueScreen(setId: widget.setId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
    return AppTopBar(
      title: 'Detail Set',
      centerTitle: false,
      onBack: _isDeleting ? null : () => Navigator.of(context).pop(),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 14, top: 8, bottom: 8),
          child: AppButton(
            label: 'Edit Set',
            size: AppButtonSize.medium,
            onPressed: _isDeleting
                ? null
                : () {
                    final set = _repository.getSetById(widget.setId);
                    if (set != null) _openEditSet(set);
                  },
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
        child: AppContentFrame(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                set.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: AppFont.heading * s,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                set.description.isEmpty ? 'Tidak ada deskripsi set.' : set.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.justify,
                style: TextStyle(
                    fontSize: AppFont.small * s, color: AppColors.muted, height: 1.25),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'Hapus Set',
                      tone: AppButtonTone.danger,
                      expand: true,
                      isLoading: _isDeleting,
                      onPressed: _isDeleting ? null : () => _confirmDelete(set),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      label: _repository.getInProgressStudySessionForSet(set.id) != null
                          ? 'Lanjut Belajar'
                          : 'Mulai Belajar',
                      expand: true,
                      onPressed: (!isEmpty && !_isDeleting) ? _openStudySessionStart : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildAddCardButton(),
              const SizedBox(height: 28),
              if (isEmpty)
                _buildEmptyState(s)
              else
                _buildCardList(set.cards, s),
            ],
          ),
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
    final bool isBackVisible = _backVisibleCardIds.contains(card.id);
    final String text = isBackVisible ? card.backText : card.frontText;
    final String sideLabel = isBackVisible ? 'Sisi Belakang' : 'Sisi Depan';
    final String flipTooltip = isBackVisible ? 'Tampilkan sisi depan' : 'Balikkan kartu';

    final TextStyle bodyStyle = _cardBodyStyle(s);
    final TextStyle effectiveBodyStyle = DefaultTextStyle.of(context).style.merge(bodyStyle);
    final TextScaler textScaler = MediaQuery.textScalerOf(context);

    return AppItemCard(
      height: 155 * s,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      headerGap: 5,
      footerGap: _bodyToActionsGap,
      header: Text(
        sideLabel,
        style: TextStyle(
          fontSize: AppFont.caption * s,
          fontWeight: FontWeight.bold,
          fontFamily: 'serif',
          color: AppColors.muted,
        ),
      ),
      body: LayoutBuilder(
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
      footer: Row(
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
                foregroundColor: AppColors.muted,
                padding: EdgeInsets.symmetric(horizontal: 2 * s, vertical: 2 * s),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              icon: Icon(Icons.swap_horiz, size: 24 * s),
              label: Text('Balikkan Kartu',
                  style: TextStyle(fontSize: AppFont.small * s)),
            ),
          ),
          AppDetailLink(onPressed: () => _openDetailCard(card)),
        ],
      ),
    );
  }

  // "Tambah Kartu"
  Widget _buildAddCardButton() {
    return AppButton(
      label: 'Tambah Kartu',
      icon: Icons.add_rounded,
      tone: AppButtonTone.primary,
      size: AppButtonSize.large,
      expand: true,
      onPressed: _isDeleting ? null : _openAddCardOptions,
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
              style: TextStyle(fontSize: AppFont.body * s, color: AppColors.muted),
            ),
          ),
          const Spacer(),
          Text(
            'Tekan tombol Tambah Kartu di atas untuk menambahkan kartu ke dalam set.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: AppFont.small * s, color: AppColors.muted, height: 1.35),
          ),
        ],
      ),
    );
  }
}