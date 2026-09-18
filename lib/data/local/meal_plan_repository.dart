import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import 'app_data_bus.dart';
import 'hive_boxes.dart';
import '../models/meal_plan.dart';

class MealPlanRepository {
  Box get _box => Hive.box(HiveBoxes.mealPlans);

  List<MealPlan> getAllForBarangay(String barangay) {
    final list = _box.values
        .map((e) => MealPlan.fromMap(Map<String, dynamic>.from(e as Map)))
        .where((p) => p.barangay == barangay)
        .toList();
    list.sort((a, b) => b.effectiveFrom.compareTo(a.effectiveFrom));
    return list;
  }

  /// Adding a new plan automatically closes whichever open-ended plan
  /// was active before it — a barangay only ever has one live menu at
  /// a time, so this keeps that true without the BNS managing it by hand.
  Future<void> addAndCloseOthers(MealPlan plan) async {
    for (final existing in getAllForBarangay(plan.barangay)) {
      if (existing.effectiveTo == null && existing.effectiveFrom.isBefore(plan.effectiveFrom)) {
        final closed = existing.copyWith(effectiveTo: plan.effectiveFrom.subtract(const Duration(days: 1)));
        await _box.put(existing.id, closed.toMap());
      }
    }
    await _box.put(plan.id, plan.toMap());
    AppDataBus.notifyChanged();
  }

  MealPlan? getActiveForDate(String barangay, DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    final matches = getAllForBarangay(barangay).where((p) {
      final from = DateTime(p.effectiveFrom.year, p.effectiveFrom.month, p.effectiveFrom.day);
      final to = p.effectiveTo == null ? null : DateTime(p.effectiveTo!.year, p.effectiveTo!.month, p.effectiveTo!.day);
      return !d.isBefore(from) && (to == null || !d.isAfter(to));
    }).toList();
    if (matches.isNotEmpty) return matches.first;
    final all = getAllForBarangay(barangay);
    return all.isEmpty ? null : all.first;
  }

  Future<void> seedInitialIfEmpty(String barangay) async {
    if (getAllForBarangay(barangay).isNotEmpty) return;
    final defaultPlan = MealPlan(
      id: generateId(),
      foodItems: [
        'Mon: Champorado with Milk & Hard Boiled Egg',
        'Tue: Ginataang Monggo with Malunggay & Dilis',
        'Wed: Chicken Arroz Caldo with Carrots & Ginger',
        'Thu: Pork Picadillo with Sayote, Carrots & Rice',
        'Fri: Sotanghon Guisado with Vegetables & Boiled Egg',
      ],
      effectiveFrom: DateTime.now().subtract(const Duration(days: 14)),
      effectiveTo: null,
      barangay: barangay,
      createdAt: DateTime.now().subtract(const Duration(days: 14)),
    );
    await _box.put(defaultPlan.id, defaultPlan.toMap());
    AppDataBus.notifyChanged();
  }

  static String generateId() => const Uuid().v4();
}