import 'package:flutter_test/flutter_test.dart';
import 'package:appscalev3/data/growth_standards/growth_classifier.dart';
import 'package:appscalev3/data/models/referral.dart';
import 'package:appscalev3/data/models/child.dart';
import 'package:appscalev3/data/models/guardian.dart';
import 'package:appscalev3/data/models/app_notification.dart';

void main() {
  group('Item 4: GrowthClassifier Tests', () {
    test('Classifies Overweight when weightKg > posTwoSD', () {
      final status = GrowthClassifier.classifyWeightForAge(
        ageMonths: 24,
        gender: 'Boy',
        weightKg: 16.5,
      );
      expect(status, equals('Overweight'));
    });

    test('Classifies Normal when weightKg is between negTwoSD and posTwoSD', () {
      final status = GrowthClassifier.classifyWeightForAge(
        ageMonths: 24,
        gender: 'Boy',
        weightKg: 12.0,
      );
      expect(status, equals('Normal'));
    });

    test('Classifies Underweight when weightKg < negTwoSD and >= negThreeSD', () {
      final status = GrowthClassifier.classifyWeightForAge(
        ageMonths: 24,
        gender: 'Boy',
        weightKg: 9.2,
      );
      expect(status, equals('Underweight'));
    });

    test('Classifies Severely Underweight when weightKg < negThreeSD', () {
      final status = GrowthClassifier.classifyWeightForAge(
        ageMonths: 24,
        gender: 'Boy',
        weightKg: 8.0,
      );
      expect(status, equals('Severely Underweight'));
    });
  });

  group('Referral Model Tests', () {
    test('Referral copyWith correctly updates status and notes', () {
      final ref = Referral(
        id: 'ref-1',
        beneficiaryType: 'child',
        beneficiaryId: 'c1',
        beneficiaryName: 'Test Baby',
        barangay: 'San Antonio',
        reason: 'Severe Acute Malnutrition (SAM)',
        facility: 'RHU Main',
        notes: '',
        status: 'Pending',
        createdAt: DateTime(2026, 3, 1),
      );

      final updated = ref.copyWith(
        status: 'In Progress',
        notes: 'Referred to RHU nutritionist for RUTF therapy.',
      );

      expect(updated.status, equals('In Progress'));
      expect(updated.notes, equals('Referred to RHU nutritionist for RUTF therapy.'));
      expect(updated.id, equals('ref-1'));
      expect(updated.facility, equals('RHU Main'));
    });
  });

  group('Child Model Integrity Tests', () {
    test('Child copyWith preserves wastingStatus and other fields when updated', () {
      final child = Child(
        id: 'c-test',
        sequenceNo: '001',
        fullName: 'Baby Smith',
        birthDate: DateTime(2025, 1, 1),
        gender: 'Girl',
        address: 'Purok 1',
        barangay: 'San Antonio',
        belongsToIpGroup: false,
        disability: 'None',
        guardian: const Guardian(
          fullName: 'Mary Smith',
          relationship: 'Mother',
          contactNo: '09999999999',
        ),
        createdAt: DateTime(2025, 1, 1),
        nutritionStatus: 'Normal',
        wastingStatus: 'MAM',
        stuntingStatus: 'Normal',
      );

      final updated = child.copyWith(nutritionStatus: 'Underweight');
      expect(updated.wastingStatus, equals('MAM'));
      expect(updated.nutritionStatus, equals('Underweight'));
      expect(updated.fullName, equals('Baby Smith'));
      expect(updated.guardian.fullName, equals('Mary Smith'));
    });
  });

  group('Referral & Notification Web Architecture Tests', () {
    test('AppNotification model serialization and deserialization', () {
      final notif = AppNotification(
        id: 'notif-123',
        title: 'Referral Resolved by RHU',
        message: 'RHU completed referral for Baby Juan. Outcome: RUTF supply provided.',
        type: 'referral_completed',
        referralId: 'ref-001',
        timestamp: DateTime(2026, 3, 18, 14, 0),
        isRead: false,
      );

      final map = notif.toMap();
      final restored = AppNotification.fromMap(map);

      expect(restored.id, equals('notif-123'));
      expect(restored.title, equals('Referral Resolved by RHU'));
      expect(restored.type, equals('referral_completed'));
      expect(restored.referralId, equals('ref-001'));
      expect(restored.isRead, isFalse);

      final markedRead = restored.copyWith(isRead: true);
      expect(markedRead.isRead, isTrue);
    });
  });
}
