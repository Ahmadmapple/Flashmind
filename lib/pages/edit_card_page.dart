import 'package:flutter/material.dart';

import '../models/flashcard.dart';
import '../repositories/flash_mind_repository.dart';

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

  static const double _fieldFooterHeight        = 22;
  static const int    _cardMaxLength            = 999;
  static const double _inputBoxHeight           = 360;
  static const double _contentToActionsGap      = 28;
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

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Kartu'),
        content: const Text('Apakah Anda yakin ingin menghapus kartu ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            style: TextButton.styleFrom(foregroundColor: Colors.grey),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: _dangerColor),
            child: const Text('Hapus'),
          ),
        ],
      ),
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
    final double keyboardInset      = MediaQuery.of(context).viewInsets.bottom;
    final double extraBottomPadding = keyboardInset.clamp(0.0, double.infinity);

    return Scaffold(
      backgroundColor: _backgroundColor,
      resizeToAvoidBottomInset: false,
      appBar: _buildAppBar(),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + extraBottomPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeadingRow(),
              const SizedBox(height: 8),
              SizedBox(height: _inputBoxHeight, child: _buildInputArea()),
              _buildFieldFooter(),
              const SizedBox(height: _contentToActionsGap - _fieldFooterHeight),
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

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _backgroundColor,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      leading: IconButton(
        onPressed: (_isSaving || _isDeleting) ? null : _cancelEditing,
        icon: const Icon(Icons.arrow_back, size: 28),
        color: _primaryColor,
        tooltip: 'Batalkan pengeditan',
      ),
      title: const Text(
        'Edit Kartu',
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

  Widget _buildHeadingRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            _isBackSide ? 'Sisi Belakang' : 'Sisi Depan',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _primaryColor,
            ),
          ),
        ),
        _buildFlipButton(),
      ],
    );
  }

  Widget _buildFlipButton() {
    return Tooltip(
      message: _isBackSide ? 'Tampilkan sisi depan' : 'Balikkan kartu',
      child: TextButton.icon(
        onPressed: (_isSaving || _isDeleting) ? null : _toggleCardSide,
        style: TextButton.styleFrom(
          foregroundColor: _primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 2),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
        icon: const Icon(Icons.swap_horiz, size: 23),
        label: const Text('Balikkan Kartu'),
      ),
    );
  }

  Widget _buildInputArea() {
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
        style: const TextStyle(
            fontSize: 14, color: _primaryColor, height: 1.45),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
          counterText: '',
          border: InputBorder.none,
          hintText: _isBackSide
              ? 'Masukkan isi dari sisi belakang kartu.'
              : 'Masukkan isi dari sisi depan kartu.',
          hintStyle: const TextStyle(
              fontSize: 14, color: Color(0xFFB4B1AC), height: 1.45),
        ),
      ),
    );
  }

  Widget _buildFieldFooter() {
    return SizedBox(
      height: _fieldFooterHeight,
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
                            style: const TextStyle(
                                color: _errorColor, fontSize: 12, height: 1.2),
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Text(
                    '${value.text.length}/$_cardMaxLength',
                    style: const TextStyle(
                        fontSize: 10, color: Color(0xFF9A9894), height: 1.6),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [_buildDeleteButton(), _buildFinishButton()],
    );
  }

  Widget _buildDeleteButton() {
    return SizedBox(
      height: 40,
      child: ElevatedButton(
        onPressed: (_isSaving || _isDeleting) ? null : _confirmDelete,
        style: ButtonStyle(
          backgroundColor: const WidgetStatePropertyAll(_dangerColor),
          foregroundColor: const WidgetStatePropertyAll(Colors.white),
          elevation: const WidgetStatePropertyAll(0),
          padding: const WidgetStatePropertyAll(
              EdgeInsets.symmetric(horizontal: 16)),
          minimumSize: const WidgetStatePropertyAll(Size(88, 40)),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          textStyle: const WidgetStatePropertyAll(
              TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
        ),
        child: _isDeleting
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                    strokeWidth: 1.5, color: Colors.white),
              )
            : const Text('Hapus Kartu'),
      ),
    );
  }

  Widget _buildFinishButton() {
    return SizedBox(
      height: 40,
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
          padding: const WidgetStatePropertyAll(
              EdgeInsets.symmetric(horizontal: 20)),
          minimumSize: const WidgetStatePropertyAll(Size(110, 40)),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Color(0xFFD7A957), width: 0.7),
            ),
          ),
          textStyle: const WidgetStatePropertyAll(
              TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
        ),
        child: _isSaving
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                    strokeWidth: 1.5, color: _primaryColor),
              )
            : const Text('Simpan'),
      ),
    );
  }
}
