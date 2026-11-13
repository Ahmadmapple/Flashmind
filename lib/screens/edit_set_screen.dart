import 'package:flutter/material.dart';

import '../models/flashcard_set.dart';
import '../repositories/flash_mind_repository.dart';
import '../widgets/app_button.dart';
import '../widgets/app_input_footer.dart';

class EditSetScreen extends StatefulWidget {
  const EditSetScreen({super.key, required this.set});

  final FlashcardSet set;

  @override
  State<EditSetScreen> createState() => _EditSetScreenState();
}

class _EditSetScreenState extends State<EditSetScreen> {
  static const Color _primaryColor = Color(0xFF192A3A);
  static const Color _backgroundColor = Color(0xFFFBF9F6);
  static const Color _borderColor = Color(0xFFB8B5AF);

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
                  color: _primaryColor,
                ),
              ),
              const SizedBox(height: 12),
              _buildInputField(
                controller: _titleController,
                hintText: 'Masukkan nama set (minimal 3 karakter).',
                maxLength: FlashcardSet.titleMaxLength,
                minLines: 2,
                maxLines: 2,
                textInputAction: TextInputAction.next,
              ),
              AppInputFooter(
                controller: _titleController,
                maxLength: FlashcardSet.titleMaxLength,
                errorTextFor: (text) =>
                    _titleValidationRequested && text.trim().length < 3
                        ? 'Nama set minimal 3 karakter.'
                        : null,
              ),
              const SizedBox(height: 24),

              // -- Deskripsi Set --
              const Text(
                'Deskripsi Set',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: _primaryColor,
                ),
              ),
              const SizedBox(height: 12),
              _buildInputField(
                controller: _descriptionController,
                hintText: 'Masukkan deskripsi set jika dibutuhkan.',
                maxLength: FlashcardSet.descriptionMaxLength,
                minLines: 6,
                maxLines: 6,
              ),
              AppInputFooter(
                controller: _descriptionController,
                maxLength: FlashcardSet.descriptionMaxLength,
              ),
              const SizedBox(height: 20),

              // -- Tombol Simpan
              Align(
                alignment: Alignment.centerRight,
                child: AppButton(
                  label: 'Simpan',
                  size: AppButtonSize.large,
                  isLoading: _isSaving,
                  onPressed: _isSaving ? null : _saveChanges,
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
}