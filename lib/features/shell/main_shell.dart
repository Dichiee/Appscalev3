import 'package:flutter/material.dart';
import '../../shared/widgets/main_scaffold.dart';
import '../beneficiary/add_profile_sheet.dart';
import '../dashboard/dashboard_screen.dart';
import '../masterlist/masterlist_screen.dart';
import '../../shared/widgets/coming_soon_placeholder.dart';
import '../program/program_screen.dart';
import '../reports/reports_home_screen.dart';

import '../masterlist/widgets/masterlist_header.dart';

/// The single owner of the bottom nav. Add a new tab by adding one
/// entry to IndexedStack and one item in AppBottomNav — nothing else changes.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _navIndex = 0;
  final _masterlistKey = GlobalKey<MasterlistScreenState>();

  void _navigateToMasterlist(MasterlistCategory category) {
    setState(() => _navIndex = 1);
    _masterlistKey.currentState?.setCategory(category);
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      currentIndex: _navIndex,
      onTabSelected: (index) => setState(() => _navIndex = index),
      onAddPressed: () => AddProfileSheet.show(context),
      body: IndexedStack(
        index: _navIndex,
        children: [
          DashboardBody(onNavigateToMasterlist: _navigateToMasterlist),
          MasterlistScreen(key: _masterlistKey),
          const ProgramScreen(),
          const ReportsHomeScreen(),
        ],
      ),
    );
  }
}

