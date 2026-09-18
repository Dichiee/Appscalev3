import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/local/app_data_bus.dart';
import '../../data/local/child_repository.dart';
import '../../data/local/mother_repository.dart';
import '../../data/models/child.dart';
import '../../data/models/child_status_filter.dart';
import '../../data/models/mother.dart';
import '../../shared/utils/app_page_route.dart';
import '../../shared/widgets/empty_state.dart';
import '../child_profile/child_profile_screen.dart';
import '../mother_profile/mother_profile_screen.dart';
import 'widgets/child_list_tile.dart';
import 'widgets/masterlist_header.dart';
import 'widgets/masterlist_search_bar.dart';
import 'widgets/masterlist_tabs.dart';
import 'widgets/mother_list_tile.dart';
import 'widgets/status_filter_sheet.dart';

const _currentBarangay = 'Tiguion'; // TODO: pull from logged-in BNS session

class MasterlistScreen extends StatefulWidget {
  final MasterlistCategory initialCategory;
  const MasterlistScreen({super.key, this.initialCategory = MasterlistCategory.children});

  @override
  State<MasterlistScreen> createState() => MasterlistScreenState();
}

class MasterlistScreenState extends State<MasterlistScreen> {
  final _childRepo = ChildRepository();
  final _motherRepo = MotherRepository();

  late MasterlistCategory _category = widget.initialCategory;
  bool _showingActive = true;
  String _query = '';
  ChildStatusFilter _filter = const ChildStatusFilter();

  void setCategory(MasterlistCategory category) {
    setState(() {
      _category = category;
      _query = '';
      _filter = const ChildStatusFilter();
    });
  }

  Future<void> _openFilter() async {
    final result = await StatusFilterSheet.show(context, _filter);
    if (result != null) setState(() => _filter = result);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: AppDataBus.version,
      builder: (context, value, childWidget) {
        final childrenCount = _childRepo.getByBarangay(_currentBarangay).length;
        final mothersCount = _motherRepo.getAll().where((m) => m.barangay == _currentBarangay).length;

        return Column(
          children: [
            MasterlistHeader(
              selected: _category,
              childrenCount: childrenCount,
              mothersCount: mothersCount,
              onChanged: (c) => setState(() {
                _category = c;
                _query = '';
                _filter = const ChildStatusFilter();
              }),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: MasterlistTabs(
                activeCount: _category == MasterlistCategory.children
                    ? _childRepo.countActive(_currentBarangay)
                    : _motherRepo.countActive(_currentBarangay),
                inactiveCount: _category == MasterlistCategory.children
                    ? _childRepo.countInactive(_currentBarangay)
                    : _motherRepo.countInactive(_currentBarangay),
                showingActive: _showingActive,
                onChanged: (v) => setState(() => _showingActive = v),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MasterlistSearchBar(
                      hint: _category == MasterlistCategory.children ? 'Search children...' : 'Search mothers...',
                      onChanged: (v) => setState(() => _query = v),
                      onFilterTap: _category == MasterlistCategory.children ? _openFilter : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (!_showingActive) ...[
                      Row(
                        children: [
                          Icon(
                            _category == MasterlistCategory.children ? Icons.school_outlined : Icons.no_food_outlined,
                            size: 14,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _category == MasterlistCategory.children
                                ? 'Children who completed monitoring'
                                : 'Mothers who stopped breastfeeding',
                            style: AppTextStyles.body.copyWith(fontSize: 11, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                    if (_category == MasterlistCategory.children) _buildChildrenList() else _buildMothersList(),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildChildrenList() {
    final results = _childRepo.getFiltered(
      barangay: _currentBarangay,
      activeOnly: _showingActive,
      query: _query,
      filter: _showingActive ? _filter : null,
    );

    if (results.isEmpty) {
      return EmptyState(
        icon: Icons.child_care_outlined,
        message: _showingActive ? 'No children match this search or filter yet.' : 'No graduated children yet.',
      );
    }

    return Column(children: results.map((c) => ChildListTile(child: c, onTap: () => _openChildProfile(c))).toList());
  }

  Widget _buildMothersList() {
    final results = _motherRepo.getFiltered(barangay: _currentBarangay, activeOnly: _showingActive, query: _query);

    if (results.isEmpty) {
      return EmptyState(
        icon: Icons.pregnant_woman_outlined,
        message: _showingActive ? 'No mothers match this search yet.' : 'No inactive mothers yet.',
      );
    }

    return Column(children: results.map((m) => MotherListTile(mother: m, onTap: () => _openMotherProfile(m))).toList());
  }

  void _openChildProfile(Child child) {
    Navigator.push(context, appPageRoute(ChildProfileScreen(child: child)));
  }

  void _openMotherProfile(Mother mother) {
    Navigator.push(context, appPageRoute(MotherProfileScreen(mother: mother)));
  }
}