import 'child_repository.dart';
import 'mother_repository.dart';
import 'referral_repository.dart';
import '../models/child.dart';
import '../models/mother.dart';

/// "Needs referral" is never stored as a field on Child or Mother —
/// it's computed live from their current status plus whether an open
/// referral already exists. This means clicking "Later" on the alert
/// can never leave a stale, forgotten flag: the beneficiary simply
/// keeps showing up here for as long as they're actually severe/at-risk
/// and nobody has opened a case for them yet.
class ReferralNeedsService {
  final _childRepo = ChildRepository();
  final _motherRepo = MotherRepository();
  final _referralRepo = ReferralRepository();

  bool _isChildSevere(Child c) =>
      c.isActive &&
      (c.nutritionStatus == 'Severely Underweight' || c.stuntingStatus == 'Severely Stunted' || c.wastingStatus == 'SAM');

  bool _hasOpenReferral(String beneficiaryId) =>
      _referralRepo.getForBeneficiary(beneficiaryId).any((r) => r.status == 'Pending' || r.status == 'In Progress');

  List<Child> getChildrenNeedingReferral(String barangay) =>
      _childRepo.getByBarangay(barangay).where((c) => _isChildSevere(c) && !_hasOpenReferral(c.id)).toList();

  List<Mother> getMothersNeedingReferral(String barangay) => _motherRepo
      .getAll()
      .where((m) => m.barangay == barangay && m.isActive && m.riskStatus == 'At-risk' && !_hasOpenReferral(m.id))
      .toList();
}