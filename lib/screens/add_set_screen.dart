import 'package:flutter/material.dart';

import '../repositories/flash_mind_repository.dart';
import '../utils/app_colors.dart';
import '../models/flashcard_set.dart';

import 'detail_set_screen.dart';

import '../widgets/app_top_bar.dart';
import '../widgets/set_form_body.dart';

class AddSetScreen extends StatefulWidget {
  const AddSetScreen({super.key});

  @override
  State<AddSetScreen> createState() => _AddSetScreenState();
}

class _AddSetScreenState extends State<AddSetScreen> {
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

    if (title.length < FlashcardSet.titleMinLength) {
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
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: false,
      appBar: AppTopBar(
        title: 'Tambah Set',
        onBack: _isSaving ? null : () => Navigator.of(context).pop(),
      ),
      body: SetFormBody(
        titleController: _titleController,
        descriptionController: _descriptionController,
        showTitleError: _titleValidationRequested,
        submitLabel: 'Buat Set',
        isSaving: _isSaving,
        onSubmit: _createSet,
      ),
    );
  }
}