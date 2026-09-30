import 'package:flutter/material.dart';

import '../models/flashcard_set.dart';
import '../repositories/flash_mind_repository.dart';

class EditSetPage extends StatefulWidget {
  const EditSetPage({super.key, required this.set});

  final FlashcardSet set;

  @override
  State<EditSetPage> createState() => _EditSetPageState();
}

class _EditSetPageState extends State<EditSetPage> {
  static const Color _primaryColor = Color(0xFF192A3A);
  static const Color _accentColor = Color(0xFFF3C279);
  static const Color _backgroundColor = Color(0xFFFBF9F6);
  static const Color _borderColor = Color(0xFFB8B5AF);
  static const Color _errorColor = Color(0xFFD32F2F);

  static const double _fieldFooterHeight = 22;

  final FlashMindRepository _repository = FlashMindRepository.instance;
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  bool _titleValidationRequested = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.set.title);
    _descriptionController = TextEditingController(
      text: widget.set.description,
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    final title = _titleController.text.trim();

    if (title.length < 3) {
      setState(() {
        _titleValidationRequested = true;
      });
      return;
    }

    if (_isSaving) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _isSaving = true;
    });

    await _repository.updateSet(
      id: widget.set.id,
      title: title,
      description: _descriptionController.text.trim(),
    );

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final double keyboardInset = MediaQuery.of(context).viewInsets.bottom;
    final double extraBottomPadding =
        keyboardInset.clamp(0.0, double.infinity).toDouble();

    return Scaffold(
      backgroundColor: _backgroundColor,
      resizeToAvoidBottomInset: false,
      appBar: _buildAppBar(),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 32 + extraBottomPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // -- Nama Set --
              const Text(
                'Nama Set',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'serif',
                  color: _primaryColor,
                ),
              ),
              const SizedBox(height: 12),
              _buildInputField(
                controller: _titleController,
                hintText: 'Masukkan nama set (minimal 3 karakter).',
                maxLength: FlashcardSet.titleMaxLength,
                minLines: 4,
                maxLines: 4,
                textInputAction: TextInputAction.next,
              ),
              _buildFieldFooter(
                controller: _titleController,
                maxLength: FlashcardSet.titleMaxLength,
                errorText: 'Nama set minimal 3 karakter.',
                showError: (text) =>
                    _titleValidationRequested && text.trim().length < 3,
              ),
              const SizedBox(height: 24),

              // -- Deskripsi Set --
              const Text(
                'Deskripsi Set',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'serif',
                  color: _primaryColor,
                ),
              ),
              const SizedBox(height: 12),
              _buildInputField(
                controller: _descriptionController,
                hintText: 'Masukkan deskripsi set jika dibutuhkan.',
                maxLength: FlashcardSet.descriptionMaxLength,
                minLines: 4,
                maxLines: 4,
              ),
              _buildFieldFooter(
                controller: _descriptionController,
                maxLength: FlashcardSet.descriptionMaxLength,
              ),
              const SizedBox(height: 20),

              // -- Tombol Simpan --
              Align(
                alignment: Alignment.centerRight,
                child: _buildActionButton(
                  label: 'Simpan',
                  onPressed: _isSaving ? null : _saveChanges,
                  isLoading: _isSaving,
                ),
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
        onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
        icon: const Icon(Icons.arrow_back, size: 28),
        color: _primaryColor,
        tooltip: 'Kembali',
      ),
      title: const Text(
        'Edit Set',
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
}
