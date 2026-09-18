import '../models/child.dart';
import '../models/guardian.dart';
import '../models/mother.dart';
import 'child_repository.dart';
import 'mother_repository.dart';

/// Single place that keeps a child's guardian link and a mother's linked
/// children list in sync. Call this any time a link is made or changed —
/// from Add Child, Add Mother, or their edit-mode counterparts — so the
/// two records never drift out of agreement with each other.
class BeneficiaryLinkService {
  final _childRepo = ChildRepository();
  final _motherRepo = MotherRepository();

  Future<void> linkChildToMother({required Child child, required Mother mother}) async {
    if (child.guardian.linkedMotherId != mother.id) {
      final updatedChild = child.copyWith(
        guardian: Guardian(
          fullName: child.guardian.fullName,
          relationship: child.guardian.relationship,
          contactNo: child.guardian.contactNo,
          linkedMotherId: mother.id,
        ),
      );
      await _childRepo.update(updatedChild);
    }

    if (!mother.linkedChildIds.contains(child.id)) {
      final updatedMother = mother.copyWith(linkedChildIds: [...mother.linkedChildIds, child.id]);
      await _motherRepo.update(updatedMother);
    }
  }

  Future<void> unlinkChildFromMother({required Child child, required Mother mother}) async {
    final updatedChild = child.copyWith(
      guardian: Guardian(
        fullName: child.guardian.fullName,
        relationship: child.guardian.relationship,
        contactNo: child.guardian.contactNo,
        linkedMotherId: null,
      ),
    );
    await _childRepo.update(updatedChild);

    final updatedMother = mother.copyWith(
      linkedChildIds: mother.linkedChildIds.where((id) => id != child.id).toList(),
    );
    await _motherRepo.update(updatedMother);
  }
}