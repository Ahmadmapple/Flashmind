import 'package:flutter/material.dart';

import '../models/flashcard.dart';
import '../repositories/flash_mind_repository.dart';

import '../widgets/confirm_delete_dialog.dart';
import '../widgets/responsive_scale.dart';

enum EditCardResult { saved, deleted }

class EditCardPage extends StatefulWidget {
  const EditCardPage({super.key, required this.setId, required this.card});

  final String setId;
  final Flashcard card;

  @override
  State<EditCardPage> createState() => _EditCardPageState();
}

class _EditCardPageState extends State<EditCardPage> {
  static const Color _primaryColor    = Color(0xFF192A3A);
  static const Color _accentColor     = Color(0xFFF3C279);
  static const Color _backgroundColor = Color(0xFFFBF9F6);
  static const Color _borderColor     = Color(0xFFB8B5AF);
  static const Color _errorColor      = Color(0xFFD32F2F);
  static const Color _dangerColor     = Color(0xFFEF5350);

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
              _buildFieldFooter(s),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: _actionsHorizontalPadding),
                child: _buildActionRow(s),
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

  Widget _buildFieldFooter(double s) {
    return SizedBox(
      height: 26 * s,
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: _activeController,
        builder: (context, value, _) {
          final bool frontEmpty = _frontController.text.trim().isEmpty;
          final bool backEmpty  = _backController.text.trim().isEmpty;
          final bool showError  = _isBackSide ? _showBackError : _showFrontError;
          final String errorText = frontEmpty && backEmpty
              ? 'Sisi depan dan belakang perlu diisi.'
              : _isBackSide
                  ? 'Sisi belakang perlu diisi.'
                  : 'Sisi depan perlu diisi.';

          return Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12, right: 8),
                    child: showError
                        ? Text(
                            errorText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: _errorColor,
                                fontSize: 13 * s,
                                height: 1.2),
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Text(
                    '${value.text.length}/$_cardMaxLength',
                    style: TextStyle(
                        fontSize: 12 * s,
                        color: const Color(0xFF9A9894),
                        height: 1.4),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionRow(double s) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [_buildDeleteButton(s), _buildFinishButton(s)],
    );
  }

  Widget _buildDeleteButton(double s) {
    return SizedBox(
      height: 40 * s,
      child: ElevatedButton(
        onPressed: (_isSaving || _isDeleting) ? null : _confirmDelete,
        style: ButtonStyle(
          backgroundColor: const WidgetStatePropertyAll(_dangerColor),
          foregroundColor: const WidgetStatePropertyAll(Colors.white),
          elevation: const WidgetStatePropertyAll(0),
          padding: WidgetStatePropertyAll(
              EdgeInsets.symmetric(horizontal: 18 * s)),
          minimumSize: WidgetStatePropertyAll(Size(110 * s, 35 * s)),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          textStyle: WidgetStatePropertyAll(
              TextStyle(fontSize: 14 * s, fontWeight: FontWeight.w700)),
        ),
        child: _isDeleting
            ? SizedBox(
                width: 16 * s,
                height: 16 * s,
                child: const CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : const Text('Hapus Kartu'),
      ),
    );
  }

  Widget _buildFinishButton(double s) {
    return SizedBox(
      height: 40 * s,
      child: ElevatedButton(
        onPressed: (_isSaving || _isDeleting) ? null : _saveChanges,
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return _accentColor.withValues(alpha: 0.55);
            }
            return _accentColor;
          }),
          foregroundColor: const WidgetStatePropertyAll(_primaryColor),
          elevation: const WidgetStatePropertyAll(0),
          padding: WidgetStatePropertyAll(
              EdgeInsets.symmetric(horizontal: 18 * s)),
          minimumSize: WidgetStatePropertyAll(Size(110 * s, 35 * s)),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Color(0xFFD7A957), width: 0.7),
            ),
          ),
          textStyle: WidgetStatePropertyAll(
              TextStyle(fontSize: 14 * s, fontWeight: FontWeight.w700)),
        ),
        child: _isSaving
            ? SizedBox(
                width: 16 * s,
                height: 16 * s,
                child: const CircularProgressIndicator(
                    strokeWidth: 2, color: _primaryColor),
              )
            : const Text('Simpan'),
      ),
    );
  }
}