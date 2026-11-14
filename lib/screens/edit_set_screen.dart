import 'package:flutter/material.dart';

import '../models/flashcard_set.dart';
import '../repositories/flash_mind_repository.dart';
import '../utils/app_colors.dart';
import '../utils/responsive_scale.dart';
import '../widgets/app_button.dart';
import '../widgets/app_input_footer.dart';
import '../widgets/app_text_field.dart';
import '../widgets/app_top_bar.dart';

class EditSetScreen extends StatefulWidget {
  const EditSetScreen({super.key, required this.set});

  final FlashcardSet set;

  @override
  State<EditSetScreen> createState() => _EditSetScreenState();
}

class _EditSetScreenState extends State<EditSetScreen> {
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
    final double s = context.scale;
    final double keyboardInset = MediaQuery.of(context).viewInsets.bottom;
    final double extraBottomPadding =
        keyboardInset.clamp(0.0, double.infinity).toDouble();
    final TextStyle labelStyle = TextStyle(
      fontSize: AppFont.heading * s,
      fontWeight: FontWeight.bold,
      color: AppColors.primary,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: false,
      appBar: AppTopBar(
        title: 'Edit Set',
        onBack: _isSaving ? null : () => Navigator.of(context).pop(),
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 32 + extraBottomPadding),
          child: AppContentFrame(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nama Set
                Text('Nama Set', style: labelStyle),
                const SizedBox(height: 12),
                AppTextField(
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
                Text('Deskripsi Set', style: labelStyle),
                const SizedBox(height: 12),
                AppTextField(
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
      ),
    );
  }
}