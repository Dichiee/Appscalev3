import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../data/local/app_data_bus.dart';
import '../../data/local/mother_repository.dart';
import '../../data/models/mother.dart';
import '../../shared/utils/app_page_route.dart';
import '../../shared/widgets/deactivate_beneficiary_sheet.dart';
import '../beneficiary/add_mother_screen.dart';
import 'widgets/children_tab.dart';
import 'widgets/info_tab.dart';
import 'widgets/mother_profile_header.dart';
import 'widgets/mother_profile_tab_bar.dart';
import 'widgets/visits_tab.dart';
import 'add_counseling_visit_screen.dart';

class MotherProfileScreen extends StatefulWidget {
  final Mother mother;
  const MotherProfileScreen({super.key, required this.mother});

  @override
  State<MotherProfileScreen> createState() => _MotherProfileScreenState();
}

class _MotherProfileScreenState extends State<MotherProfileScreen> {
  int _tabIndex = 0;
  late final String _motherId = widget.mother.id;

  Future<void> _handleEdit(Mother current) async {
    await Navigator.push<Mother>(context, appPageRoute(AddMotherScreen(existingMother: current)));
    // No manual refresh needed — AddMotherScreen's save already calls
    // MotherRepository.update, which fires AppDataBus, which this screen
    // is already listening to below.
  }

  Future<void> _handleAddVisit(Mother current) async {
    await Navigator.push(context, appPageRoute(AddCounselingVisitScreen(mother: current)));
  }

  Future<void> _handleStatusAction(Mother current) async {
    if (current.isActive) {
      final reason = await DeactivateBeneficiarySheet.show(
        context,
        beneficiaryName: current.fullName,
        reasons: const ['Transferred', 'Deceased', 'Other'],
        accentColor: const Color(0xFF9A2D5E),
      );
      if (reason != null) {
        await MotherRepository().update(current.copyWith(isActive: false, inactiveReason: reason));
      }
    } else {
      await MotherRepository().update(current.copyWith(isActive: true, inactiveReason: null));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: AppDataBus.version,
      builder: (context, version, child) {
        final mother = MotherRepository().getById(_motherId) ?? widget.mother;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              children: [
                MotherProfileHeader(
                  mother: mother,
                  onEditPressed: () => _handleEdit(mother),
                  onStatusActionPressed: () => _handleStatusAction(mother),
                  onAddVisitPressed: () => _handleAddVisit(mother),
                ),
                MotherProfileTabBar(currentIndex: _tabIndex, onChanged: (i) => setState(() => _tabIndex = i)),
                Expanded(
                  child: IndexedStack(
                    index: _tabIndex,
                    children: [
                      InfoTab(mother: mother),
                      VisitsTab(mother: mother),
                      ChildrenTab(mother: mother, onChanged: () {}),
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