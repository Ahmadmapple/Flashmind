import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/responsive_scale.dart';

// AppBar: tombol kembali dan judul
// onBack null -> tombol kembali nonaktif
class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar({
    super.key,
    required this.title,
    required this.onBack,
    this.centerTitle = true,
    this.actions,
    this.backTooltip = 'Kembali',
  });

  final String title;
  final VoidCallback? onBack;
  final bool centerTitle;
  final List<Widget>? actions;
  final String backTooltip;

  static const double height = 60;

  @override
  Size get preferredSize => const Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    final double s = context.scale;
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      toolbarHeight: height,
      centerTitle: centerTitle,
      leading: IconButton(
        onPressed: onBack,
        icon: Icon(Icons.arrow_back, size: 28 * s),
        color: AppColors.primary,
        tooltip: backTooltip,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: AppFont.appBar * s,
          fontWeight: FontWeight.bold,
          fontFamily: 'serif',
          color: AppColors.primary,
        ),
      ),
      actions: actions,
    );
  }
}