class Measurement {
  final DateTime date;
  final double weightKg;
  final double heightCm;
  final double? muacCm;
  final bool bilateralPittingEdema;
  final String weightForAgeStatus;   // Severely Underweight / Underweight / Normal
  final String heightForAgeStatus;   // Severely Stunted / Stunted / Normal / Tall
  final String weightForLengthStatus; // SAM / MAM / Normal / Overweight / Obese

  const Measurement({
    required this.date,
    required this.weightKg,
    required this.heightCm,
    this.muacCm,
    required this.bilateralPittingEdema,
    required this.weightForAgeStatus,
    required this.heightForAgeStatus,
    required this.weightForLengthStatus,
  });

  /// Edema present overrides the wasting classification to SAM regardless
  /// of the weight-for-length number — this is a real WHO/NNC rule, not
  /// a cosmetic warning, since edema itself signals severe acute malnutrition.
  String get effectiveWastingStatus => bilateralPittingEdema ? 'SAM' : weightForLengthStatus;

  bool get isSevere =>
      weightForAgeStatus == 'Severely Underweight' ||
      heightForAgeStatus == 'Severely Stunted' ||
      effectiveWastingStatus == 'SAM';

  Map<String, dynamic> toMap() => {
        'date': date.toIso8601String(),
        'weightKg': weightKg,
        'heightCm': heightCm,
        'muacCm': muacCm,
        'bilateralPittingEdema': bilateralPittingEdema,
        'weightForAgeStatus': weightForAgeStatus,
        'heightForAgeStatus': heightForAgeStatus,
        'weightForLengthStatus': weightForLengthStatus,
      };

  factory Measurement.fromMap(Map<String, dynamic> map) => Measurement(
        date: DateTime.parse(map['date'] as String),
        weightKg: (map['weightKg'] as num).toDouble(),
        heightCm: (map['heightCm'] as num).toDouble(),
        muacCm: (map['muacCm'] as num?)?.toDouble(),
        bilateralPittingEdema: map['bilateralPittingEdema'] as bool? ?? false,
        weightForAgeStatus: map['weightForAgeStatus'] as String,
        heightForAgeStatus: map['heightForAgeStatus'] as String,
        weightForLengthStatus: map['weightForLengthStatus'] as String,
      );
}