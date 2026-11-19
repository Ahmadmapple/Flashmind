import 'package:flutter/material.dart';

import '../models/flashcard_set.dart';
import '../repositories/flash_mind_repository.dart';
import '../utils/app_colors.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/set_form_body.dart';

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
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: false,
      appBar: AppTopBar(
        title: 'Edit Set',
        onBack: _isSaving ? null : () => Navigator.of(context).pop(),
      ),
      body: SetFormBody(
        titleController: _titleController,
        descriptionController: _descriptionController,
        showTitleError: _titleValidationRequested,
        submitLabel: 'Simpan',
        isSaving: _isSaving,
        onSubmit: _saveChanges,
      ),
    );
  }
}