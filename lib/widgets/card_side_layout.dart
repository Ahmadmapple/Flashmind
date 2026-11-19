import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/responsive_scale.dart';

// Desain dasar untuk layar yang menampilkan sisi kartu, yaitu Detail Kartu dan Edit Kartu. 

class CardSideLayout extends StatelessWidget {
  const CardSideLayout({
    super.key,
    required this.sideLabel,
    required this.flipTooltip,
    required this.onFlip,
    required this.box,
    required this.leftAction,
    required this.rightAction,
    this.boxFooter,
    this.bottomPadding = 50,
  });

  final String sideLabel;
  final String flipTooltip;

  // null = tombol balik nonaktif
  final VoidCallback? onFlip;

  final Widget box;
  final Widget leftAction;
  final Widget rightAction;
  final Widget? boxFooter;
  final double bottomPadding;

  static const double boxToActionsGap = 30;

  @override
  Widget build(BuildContext context) {
    final double s = context.scale;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, bottomPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  sideLabel,
                  style: TextStyle(
                    fontSize: AppFont.title * s,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'serif',
                    color: AppColors.primary,
                  ),
                ),
              ),
              Tooltip(
                message: flipTooltip,
                child: TextButton.icon(
                  onPressed: onFlip,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(
                      horizontal: 4 * s,
                      vertical: 6 * s,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  icon: Icon(Icons.swap_horiz, size: 25 * s),
                  label: Text(
                    'Balikkan Kartu',
                    style: TextStyle(
                      fontSize: AppFont.bodyLarge * s,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(child: box),
          // Footer berada di dalam jarak 30 px agar posisi tombol tetap sama.
          SizedBox(height: boxToActionsGap, child: boxFooter),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [leftAction, rightAction],
            ),
          ),
        ],
      ),
    );
  }
}

// Kotak putih berbingkai tempat isi sisi kartu
class CardSideBox extends StatelessWidget {
  const CardSideBox({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(14, 13, 14, 13),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.borderStrong, width: 1),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: child,
    );
  }
}