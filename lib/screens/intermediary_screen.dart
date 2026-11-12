import 'package:flutter/material.dart';

import '../widgets/app_bottom_nav.dart';
import 'beranda_screen.dart';
import 'berkas_screen.dart';
import 'statistic_screen.dart';

// Wadah navigasi utama yang menampung Beranda, Berkas, dan Statistik.
class IntermediaryScreen extends StatefulWidget {
  const IntermediaryScreen({super.key});

  @override
  State<IntermediaryScreen> createState() => _IntermediaryScreenState();
}

class _IntermediaryScreenState extends State<IntermediaryScreen> {
  AppNavTab _selectedTab = AppNavTab.beranda;
  final GlobalKey<BerkasScreenState> _berkasKey =
      GlobalKey<BerkasScreenState>();

  void _selectTab(AppNavTab tab) {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _selectedTab = tab);
  }

  void _openReviewBerkas() {
    _berkasKey.currentState?.showReviewFilter();
    _selectTab(AppNavTab.berkas);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F6),
      resizeToAvoidBottomInset: false,
      body: IndexedStack(
        index: _selectedTab.index,
        children: [
          BerkasScreen(key: _berkasKey),
          BerandaScreen(onViewAllReviews: _openReviewBerkas),
          const StatisticScreen(),
        ],
      ),
      floatingActionButton: AppHomeFab(
        isActive: _selectedTab == AppNavTab.beranda,
        onPressed: () => _selectTab(AppNavTab.beranda),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AppBottomNavBar(
        selectedTab: _selectedTab,
        onBerkasTap: () => _selectTab(AppNavTab.berkas),
        onStatistikTap: () => _selectTab(AppNavTab.statistik),
      ),
    );
  }
}