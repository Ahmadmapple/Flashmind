import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/responsive_scale.dart';

// Tujuan bar navigasi, yaitu Beranda, Berkas, dan Statistik
// Urutan enum
enum AppNavTab { berkas, beranda, statistik }

// Konstanta ukuran dan warna yang dipakai oleh bar navigasi dan tombol Beranda.
class AppNavStyle {
  const AppNavStyle._();
  static const double barHeight = 65;
  static const Color primary = AppColors.primary; 
  static const Color background = AppColors.surface;
}

class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.selectedTab,
    this.onBerkasTap,
    this.onStatistikTap,
    this.compact = false,
    this.elevation,
  });

  final AppNavTab selectedTab;
  final VoidCallback? onBerkasTap;
  final VoidCallback? onStatistikTap;
  final bool compact;
  final double? elevation;

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: AppNavStyle.background,
      elevation: elevation,
      shape: const CircularNotchedRectangle(),
      notchMargin: 6.0,
      padding: EdgeInsets.symmetric(horizontal: 36.0 * context.scale),
      height: AppNavStyle.barHeight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _NavItem(
            icon: Icons.description,
            label: 'Berkas',
            selected: selectedTab == AppNavTab.berkas,
            compact: compact,
            onTap: onBerkasTap,
          ),
          _NavItem(
            icon: Icons.bar_chart,
            label: 'Statistik',
            selected: selectedTab == AppNavTab.statistik,
            compact: compact,
            onTap: onStatistikTap,
          ),
        ],
      ),
    );
  }
}

class AppHomeFab extends StatelessWidget {
  const AppHomeFab({
    super.key,
    required this.isActive,
    required this.onPressed,
    this.compact = false,
  });

  final bool isActive;
  final VoidCallback? onPressed;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final double s = context.scale;
    final Color labelColor = isActive ? AppNavStyle.primary : AppColors.inactive;

    return Transform.translate(
      offset: const Offset(0, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 56,
            height: 56,
            child: FloatingActionButton(
              onPressed: onPressed,
              backgroundColor: isActive ? AppNavStyle.primary : Colors.white,
              shape: const CircleBorder(),
              elevation: 3,
              child: Icon(
                Icons.home_rounded,
                color: isActive ? Colors.white : AppColors.inactive,
                size: 30,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Beranda',
            style: TextStyle(
              fontSize: (compact ? 10 : AppFont.caption) * s,
              color: labelColor,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.compact,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final bool compact;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final double s = context.scale;
    final Color color = selected ? AppNavStyle.primary : AppColors.inactive;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: (compact ? 64 : 72) * s,
        height: AppNavStyle.barHeight,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: (compact ? 22 : 28) * s),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: (compact ? 10 : AppFont.caption) * s,
                color: color,
                fontWeight: selected ? FontWeight.bold : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}