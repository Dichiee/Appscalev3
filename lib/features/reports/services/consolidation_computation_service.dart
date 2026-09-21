import '../../../data/local/child_repository.dart';
import '../../../data/models/child.dart';

/// Computes the "New" (current, live) counts for each consolidation
/// report type, straight from active Child records. There is no fake
/// historical calculation here — "Old" comes separately from the last
/// saved ReportSnapshot, never invented.
class ConsolidationComputationService {
  final _childRepo = ChildRepository();

  Map<String, int> compute(String reportTypeId, String barangay) {
    switch (reportTypeId) {
      case 'consolidation_0_23':
        return _byWeightStatus(_children(barangay, maxAgeExclusive: 24));
      case 'consolidation_24_59':
        return _byWeightStatusWithGender(_children(barangay, minAge: 24, maxAgeExclusive: 60));
      case 'uw_suw':
        return _uwSuwOnly(_children(barangay));
      case 'stunted_sst':
        return _byHeightStatus(_children(barangay));
      default:
        return {};
    }
  }

  List<Child> _children(String barangay, {int? minAge, int? maxAgeExclusive}) {
    return _childRepo.getByBarangay(barangay).where((c) {
      if (!c.isActive) return false;
      if (minAge != null && c.ageInMonths < minAge) return false;
      if (maxAgeExclusive != null && c.ageInMonths >= maxAgeExclusive) return false;
      return true;
    }).toList();
  }

  Map<String, int> _byWeightStatus(List<Child> children) => {
        'Normal': children.where((c) => c.nutritionStatus == 'Normal').length,
        'Underweight': children.where((c) => c.nutritionStatus == 'Underweight').length,
        'Severely Underweight': children.where((c) => c.nutritionStatus == 'Severely Underweight').length,
        'Not weighed': children.where((c) => c.nutritionStatus == 'Not weighed').length,
        'Total': children.length,
      };

  Map<String, int> _byWeightStatusWithGender(List<Child> children) {
    final boys = children.where((c) => c.gender == 'Male').toList();
    final girls = children.where((c) => c.gender == 'Female').toList();
    return {
      'Normal (Boys)': boys.where((c) => c.nutritionStatus == 'Normal').length,
      'Normal (Girls)': girls.where((c) => c.nutritionStatus == 'Normal').length,
      'Underweight (Boys)': boys.where((c) => c.nutritionStatus == 'Underweight').length,
      'Underweight (Girls)': girls.where((c) => c.nutritionStatus == 'Underweight').length,
      'Overweight (Boys)': boys.where((c) => c.wastingStatus == 'Overweight').length,
      'Overweight (Girls)': girls.where((c) => c.wastingStatus == 'Overweight').length,
      'Total Boys': boys.length,
      'Total Girls': girls.length,
      'Total': children.length,
    };
  }

  Map<String, int> _uwSuwOnly(List<Child> children) => {
        'Underweight': children.where((c) => c.nutritionStatus == 'Underweight').length,
        'Severely Underweight': children.where((c) => c.nutritionStatus == 'Severely Underweight').length,
        'Total flagged': children.where((c) => c.nutritionStatus == 'Underweight' || c.nutritionStatus == 'Severely Underweight').length,
      };

  Map<String, int> _byHeightStatus(List<Child> children) => {
        'Normal': children.where((c) => c.stuntingStatus == 'Normal').length,
        'Stunted': children.where((c) => c.stuntingStatus == 'Stunted').length,
        'Severely Stunted': children.where((c) => c.stuntingStatus == 'Severely Stunted').length,
        'Tall': children.where((c) => c.stuntingStatus == 'Tall').length,
        'Total': children.length,
      };
}