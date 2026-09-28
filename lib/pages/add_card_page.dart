import 'package:flutter/material.dart';

import '../repositories/flash_mind_repository.dart';

class AddCardPage extends StatefulWidget {
  const AddCardPage({super.key, required this.setId});

  final String setId;

  @override
  State<AddCardPage> createState() => _AddCardPageState();
}

class _AddCardPageState extends State<AddCardPage> {
  static const Color _primaryColor = Color(0xFF192A3A);
  static const Color _accentColor = Color(0xFFF3C279);
  static const Color _backgroundColor = Color(0xFFFBF9F6);
  static const Color _borderColor = Color(0xFFB8B5AF);
  static const Color _errorColor = Color(0xFFD32F2F);

  static const double _bottomBarHeight = 65;
  static const double _fieldFooterHeight = 22;

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
    final keyboardInset = MediaQuery.of(context).viewInsets.bottom;
    final extraBottomPadding = (keyboardInset - _bottomBarHeight)
        .clamp(0.0, double.infinity)
        .toDouble();

    return Scaffold(
      backgroundColor: _backgroundColor,
      resizeToAvoidBottomInset: false,
      appBar: _buildAppBar(),
      body: SafeArea(bottom: false, child: _buildContent(extraBottomPadding)),
      floatingActionButton: _buildHomeButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomNavigationBar(),
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

  Widget _buildContent(double extraBottomPadding) {
    final isBack = _isBackSide;
    final controller = _activeController;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      child: SingleChildScrollView(
        key: ValueKey<bool>(isBack),
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
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'serif',
                      color: _primaryColor,
                    ),
                  ),
                ),
                _buildFlipButton(),
              ],
            ),
            const SizedBox(height: 12),
            _buildInputField(controller: controller, isBack: isBack),
            _buildFieldFooter(isBack: isBack, controller: controller),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: _buildActionButton(
                label: 'Buat Kartu',
                onPressed: _isSaving ? null : _tryCreateCard,
              ),
            ),
          ],
        ),
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
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        return TextField(
          controller: controller,
          maxLength: 999,
          minLines: 8,
          maxLines: null,
          textCapitalization: TextCapitalization.sentences,
          textAlignVertical: TextAlignVertical.top,
          style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.25),
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
      },
    );
  }

  Widget _buildFieldFooter({
    required bool isBack,
    required TextEditingController controller,
  }) {
    return SizedBox(
      height: _fieldFooterHeight,
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (context, value, _) {
          final showError = isBack ? _showBackError : _showFrontError;
          final bothEmpty =
              _frontController.text.trim().isEmpty &&
              _backController.text.trim().isEmpty;
          final errorText = bothEmpty
              ? 'Sisi depan dan belakang perlu diisi.'
              : isBack
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
                              color: _errorColor,
                              fontSize: 12,
                              height: 1.2,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Text(
                    '${value.text.length}/999',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF9A9894),
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      height: 32,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          backgroundColor: const WidgetStatePropertyAll(_accentColor),
          foregroundColor: const WidgetStatePropertyAll(_primaryColor),
          elevation: const WidgetStatePropertyAll(0),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 18),
          ),
          minimumSize: const WidgetStatePropertyAll(Size(100, 32)),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: const BorderSide(color: Color(0xFFD7A957), width: 0.7),
            ),
          ),
          textStyle: const WidgetStatePropertyAll(
            TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
        ),
        child: _isSaving
            ? const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  color: _primaryColor,
                ),
              )
            : Text(label),
      ),
    );
  }

  Widget _buildHomeButton() {
    return Transform.translate(
      offset: const Offset(0, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 56,
            height: 56,
            child: FloatingActionButton(
              onPressed: _goBack,
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
      height: _bottomBarHeight,
      padding: const EdgeInsets.symmetric(horizontal: 36),
      shape: const CircularNotchedRectangle(),
      notchMargin: 6,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildBottomNavItem(
            icon: Icons.article_outlined,
            label: 'Berkas',
            onTap: _goBack,
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
        height: _bottomBarHeight,
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
