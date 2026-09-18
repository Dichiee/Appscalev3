import 'sd_thresholds.dart';

/// ⚠️ STARTER DATASET — sampled at key ages, not every month.
/// Source: NNC "Child Growth Standards — Weight (kg) for Age" tables you
/// provided, boys and girls, 0–71 months. Threshold values below were
/// transcribed directly from that document for the ages listed.
///
/// BEFORE THIS SHIPS: fill in every remaining month (0–71) from the same
/// source, and have a second person cross-check every entered number
/// against the printed table. This classifies malnutrition — a single
/// mistyped digit here silently misclassifies a real child. Don't treat
/// this as done just because the app runs; treat the *data* as its own
/// verification task, separate from the code being correct.
const weightForAgeBoys = <int, SdThresholds>{
  0: SdThresholds(negThreeSD: 2.1, negTwoSD: 2.5, posTwoSD: 4.4),
  3: SdThresholds(negThreeSD: 4.4, negTwoSD: 5.0, posTwoSD: 8.0),
  6: SdThresholds(negThreeSD: 5.7, negTwoSD: 6.4, posTwoSD: 9.8),
  9: SdThresholds(negThreeSD: 6.4, negTwoSD: 7.1, posTwoSD: 11.0),
  12: SdThresholds(negThreeSD: 6.9, negTwoSD: 7.7, posTwoSD: 12.0),
  18: SdThresholds(negThreeSD: 7.7, negTwoSD: 8.6, posTwoSD: 13.7),
  24: SdThresholds(negThreeSD: 8.6, negTwoSD: 9.7, posTwoSD: 15.3),
  36: SdThresholds(negThreeSD: 9.9, negTwoSD: 11.2, posTwoSD: 18.1),
  48: SdThresholds(negThreeSD: 11.2, negTwoSD: 12.6, posTwoSD: 20.7),
  60: SdThresholds(negThreeSD: 12.4, negTwoSD: 14.0, posTwoSD: 23.2),
  71: SdThresholds(negThreeSD: 13.9, negTwoSD: 15.6, posTwoSD: 26.8),
};

const weightForAgeGirls = <int, SdThresholds>{
  0: SdThresholds(negThreeSD: 2.0, negTwoSD: 2.4, posTwoSD: 4.2),
  3: SdThresholds(negThreeSD: 4.0, negTwoSD: 4.5, posTwoSD: 7.5),
  6: SdThresholds(negThreeSD: 5.1, negTwoSD: 5.7, posTwoSD: 9.3),
  9: SdThresholds(negThreeSD: 5.8, negTwoSD: 6.5, posTwoSD: 10.5),
  12: SdThresholds(negThreeSD: 6.3, negTwoSD: 7.0, posTwoSD: 11.5),
  18: SdThresholds(negThreeSD: 7.0, negTwoSD: 7.9, posTwoSD: 12.9),
  24: SdThresholds(negThreeSD: 8.1, negTwoSD: 9.0, posTwoSD: 14.8),
  36: SdThresholds(negThreeSD: 9.5, negTwoSD: 10.6, posTwoSD: 17.9),
  48: SdThresholds(negThreeSD: 10.9, negTwoSD: 12.2, posTwoSD: 21.5),
  60: SdThresholds(negThreeSD: 12.1, negTwoSD: 13.6, posTwoSD: 24.7),
  71: SdThresholds(negThreeSD: 13.4, negTwoSD: 15.1, posTwoSD: 27.6),
};