import 'package:flutter/material.dart';

import '../repositories/flash_mind_repository.dart';
import '../utils/app_colors.dart';
import '../utils/responsive_scale.dart';
import '../services/card_form_rules.dart';
import '../widgets/app_button.dart';
import '../widgets/app_input_footer.dart';
import '../widgets/app_text_field.dart';
import '../widgets/app_top_bar.dart';

class AddCardScreen extends StatefulWidget {
  const AddCardScreen({super.key, required this.setId});

  final String setId;

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  static const int _cardMaxLength = CardFormRules.maxLength;

  static const double _inputBoxHeightFactor = 0.45;
  static const double _inputBoxMinHeight = 280;
  static const double _inputBoxMaxHeight = 460;

  final TextEditingController _frontController = TextEditingController();
  final TextEditingController _backController = TextEditingController();

  bool _showFrontError = false;
  bool _showBackError = false;
  bool _isBackSide = false;
  bool _isSaving = false;

  final FlashMindRepository _repository = FlashMindRepository.instance;

  TextEditingController get _activeController =>
      _isBackSide ? _backController : _frontController;

  @override
  void initState() {
    super.initState();
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

    final frontValid = _frontController.text.trim().isNotEmpty;
    final backValid = _backController.text.trim().isNotEmpty;

    if ((_showFrontError && frontValid) || (_showBackError && backValid)) {
      setState(() {
        if (frontValid) _showFrontError = false;
        if (backValid) _showBackError = false;
      });
    }
  }

  void _goBack() {
    Navigator.of(context).pop();
  }

  void _toggleCardSide() {
    FocusScope.of(context).unfocus();
    setState(() {
      _isBackSide = !_isBackSide;
    });
  }

  Future<void> _tryCreateCard() async {
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

    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    final card = await _repository.addFlashcard(
      setId: widget.setId,
      frontText: _frontController.text.trim(),
      backText: _backController.text.trim(),
    );

    if (!mounted) return;

    if (card == null) {
      setState(() {
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Set tidak ditemukan sehingga kartu tidak dapat dibuat',
          ),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.fromLTRB(20, 0, 20, 10),
        ),
      );
      return;
    }

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final double s = context.scale;
    final media = MediaQuery.of(context);
    final keyboardInset = media.viewInsets.bottom;
    final extraBottomPadding = keyboardInset
        .clamp(0.0, double.infinity)
        .toDouble();

    final double inputBoxHeight = (media.size.height * _inputBoxHeightFactor)
        .clamp(_inputBoxMinHeight, _inputBoxMaxHeight * s)
        .toDouble();

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: false,
      appBar: AppTopBar(title: 'Tambah Kartu', onBack: _goBack),
      body: SafeArea(
        bottom: false,
        child: _buildContent(s, extraBottomPadding, inputBoxHeight),
      ),
    );
  }

  Widget _buildContent(
    double s,
    double extraBottomPadding,
    double inputBoxHeight,
  ) {
    final isBack = _isBackSide;
    final controller = _activeController;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 32 + extraBottomPadding),
      child: AppContentFrame(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    isBack ? 'Sisi Belakang' : 'Sisi Depan',
                    style: TextStyle(
                      fontSize: AppFont.title * s,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                _buildFlipButton(s),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: inputBoxHeight,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: SizedBox.expand(
                  key: ValueKey<bool>(isBack),
                  child: AppTextField(
                    controller: controller,
                    maxLength: _cardMaxLength,
                    expands: true,
                    hintText: isBack
                        ? 'Masukkan isi dari sisi belakang kartu.\nMinimal 1 karakter'
                        : 'Masukkan isi dari sisi depan kartu.\nMinimal 1 karakter',
                  ),
                ),
              ),
            ),
            AppInputFooter(
              controller: controller,
              maxLength: _cardMaxLength,
              errorTextFor: (_) => _footerError(isBack),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: AppButton(
                label: 'Buat Kartu',
                size: AppButtonSize.large,
                isLoading: _isSaving,
                onPressed: _isSaving ? null : _tryCreateCard,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlipButton(double s) {
    return Tooltip(
      message: 'Balikkan kartu',
      child: TextButton.icon(
        onPressed: _toggleCardSide,
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: EdgeInsets.symmetric(horizontal: 4 * s, vertical: 6 * s),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          textStyle: TextStyle(
            fontSize: AppFont.body * s,
            fontWeight: FontWeight.w700,
          ),
        ),
        icon: Icon(Icons.swap_horiz, size: 24 * s),
        label: const Text('Balikkan Kartu'),
      ),
    );
  }

  // Pesan eror untuk sisi yang tampil (null bila tidak ada eror)
  String? _footerError(bool isBack) => CardFormRules.footerError(
        isBack: isBack,
        showError: isBack ? _showBackError : _showFrontError,
        front: _frontController.text,
        back: _backController.text,
  );
}
