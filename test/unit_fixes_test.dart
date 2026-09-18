import 'package:flutter_test/flutter_test.dart';
import 'package:appscalev3/data/growth_standards/growth_classifier.dart';
import 'package:appscalev3/data/models/referral.dart';
import 'package:appscalev3/data/models/child.dart';
import 'package:appscalev3/data/models/guardian.dart';
import 'package:appscalev3/data/models/app_notification.dart';
import 'package:appscalev3/data/models/vitamin_a_record.dart';
import 'package:appscalev3/data/models/deworming_record.dart';
import 'package:appscalev3/data/models/program_schedule.dart';
import 'package:appscalev3/data/local/vitamin_a_repository.dart';
import 'package:appscalev3/data/local/deworming_repository.dart';

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

  group('Vitamin A Program DOH Guidelines Tests', () {
    test('DOH Vitamin A dosage recommendation by age', () {
      expect(VitaminARepository.determineRecommendedDosage(4), equals('Not Eligible (<6 mos)'));
      expect(VitaminARepository.determineRecommendedDosage(6), equals('100,000 IU (Blue)'));
      expect(VitaminARepository.determineRecommendedDosage(11), equals('100,000 IU (Blue)'));
      expect(VitaminARepository.determineRecommendedDosage(12), equals('200,000 IU (Red)'));
      expect(VitaminARepository.determineRecommendedDosage(59), equals('200,000 IU (Red)'));
      expect(VitaminARepository.determineRecommendedDosage(60), equals('Exceeds Target Age (>59 mos)'));
    });

    test('VitaminARecord serialization and deserialization', () {
      final now = DateTime(2026, 3, 18);
      final record = VitaminARecord(
        id: 'vit-101',
        childId: 'c-1',
        childName: 'Baby Juan',
        barangay: 'Tiguion',
        ageInMonths: 9,
        dateGiven: now,
        dosage: '100,000 IU (Blue)',
        doseType: 'Routine (6-11 mos)',
        administeredBy: 'BNS Maria',
        remarks: 'No reaction',
        nextDueDate: now.add(const Duration(days: 180)),
        createdAt: now,
      );

      final map = record.toMap();
      final restored = VitaminARecord.fromMap(map);

      expect(restored.id, equals('vit-101'));
      expect(restored.childName, equals('Baby Juan'));
      expect(restored.dosage, equals('100,000 IU (Blue)'));
      expect(restored.administeredBy, equals('BNS Maria'));
      expect(restored.nextDueDate, isNotNull);
    });
  });

  group('Deworming Program DOH Guidelines Tests', () {
    test('DOH Deworming eligibility by age', () {
      expect(DewormingRepository.isEligible(6), isFalse); // under 12 mos contraindicated
      expect(DewormingRepository.isEligible(11), isFalse);
      expect(DewormingRepository.isEligible(12), isTrue); // 12-59 mos target
      expect(DewormingRepository.isEligible(36), isTrue);
      expect(DewormingRepository.isEligible(59), isTrue);
      expect(DewormingRepository.isEligible(60), isFalse);
    });

    test('DewormingRecord serialization and deserialization', () {
      final now = DateTime(2026, 3, 18);
      final record = DewormingRecord(
        id: 'dew-101',
        childId: 'c-2',
        childName: 'Baby Pedro',
        barangay: 'Tiguion',
        ageInMonths: 24,
        dateGiven: now,
        drugName: 'Albendazole 400mg',
        round: '1st Round (Jan - Jun)',
        adverseEvents: 'None',
        administeredBy: 'BNS Maria',
        remarks: 'Taken with water',
        nextDueDate: now.add(const Duration(days: 180)),
        createdAt: now,
      );

      final map = record.toMap();
      final restored = DewormingRecord.fromMap(map);

      expect(restored.id, equals('dew-101'));
      expect(restored.childName, equals('Baby Pedro'));
      expect(restored.drugName, equals('Albendazole 400mg'));
      expect(restored.round, equals('1st Round (Jan - Jun)'));
      expect(restored.adverseEvents, equals('None'));
    });
  });

  group('ProgramSchedule Model Tests', () {
    test('ProgramSchedule serialization and deserialization', () {
      final now = DateTime(2026, 3, 25);
      final sched = ProgramSchedule(
        id: 'sch-101',
        title: 'Community Deworming Day',
        programType: 'Deworming',
        date: now,
        startTime: '08:00 AM',
        endTime: '12:00 PM',
        location: 'Barangay Health Center',
        targetGroup: 'Children 12-59 mos',
        notes: 'Bring child immunization card',
        barangay: 'Tiguion',
        createdBy: 'RHU Web Admin',
        createdAt: DateTime(2026, 3, 18),
      );

      final map = sched.toMap();
      final restored = ProgramSchedule.fromMap(map);

      expect(restored.id, equals('sch-101'));
      expect(restored.title, equals('Community Deworming Day'));
      expect(restored.programType, equals('Deworming'));
      expect(restored.createdBy, equals('RHU Web Admin'));
    });
  });
}
