import 'package:flutter/material.dart';

import '../repositories/flash_mind_repository.dart';
import 'detail_set_screen.dart';
import '../models/flashcard_set.dart';
import '../widgets/app_button.dart';
import '../widgets/app_input_footer.dart';

class AddSetScreen extends StatefulWidget {
  const AddSetScreen({super.key});

  @override
  State<AddSetScreen> createState() => _AddSetScreenState();
}

class _AddSetScreenState extends State<AddSetScreen> {
  static const Color _primaryColor = Color(0xFF192A3A);
  static const Color _backgroundColor = Color(0xFFFBF9F6);
  static const Color _borderColor = Color(0xFFB8B5AF);

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool _titleValidationRequested = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _createSet() async {
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

    final set = await FlashMindRepository.instance.createSet(
      title: title,
      description: _descriptionController.text.trim(),
    );

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) =>
            DetailSetScreen(setId: set.id, showCreatedNotification: true),
      ),
    );
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
                errorTextFor: (text) => _titleValidationRequested && text.trim().length < 3
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

              // -- Tombol Buat Set
              Align(
                alignment: Alignment.centerRight,
                child: AppButton(
                  label: 'Buat Set',
                  size: AppButtonSize.large,
                  isLoading: _isSaving,
                  onPressed: _isSaving ? null : _createSet,
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