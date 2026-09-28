import 'package:flutter/material.dart';

import '../repositories/flash_mind_repository.dart';
import 'detail_set_page.dart';
import '../models/flashcard_set.dart';

class AddSetPage extends StatefulWidget {
  const AddSetPage({super.key});

  @override
  State<AddSetPage> createState() => _AddSetPageState();
}

class _AddSetPageState extends State<AddSetPage> {
  static const Color _primaryColor = Color(0xFF192A3A);
  static const Color _accentColor = Color(0xFFF3C279);
  static const Color _backgroundColor = Color(0xFFFBF9F6);
  static const Color _borderColor = Color(0xFFB8B5AF);
  static const Color _errorColor = Color(0xFFD32F2F);

  static const double _bottomBarHeight = 65;
  static const double _fieldFooterHeight = 22;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  int _currentStep = 0;
  bool _titleValidationRequested = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _goBack() {
    if (_currentStep == 1) {
      setState(() {
        _currentStep = 0;
      });
      return;
    }

    Navigator.of(context).pop();
  }

  void _continueFromTitle() {
    final title = _titleController.text.trim();

    if (title.length < 3) {
      setState(() {
        _titleValidationRequested = true;
      });
      return;
    }

    setState(() {
      _currentStep = 1;
      _titleValidationRequested = false;
    });
  }

  Future<void> _createSet() async {
    if (_isSaving) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _isSaving = true;
    });

    final set = await FlashMindRepository.instance.createSet(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
    );

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) =>
            DetailSetPage(setId: set.id, showCreatedNotification: true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double keyboardInset = MediaQuery.of(context).viewInsets.bottom;
    final double extraBottomPadding = (keyboardInset - _bottomBarHeight)
        .clamp(0.0, double.infinity)
        .toDouble();

    return Scaffold(
      backgroundColor: _backgroundColor,
      resizeToAvoidBottomInset: false,
      appBar: _buildAppBar(),
      body: SafeArea(
        bottom: false,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: _currentStep == 0
              ? _buildTitleStep(extraBottomPadding)
              : _buildDescriptionStep(extraBottomPadding),
        ),
      ),
      floatingActionButton: Transform.translate(
        offset: const Offset(0, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 56,
              height: 56,
              child: FloatingActionButton(
                onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
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
      ),
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
        onPressed: _isSaving ? null : _goBack,
        icon: const Icon(Icons.arrow_back, size: 28),
        color: _primaryColor,
        tooltip: 'Kembali',
      ),
      title: const Text(
        'Tambah Set',
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

  Widget _buildTitleStep(double extraBottomPadding) {
    return SingleChildScrollView(
      key: const ValueKey('title-step'),
      padding: EdgeInsets.fromLTRB(20, 16, 20, 32 + extraBottomPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nama Set',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              fontFamily: 'serif',
              color: _primaryColor,
            ),
          ),
          const SizedBox(height: 15),
          _buildInputField(
            controller: _titleController,
            hintText: 'Masukkan nama set dengan jumlah minimal 3 karakter.',
            maxLength: FlashcardSet.titleMaxLength,
            minLines: 8,
            maxLines: 8,
            textInputAction: TextInputAction.next,
          ),
          _buildFieldFooter(
            controller: _titleController,
            maxLength: FlashcardSet.titleMaxLength,
            errorText: 'Nama set minimal 3 karakter.',
            showError: (text) =>
                _titleValidationRequested && text.trim().length < 3,
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: _buildActionButton(
              label: 'Lanjut',
              onPressed: _isSaving ? null : _continueFromTitle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionStep(double extraBottomPadding) {
    return SingleChildScrollView(
      key: const ValueKey('description-step'),
      padding: EdgeInsets.fromLTRB(20, 16, 20, 32 + extraBottomPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Deskripsi Set',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              fontFamily: 'serif',
              color: _primaryColor,
            ),
          ),
          const SizedBox(height: 15),
          _buildInputField(
            controller: _descriptionController,
            hintText: 'Masukkan deskripsi set jika dibutuhkan.',
            maxLength: FlashcardSet.descriptionMaxLength,
            minLines: 8,
            maxLines: 8,
          ),
          _buildFieldFooter(
            controller: _descriptionController,
            maxLength: FlashcardSet.descriptionMaxLength,
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: _buildActionButton(
              label: 'Buat Set',
              onPressed: _isSaving ? null : _createSet,
              isLoading: _isSaving,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required int maxLength,
    required int minLines,
    required int maxLines,
    TextInputAction? textInputAction,
  }) {
    return TextField(
      controller: controller,
      maxLength: maxLength,
      minLines: minLines,
      maxLines: maxLines,
      textInputAction: textInputAction,
      textCapitalization: TextCapitalization.sentences,
      textAlign: TextAlign.justify,
      style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.25),
      decoration: InputDecoration(
        hintText: hintText,
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

  Widget _buildFieldFooter({
    required TextEditingController controller,
    required int maxLength,
    String? errorText,
    bool Function(String text)? showError,
  }) {
    return SizedBox(
      height: _fieldFooterHeight,
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (context, value, _) {
          final bool hasError =
              errorText != null && (showError?.call(value.text) ?? false);

          return Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Padding(
                    // Sejajar dengan teks di dalam kotak (contentPadding = 12).
                    padding: const EdgeInsets.only(left: 12, right: 8),
                    child: hasError
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
                    '${value.text.length}/$maxLength',
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
    bool isLoading = false,
  }) {
    return SizedBox(
      height: 32,
      child: ElevatedButton(
        onPressed: onPressed,
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
        child: isLoading
            ? const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 1.5),
              )
            : Text(label),
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
            onTap: _isSaving ? null : () => Navigator.of(context).pop(),
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
