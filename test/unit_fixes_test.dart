import 'package:flutter_test/flutter_test.dart';
import 'package:appscalev3/data/growth_standards/growth_classifier.dart';
import 'package:appscalev3/data/models/referral.dart';
import 'package:appscalev3/data/models/child.dart';
import 'package:appscalev3/data/models/guardian.dart';

void main() {
  group('Item 4: GrowthClassifier Tests', () {
    test('Classifies Overweight when weightKg > posTwoSD', () {
      // For boy at 24 months, standard: med ~12.2, posTwoSD ~15.3, negTwoSD ~9.7, negThreeSD ~8.6
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

  group('Item 6: Referral Status & Notes Tests', () {
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

  group('Item 1: Child Model Integrity Tests', () {
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
}
