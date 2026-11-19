import 'package:flutter/material.dart';

import '../models/flashcard_set.dart';
import '../utils/app_colors.dart';
import '../utils/responsive_scale.dart';
import 'app_button.dart';
import 'app_input_footer.dart';
import 'app_text_field.dart';

// Isi formulir Nama Set dan Deskripsi Set yang dipakai Tambah Set dan Edit Set
class SetFormBody extends StatelessWidget {
  const SetFormBody({
    super.key,
    required this.titleController,
    required this.descriptionController,
    required this.showTitleError,
    required this.submitLabel,
    required this.isSaving,
    required this.onSubmit,
  });

  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final bool showTitleError;
  final String submitLabel;
  final bool isSaving;
  final VoidCallback onSubmit;

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

    return SafeArea(
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
                controller: titleController,
                hintText: 'Masukkan nama set (minimal 3 karakter).',
                maxLength: FlashcardSet.titleMaxLength,
                minLines: 2,
                maxLines: 2,
                textInputAction: TextInputAction.next,
              ),
              AppInputFooter(
                controller: titleController,
                maxLength: FlashcardSet.titleMaxLength,
                errorTextFor: (text) => showTitleError &&
                        text.trim().length < FlashcardSet.titleMinLength
                    ? 'Nama set minimal 3 karakter.'
                    : null,
              ),
              const SizedBox(height: 24),

              // Deskripsi Set
              Text('Deskripsi Set', style: labelStyle),
              const SizedBox(height: 12),
              AppTextField(
                controller: descriptionController,
                hintText: 'Masukkan deskripsi set jika dibutuhkan.',
                maxLength: FlashcardSet.descriptionMaxLength,
                minLines: 6,
                maxLines: 6,
              ),
              AppInputFooter(
                controller: descriptionController,
                maxLength: FlashcardSet.descriptionMaxLength,
              ),
              const SizedBox(height: 20),

              // Tombol aksi
              Align(
                alignment: Alignment.centerRight,
                child: AppButton(
                  label: submitLabel,
                  size: AppButtonSize.large,
                  isLoading: isSaving,
                  onPressed: isSaving ? null : onSubmit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}