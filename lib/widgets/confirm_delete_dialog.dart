import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import 'app_button.dart';
import '../utils/responsive_scale.dart';
import 'word_ellipsis_text.dart';

// Dialog konfirmasi hapus yang digunakan layar Hapus Set dan Hapus Kartu
// Mengembalikan `true` bila pengguna menekan tombol hapus.
Future<bool?> showConfirmDeleteDialog(
  BuildContext context, {
  required String title,
  required String message,
  String? itemName,
  String confirmLabel = 'Hapus',
  String cancelLabel = 'Batal',
}) {
  return showDialog<bool>(
    context: context,
    builder: (_) => _ConfirmDeleteDialog(
      title: title,
      message: message,
      itemName: itemName,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
    ),
  );
}

class _ConfirmDeleteDialog extends StatelessWidget {
  const _ConfirmDeleteDialog({
    required this.title,
    required this.message,
    required this.itemName,
    required this.confirmLabel,
    required this.cancelLabel,
  });

  final String title;
  final String message;
  final String? itemName;
  final String confirmLabel;
  final String cancelLabel;

  @override
  Widget build(BuildContext context) {
    final double s = ResponsiveScale.of(context);

    return Dialog(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 440 * s),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64 * s,
                height: 64 * s,
                decoration: BoxDecoration(
                  color: AppColors.danger.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.delete_outline_rounded,
                    color: AppColors.danger, size: 32 * s),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppFont.heading * s,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'serif',
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppFont.bodyLarge * s,
                  color: AppColors.textSecondary,
                  height: 1.45,
                ),
              ),
              if (itemName != null && itemName!.trim().isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border, width: 1.5),
                  ),
                  child: WordEllipsisText(
                    itemName!,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: AppFont.bodyLarge * s,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: cancelLabel,
                      tone: AppButtonTone.primary,
                      size: AppButtonSize.large,
                      expand: true,
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      label: confirmLabel,
                      tone: AppButtonTone.danger,
                      size: AppButtonSize.large,
                      expand: true,
                      onPressed: () => Navigator.of(context).pop(true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}