import 'package:flutter/material.dart';

import '../models/flashcard.dart';
import '../repositories/flash_mind_repository.dart';

import '../widgets/confirm_delete_dialog.dart';
import '../widgets/responsive_scale.dart';
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
  static const Color _primaryColor    = Color(0xFF192A3A);
  static const Color _backgroundColor = Color(0xFFFBF9F6);
  static const Color _borderColor     = Color(0xFFB8B5AF);

  static const int _cardMaxLength = 999;
  static const double _inputBoxHeight = 360;
  static const double _actionsHorizontalPadding = 0;

  final FlashMindRepository _repository = FlashMindRepository.instance;
  late final TextEditingController _frontController;
  late final TextEditingController _backController;

  bool _isBackSide     = false;
  bool _showFrontError = false;
  bool _showBackError  = false;
  bool _isSaving       = false;
  bool _isDeleting     = false;

  TextEditingController get _activeController =>
      _isBackSide ? _backController : _frontController;

  @override
  void initState() {
    super.initState();
    _frontController = TextEditingController(text: widget.card.frontText);
    _backController  = TextEditingController(text: widget.card.backText);
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
    final bool backValid  = _backController.text.trim().isNotEmpty;
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

    final bool frontEmpty = _frontController.text.trim().isEmpty;
    final bool backEmpty  = _backController.text.trim().isEmpty;

    if (frontEmpty && backEmpty) {
      setState(() {
        _isBackSide     = false;
        _showFrontError = true;
        _showBackError  = true;
      });
      return;
    }
    if (frontEmpty) {
      setState(() {
        _isBackSide     = false;
        _showFrontError = true;
      });
      return;
    }
    if (backEmpty) {
      setState(() {
        _isBackSide    = true;
        _showBackError = true;
      });
      return;
    }

    setState(() => _isSaving = true);

    await _repository.updateFlashcard(
      id:        widget.card.id,
      setId:     widget.setId,
      frontText: _frontController.text,
      backText:  _backController.text,
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
      message: 'Kartu ini akan dihapus dari set dan tidak dapat dikembalikan.',
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
          content: Text('Kartu tidak ditemukan.'),
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
    final double s = ResponsiveScale.of(context);
    final double keyboardInset = MediaQuery.of(context).viewInsets.bottom;
    final double extraBottomPadding = keyboardInset.clamp(0.0, double.infinity);

    return Scaffold(
      backgroundColor: _backgroundColor,
      resizeToAvoidBottomInset: false,
      appBar: _buildAppBar(s),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + extraBottomPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeadingRow(s),
              const SizedBox(height: 8),
              SizedBox(height: _inputBoxHeight, child: _buildInputArea(s)),
              AppInputFooter(
                controller: _activeController,
                maxLength: _cardMaxLength,
                errorTextFor: (_) => _footerError(),
              ),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: _actionsHorizontalPadding),
                child: _buildActionRow(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(double s) {
    return AppBar(
      backgroundColor: _backgroundColor,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      leading: IconButton(
        onPressed: (_isSaving || _isDeleting) ? null : _cancelEditing,
        icon: Icon(Icons.arrow_back, size: 28 * s),
        color: _primaryColor,
        tooltip: 'Batalkan pengeditan',
      ),
      title: Text(
        'Edit Kartu',
        style: TextStyle(
          fontSize: 24 * s,
          fontWeight: FontWeight.bold,
          fontFamily: 'serif',
          color: _primaryColor,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildHeadingRow(double s) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            _isBackSide ? 'Sisi Belakang' : 'Sisi Depan',
            style: TextStyle(
              fontSize: 20 * s,
              fontWeight: FontWeight.bold,
              color: _primaryColor,
            ),
          ),
        ),
        _buildFlipButton(s),
      ],
    );
  }

  Widget _buildFlipButton(double s) {
    return Tooltip(
      message: _isBackSide ? 'Tampilkan sisi depan' : 'Balikkan kartu',
      child: TextButton.icon(
        onPressed: (_isSaving || _isDeleting) ? null : _toggleCardSide,
        style: TextButton.styleFrom(
          foregroundColor: _primaryColor,
          padding: EdgeInsets.symmetric(horizontal: 4 * s, vertical: 6 * s),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          textStyle: TextStyle(fontSize: 14 * s, fontWeight: FontWeight.w700),
        ),
        icon: Icon(Icons.swap_horiz, size: 24 * s),
        label: const Text('Balikkan Kartu'),
      ),
    );
  }

  Widget _buildInputArea(double s) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _borderColor, width: 1),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
              color: Color(0x18000000), blurRadius: 2, offset: Offset(0, 1)),
        ],
      ),
      child: TextField(
        controller: _activeController,
        maxLength: _cardMaxLength,
        minLines: null,
        maxLines: null,
        expands: true,
        textCapitalization: TextCapitalization.sentences,
        textAlignVertical: TextAlignVertical.top,
        textAlign: TextAlign.justify,
        style: TextStyle(fontSize: 15 * s, color: _primaryColor, height: 1.45),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
          counterText: '',
          border: InputBorder.none,
          hintText: _isBackSide
              ? 'Masukkan isi dari sisi belakang kartu.'
              : 'Masukkan isi dari sisi depan kartu.',
          hintStyle: TextStyle(
              fontSize: 14 * s, color: const Color(0xFFB4B1AC), height: 1.45),
        ),
      ),
    );
  }

  Widget _buildActionRow() {
    final bool busy = _isSaving || _isDeleting;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppButton(
          label: 'Hapus Kartu',
          tone: AppButtonTone.danger,
          isLoading: _isDeleting,
          onPressed: busy ? null : _confirmDelete,
        ),
        AppButton(
          label: 'Simpan',
          isLoading: _isSaving,
          onPressed: busy ? null : _saveChanges,
        ),
      ],
    );
  }

  // Pesan error footer untuk sisi yang sedang tampil (null bila tidak ada error).
  String? _footerError() {
    final bool showError = _isBackSide ? _showBackError : _showFrontError;
    if (!showError) return null;
    final bool bothEmpty = _frontController.text.trim().isEmpty &&
        _backController.text.trim().isEmpty;
    if (bothEmpty) return 'Sisi depan dan belakang perlu diisi.';
    return _isBackSide ? 'Sisi belakang perlu diisi.' : 'Sisi depan perlu diisi.';
  }
}