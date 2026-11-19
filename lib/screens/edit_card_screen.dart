import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../models/flashcard.dart';
import '../repositories/flash_mind_repository.dart';
import '../utils/app_colors.dart';
import '../utils/responsive_scale.dart';
import '../services/card_form_rules.dart';

import '../widgets/app_bottom_nav.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/card_side_layout.dart';
import '../widgets/confirm_delete_dialog.dart';
import '../widgets/app_button.dart';
import '../widgets/app_input_footer.dart';

enum EditCardResult { saved, deleted }

class EditCardScreen extends StatefulWidget {
  const EditCardScreen({super.key, required this.setId, required this.card});

  final String setId;
  final Flashcard card;

  @override
  State<EditCardScreen> createState() => _EditCardScreenState();
}

class _EditCardScreenState extends State<EditCardScreen> {
  static const int _cardMaxLength = CardFormRules.maxLength;

  final FlashMindRepository _repository = FlashMindRepository.instance;
  late final TextEditingController _frontController;
  late final TextEditingController _backController;

  bool _isBackSide = false;
  bool _showFrontError = false;
  bool _showBackError = false;
  bool _isSaving = false;
  bool _isDeleting = false;

  TextEditingController get _activeController =>
      _isBackSide ? _backController : _frontController;

  @override
  void initState() {
    super.initState();
    _frontController = TextEditingController(text: widget.card.frontText);
    _backController = TextEditingController(text: widget.card.backText);
    _frontController.addListener(_handleTextChanged);
    _backController.addListener(_handleTextChanged);
  }

  @override
  void dispose() {
    _frontController.removeListener(_handleTextChanged);
    _backController.removeListener(_handleTextChanged);
    _frontController.dispose();
    _backController.dispose();
    super.dispose();
  }

  void _handleTextChanged() {
    if (!mounted) return;
    final bool frontValid = _frontController.text.trim().isNotEmpty;
    final bool backValid = _backController.text.trim().isNotEmpty;
    if ((_showFrontError && frontValid) || (_showBackError && backValid)) {
      setState(() {
        if (frontValid) _showFrontError = false;
        if (backValid) _showBackError = false;
      });
    }
  }

  void _cancelEditing() {
    if (_isSaving || _isDeleting) return;
    FocusScope.of(context).unfocus();
    Navigator.of(context).pop();
  }

  void _toggleCardSide() {
    if (_isSaving || _isDeleting) return;
    FocusScope.of(context).unfocus();
    setState(() => _isBackSide = !_isBackSide);
  }

  Future<void> _saveChanges() async {
    if (_isSaving || _isDeleting) return;
    FocusScope.of(context).unfocus();

    switch (CardFormRules.evaluate(
        _frontController.text, _backController.text)) {
      case CardFormIssue.both:
        setState(() {
          _isBackSide = false;
          _showFrontError = true;
          _showBackError = true;
        });
        return;
      case CardFormIssue.frontOnly:
        setState(() {
          _isBackSide = false;
          _showFrontError = true;
        });
        return;
      case CardFormIssue.backOnly:
        setState(() {
          _isBackSide = true;
          _showBackError = true;
        });
        return;
      case CardFormIssue.none:
        break;
    }

    setState(() => _isSaving = true);

    await _repository.updateFlashcard(
      id: widget.card.id,
      setId: widget.setId,
      frontText: _frontController.text,
      backText: _backController.text,
    );

    if (!mounted) return;
    setState(() => _isSaving = false);
    Navigator.of(context).pop(EditCardResult.saved);
  }

  Future<void> _confirmDelete() async {
    if (_isSaving || _isDeleting) return;

    final bool? confirmed = await showConfirmDeleteDialog(
      context,
      title: 'Hapus Kartu',
      message: 'Kartu ini akan dihapus dari set dan tidak dapat dikembalikan',
      confirmLabel: 'Hapus',
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isDeleting = true);

    final bool deleted = await _repository.deleteFlashcard(widget.card.id);

    if (!mounted) return;

    if (!deleted) {
      setState(() => _isDeleting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kartu tidak ditemukan'),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.fromLTRB(20, 0, 20, 16),
        ),
      );
      return;
    }

    Navigator.of(context).pop(EditCardResult.deleted);
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData media = MediaQuery.of(context);
    final bool busy = _isSaving || _isDeleting;

    final double reserved = AppNavStyle.barHeight + media.padding.bottom;
    final double bottomPadding =
        math.max(reserved + 50, media.viewInsets.bottom + 20);

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: false,
      appBar: AppTopBar(
        title: 'Edit Kartu',
        backTooltip: 'Batalkan pengeditan',
        onBack: busy ? null : _cancelEditing,
      ),
      body: SafeArea(
        bottom: false,
        child: AppContentFrame(
          child: CardSideLayout(
            sideLabel: _isBackSide ? 'Sisi Belakang' : 'Sisi Depan',
            flipTooltip: _isBackSide ? 'Tampilkan sisi depan' : 'Balikkan kartu',
            onFlip: busy ? null : _toggleCardSide,
            bottomPadding: bottomPadding,
            box: _buildInputBox(context.scale),
            boxFooter: AppInputFooter(
              controller: _activeController,
              maxLength: _cardMaxLength,
              errorTextFor: (_) => _footerError(),
            ),
            leftAction: AppButton(
              label: 'Hapus Kartu',
              tone: AppButtonTone.danger,
              isLoading: _isDeleting,
              onPressed: busy ? null : _confirmDelete,
            ),
            rightAction: AppButton(
              label: 'Simpan',
              isLoading: _isSaving,
              onPressed: busy ? null : _saveChanges,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputBox(double s) {
    return CardSideBox(
      child: TextField(
        key: ValueKey<bool>(_isBackSide),
        controller: _activeController,
        maxLength: _cardMaxLength,
        minLines: null,
        maxLines: null,
        expands: true,
        textCapitalization: TextCapitalization.sentences,
        textAlignVertical: TextAlignVertical.top,
        textAlign: TextAlign.justify,
        style: TextStyle(
          fontSize: AppFont.bodyLarge * s,
          color: AppColors.primary,
          height: 1.45,
        ),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.only(right: 13),
          counterText: '',
          border: InputBorder.none,
          hintText: _isBackSide
              ? 'Masukkan isi dari sisi belakang kartu'
              : 'Masukkan isi dari sisi depan kartu',
          hintStyle: TextStyle(
            fontSize: AppFont.bodyLarge * s,
            color: AppColors.hint,
            height: 1.45,
          ),
        ),
      ),
    );
  }

  // Pesan error footer untuk sisi yang sedang tampil (null bila tidak ada error).
  String? _footerError() => CardFormRules.footerError(
        isBack: _isBackSide,
        showError: _isBackSide ? _showBackError : _showFrontError,
        front: _frontController.text,
        back: _backController.text,
  );
}