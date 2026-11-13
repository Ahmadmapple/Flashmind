import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../repositories/flash_mind_repository.dart';
import '../widgets/app_button.dart';
import '../widgets/app_input_footer.dart';

class AddCardScreen extends StatefulWidget {
  const AddCardScreen({super.key, required this.setId});

  final String setId;

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  static const Color _primaryColor = Color(0xFF192A3A);
  static const Color _backgroundColor = Color(0xFFFBF9F6);
  static const Color _borderColor = Color(0xFFB8B5AF);

  static const int _cardMaxLength = 999;

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

    final frontEmpty = _frontController.text.trim().isEmpty;
    final backEmpty = _backController.text.trim().isEmpty;

    if (frontEmpty && backEmpty) {
      setState(() {
        _isBackSide = false;
        _showFrontError = true;
        _showBackError = true;
      });
      return;
    }

    if (frontEmpty) {
      setState(() {
        _isBackSide = false;
        _showFrontError = true;
      });
      return;
    }

    if (backEmpty) {
      setState(() {
        _isBackSide = true;
        _showBackError = true;
      });
      return;
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
            'Set tidak ditemukan sehingga kartu tidak dapat dibuat.',
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
    final media = MediaQuery.of(context);
    final keyboardInset = media.viewInsets.bottom;
    final extraBottomPadding =
        keyboardInset.clamp(0.0, double.infinity).toDouble();

    final double inputBoxHeight =
        (media.size.height * _inputBoxHeightFactor)
            .clamp(_inputBoxMinHeight, _inputBoxMaxHeight)
            .toDouble();

    return Scaffold(
      backgroundColor: _backgroundColor,
      resizeToAvoidBottomInset: false,
      appBar: _buildAppBar(),
      body: SafeArea(
        bottom: false,
        child: _buildContent(extraBottomPadding, inputBoxHeight),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _backgroundColor,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      leading: IconButton(
        onPressed: _goBack,
        icon: const Icon(Icons.arrow_back, size: 28),
        color: _primaryColor,
        tooltip: 'Kembali',
      ),
      title: const Text(
        'Tambah Kartu',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          fontFamily: 'serif',
          color: _primaryColor,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildContent(double extraBottomPadding, double inputBoxHeight) {
    final isBack = _isBackSide;
    final controller = _activeController;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 32 + extraBottomPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  isBack ? 'Sisi Belakang' : 'Sisi Depan',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _primaryColor,
                  ),
                ),
              ),
              _buildFlipButton(),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: inputBoxHeight,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: SizedBox.expand(
                key: ValueKey<bool>(isBack),
                child: _buildInputField(controller: controller, isBack: isBack),
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
    );
  }

  Widget _buildFlipButton() {
    return Tooltip(
      message: 'Balikkan kartu',
      child: TextButton.icon(
        onPressed: _toggleCardSide,
        style: TextButton.styleFrom(
          foregroundColor: _primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
        icon: const Icon(Icons.swap_horiz, size: 23),
        label: const Text('Balikkan Kartu'),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required bool isBack,
  }) {
    return TextField(
      controller: controller,
      maxLength: _cardMaxLength,
      maxLengthEnforcement: MaxLengthEnforcement.enforced,
      expands: true,
      minLines: null,
      maxLines: null,
      keyboardType: TextInputType.multiline,
      textCapitalization: TextCapitalization.sentences,
      textAlignVertical: TextAlignVertical.top,
      textAlign: TextAlign.justify,
      style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.25),
      decoration: InputDecoration(
        hintText: isBack
            ? 'Masukkan isi dari sisi belakang kartu.\nMinimal 1 karakter.'
            : 'Masukkan isi dari sisi depan kartu.\nMinimal 1 karakter.',
        hintStyle: const TextStyle(
          fontSize: 14,
          color: Color(0xFFB4B1AC),
          height: 1.25,
        ),
        contentPadding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        counterText: '',
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _borderColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _primaryColor, width: 1.2),
        ),
      ),
    );
  }

  // Pesan eror untuk sisi yang tampil (null bila tidak ada eror)
  String? _footerError(bool isBack) {
    final bool showError = isBack ? _showBackError : _showFrontError;
    if (!showError) return null;
    final bool bothEmpty = _frontController.text.trim().isEmpty &&
        _backController.text.trim().isEmpty;
    if (bothEmpty) return 'Sisi depan dan belakang perlu diisi.';
    return isBack ? 'Sisi belakang perlu diisi.' : 'Sisi depan perlu diisi.';
  }
}
