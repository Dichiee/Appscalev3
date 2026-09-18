import 'sd_thresholds.dart';

/// ⚠️ STARTER DATASET — same warning as weight_for_age_data.dart applies.
/// posTwoSD here doubles as the "Tall" lower bound (table has no separate
/// upper number — Tall is simply "above +2SD").
const heightForAgeBoys = <int, SdThresholds>{
  0: SdThresholds(negThreeSD: 44.2, negTwoSD: 46.1, posTwoSD: 53.7),
  3: SdThresholds(negThreeSD: 55.3, negTwoSD: 57.3, posTwoSD: 65.5),
  6: SdThresholds(negThreeSD: 61.2, negTwoSD: 63.3, posTwoSD: 71.9),
  9: SdThresholds(negThreeSD: 64.0, negTwoSD: 66.2, posTwoSD: 75.0),
  12: SdThresholds(negThreeSD: 67.6, negTwoSD: 69.8, posTwoSD: 79.2),
  18: SdThresholds(negThreeSD: 73.3, negTwoSD: 75.9, posTwoSD: 86.5),
  24: SdThresholds(negThreeSD: 78.0, negTwoSD: 80.9, posTwoSD: 93.2),
  36: SdThresholds(negThreeSD: 84.4, negTwoSD: 88.0, posTwoSD: 102.8),
  48: SdThresholds(negThreeSD: 90.7, negTwoSD: 94.8, posTwoSD: 111.7),
  60: SdThresholds(negThreeSD: 96.1, negTwoSD: 100.6, posTwoSD: 118.7),
  71: SdThresholds(negThreeSD: 100.8, negTwoSD: 105.6, posTwoSD: 125.2),
};

const heightForAgeGirls = <int, SdThresholds>{
  0: SdThresholds(negThreeSD: 43.6, negTwoSD: 45.4, posTwoSD: 52.9),
  3: SdThresholds(negThreeSD: 53.5, negTwoSD: 55.6, posTwoSD: 64.1),
  6: SdThresholds(negThreeSD: 58.9, negTwoSD: 61.2, posTwoSD: 70.4),
  9: SdThresholds(negThreeSD: 62.9, negTwoSD: 65.3, posTwoSD: 73.6),
  12: SdThresholds(negThreeSD: 65.2, negTwoSD: 67.7, posTwoSD: 77.9),
  18: SdThresholds(negThreeSD: 71.1, negTwoSD: 73.9, posTwoSD: 86.6),
  24: SdThresholds(negThreeSD: 76.0, negTwoSD: 79.3, posTwoSD: 92.3),
  36: SdThresholds(negThreeSD: 83.6, negTwoSD: 87.4, posTwoSD: 102.8),
  48: SdThresholds(negThreeSD: 89.8, negTwoSD: 94.1, posTwoSD: 111.4),
  60: SdThresholds(negThreeSD: 95.2, negTwoSD: 99.8, posTwoSD: 118.9),
  71: SdThresholds(negThreeSD: 99.4, negTwoSD: 104.4, posTwoSD: 124.9),
};