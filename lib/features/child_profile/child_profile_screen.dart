import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../data/local/app_data_bus.dart';
import '../../data/local/child_repository.dart';
import '../../data/models/child.dart';
import '../../shared/utils/app_page_route.dart';
import '../../shared/widgets/coming_soon_placeholder.dart';
import '../../shared/widgets/deactivate_beneficiary_sheet.dart';
import '../beneficiary/add_child_screen.dart';
import 'add_measurement_screen.dart';
import 'widgets/charts_tab.dart';
import 'widgets/child_profile_header.dart';
import 'widgets/history_tab.dart';
import 'widgets/info_tab.dart';
import 'widgets/profile_tab_bar.dart';

class ChildProfileScreen extends StatefulWidget {
  final Child child;
  const ChildProfileScreen({super.key, required this.child});

  @override
  State<ChildProfileScreen> createState() => _ChildProfileScreenState();
}

class _ChildProfileScreenState extends State<ChildProfileScreen> {
  int _tabIndex = 0;
  late final String _childId = widget.child.id;

  Future<void> _handleEdit(Child current) async {
    await Navigator.push<Child>(context, appPageRoute(AddChildScreen(existingChild: current)));
  }

  Future<void> _handleMeasure(Child current) async {
    await Navigator.push<Child>(context, appPageRoute(AddMeasurementScreen(child: current)));
  }

  Future<void> _handleStatusAction(Child current) async {
    if (current.isActive) {
      final reason = await DeactivateBeneficiarySheet.show(
        context,
        beneficiaryName: current.fullName,
        reasons: const ['Transferred', 'Deceased', 'Other'],
      );
      if (reason != null) {
        await ChildRepository().update(current.copyWith(isActive: false, inactiveReason: reason));
      }
    } else {
      await ChildRepository().update(current.copyWith(isActive: true, inactiveReason: null));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: AppDataBus.version,
      builder: (context, value, childWidget) {
        final child = ChildRepository().getAll().firstWhere((c) => c.id == _childId, orElse: () => widget.child);

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              children: [
                ChildProfileHeader(
                  child: child,
                  isActive: child.isActive,
                  onEditPressed: () => _handleEdit(child),
                  onStatusActionPressed: () => _handleStatusAction(child),
                  onMeasurePressed: () => _handleMeasure(child),
                ),
                ProfileTabBar(currentIndex: _tabIndex, onChanged: (i) => setState(() => _tabIndex = i)),
                Expanded(
                  child: IndexedStack(
                    index: _tabIndex,
                    children: [
                      InfoTab(child: child),
                      HistoryTab(childId: child.id),
                      ChartsTab(childId: child.id),
                      const ComingSoonPlaceholder(label: 'Programs'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}