import 'package:flutter/material.dart';

import 'responsive_scale.dart';
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

  static const Color _primary = Color(0xFF192A3A);
  static const Color _danger = Color(0xFFEF5350);
  static const Color _background = Color(0xFFFBF9F6);
  static const Color _border = Color(0xFFE8E4DB);

  @override
  Widget build(BuildContext context) {
    final double s = ResponsiveScale.of(context);

    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64 * s,
                height: 64 * s,
                decoration: BoxDecoration(
                  color: _danger.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.delete_outline_rounded,
                    color: _danger, size: 32 * s),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22 * s,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'serif',
                  color: _primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15 * s,
                  color: Colors.black54,
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
                    color: _background,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _border, width: 1.5),
                  ),
                  child: WordEllipsisText(
                    itemName!,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15 * s,
                      fontWeight: FontWeight.w700,
                      color: _primary,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48 * s,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _primary,
                          side: const BorderSide(color: _primary, width: 1.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24 * s),
                          ),
                          textStyle: TextStyle(
                              fontSize: 15 * s, fontWeight: FontWeight.w700),
                        ),
                        child: Text(cancelLabel),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 48 * s,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _danger,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24 * s),
                          ),
                          textStyle: TextStyle(
                              fontSize: 15 * s, fontWeight: FontWeight.w700),
                        ),
                        child: Text(confirmLabel),
                      ),
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