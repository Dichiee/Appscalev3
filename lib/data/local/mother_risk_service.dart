import 'mother_repository.dart';
import 'mother_visit_repository.dart';

/// The single place that ever writes riskStatus or breastfeedingPractice
/// onto a Mother record. Call recomputeAndSave right after any visit is
/// logged — no other screen should set these fields directly, so there
/// is exactly one source of truth for both, always traceable to a
/// specific dated visit.
class MotherRiskService {
  final _motherRepo = MotherRepository();
  final _visitRepo = MotherVisitRepository();

  Future<void> recomputeAndSave(String motherId) async {
    final mother = _motherRepo.getById(motherId);
    if (mother == null) return;

    final visits = _visitRepo.getForMother(motherId);
    if (visits.isEmpty) return; // no visits yet — leave defaults untouched

    final latest = visits.first;

    // A missed visit is not an observation — it doesn't change risk status
    // or breastfeeding practice, it just sits in the log as a missed entry.
    if (!latest.present) return;

    final newRisk = latest.observation == 'Signs of concern' ? 'At-risk' : 'Normal';
    final newBreastfeeding = latest.breastfeedingPractice ?? mother.breastfeedingPractice;

    await _motherRepo.update(mother.copyWith(riskStatus: newRisk, breastfeedingPractice: newBreastfeeding));
  }
}