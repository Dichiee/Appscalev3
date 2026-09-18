import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem(this.icon, this.activeIcon, this.label);
}

/// Home / List / Add / Program / Reports, all five living in the same
/// bar — Add is not a separate floating layer, it's the middle slot,
/// styled distinctly but positioned exactly like every other item.
class AppBottomNav extends StatelessWidget {
  final int currentIndex; // 0..3, mapped across Home/List/Program/Reports
  final ValueChanged<int> onTabSelected;
  final VoidCallback onAddPressed;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    required this.onAddPressed,
  });

  static const _items = [
    _NavItem(Icons.home_outlined, Icons.home_rounded, 'Home'),
    _NavItem(Icons.list_alt_outlined, Icons.list_alt_rounded, 'List'),
    _NavItem(Icons.medical_services_outlined, Icons.medical_services_rounded, 'Program'),
    _NavItem(Icons.bar_chart_outlined, Icons.bar_chart_rounded, 'Reports'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Container(
        height: 68,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: Row(
          children: [
            _buildTab(0),
            _buildTab(1),
            _buildAddSlot(),
            _buildTab(2),
            _buildTab(3),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(int bodyIndex) {
    final item = _items[bodyIndex];
    final isActive = bodyIndex == currentIndex;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTabSelected(bodyIndex),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              width: 40,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isActive ? AppColors.lightGreenBg : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(isActive ? item.activeIcon : item.icon, color: isActive ? AppColors.darkGreen : AppColors.textMuted, size: 21),
            ),
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 220),
              style: TextStyle(color: isActive ? AppColors.darkGreen : AppColors.textMuted, fontSize: 10.5, fontWeight: isActive ? FontWeight.w700 : FontWeight.w500),
              child: Text(item.label, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddSlot() {
    return Expanded(
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onAddPressed,
            customBorder: const CircleBorder(),
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primaryGreen, AppColors.darkGreen],
                ),
                boxShadow: [BoxShadow(color: AppColors.darkGreen.withValues(alpha: 0.35), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: const Icon(Icons.add_rounded, color: Colors.white, size: 26),
            ),
          ),
        ),
      ),
    );
  }
}