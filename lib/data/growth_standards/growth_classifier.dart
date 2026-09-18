import 'height_for_age_data.dart';
import 'sd_thresholds.dart';
import 'weight_for_age_data.dart';
import 'weight_for_length_data.dart';

/// Applies the WHO/NNC classification rules exactly as printed on the
/// source tables' own "Instructions for Use": find which column a value
/// falls under, classify accordingly. No interpolation between SD lines —
/// that's not how the source tables work; they're direct lookup tables.
class GrowthClassifier {
  GrowthClassifier._();

  static bool _isMale(String gender) {
    final g = gender.trim().toLowerCase();
    return g == 'male' || g == 'boy' || g == 'm';
  }

  static String classifyWeightForAge({required double weightKg, required int ageMonths, required String gender}) {
    final table = _isMale(gender) ? weightForAgeBoys : weightForAgeGirls;
    final t = _nearest(table, ageMonths);
    if (weightKg < t.negThreeSD) return 'Severely Underweight';
    if (weightKg < t.negTwoSD) return 'Underweight';
    if (weightKg > t.posTwoSD) return 'Overweight';
    return 'Normal';
  }

  static String classifyHeightForAge({required double heightCm, required int ageMonths, required String gender}) {
    final table = _isMale(gender) ? heightForAgeBoys : heightForAgeGirls;
    final t = _nearest(table, ageMonths);
    if (heightCm < t.negThreeSD) return 'Severely Stunted';
    if (heightCm < t.negTwoSD) return 'Stunted';
    if (heightCm > t.posTwoSD) return 'Tall';
    return 'Normal';
  }

  static String classifyWeightForLength({required double weightKg, required double heightCm, required String gender}) {
    final table = _isMale(gender) ? weightForLengthBoys : weightForLengthGirls;
    final roundedLength = (heightCm * 2).round() / 2; // nearest 0.5cm, per the source table's own instructions
    final t = _nearestByLength(table, roundedLength);
    if (weightKg < t.negThreeSD) return 'SAM';
    if (weightKg < t.negTwoSD) return 'MAM';
    if (t.posThreeSD != null && weightKg > t.posThreeSD!) return 'Obese';
    if (weightKg > t.posTwoSD) return 'Overweight';
    return 'Normal';
  }

  static SdThresholds _nearest(Map<int, SdThresholds> table, int age) {
    if (table.containsKey(age)) return table[age]!;
    final keys = table.keys.toList()..sort();
    return table[keys.reduce((a, b) => (a - age).abs() < (b - age).abs() ? a : b)]!;
  }

  static SdThresholds _nearestByLength(Map<double, SdThresholds> table, double length) {
    if (table.containsKey(length)) return table[length]!;
    final keys = table.keys.toList()..sort();
    return table[keys.reduce((a, b) => (a - length).abs() < (b - length).abs() ? a : b)]!;
  }
}