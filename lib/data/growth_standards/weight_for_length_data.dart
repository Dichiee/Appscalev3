import 'sd_thresholds.dart';

/// ⚠️ STARTER DATASET, keyed by length/height rounded to nearest 0.5cm,
/// per the source table's own instructions. Same completeness warning
/// applies — sampled every 5cm here, full table needs every 0.5cm row.
final weightForLengthBoys = <double, SdThresholds>{
  45.0: SdThresholds(negThreeSD: 1.9, negTwoSD: 2.1, posTwoSD: 3.1, posThreeSD: 3.3),
  50.0: SdThresholds(negThreeSD: 2.6, negTwoSD: 2.7, posTwoSD: 4.1, posThreeSD: 4.5),
  55.0: SdThresholds(negThreeSD: 3.5, negTwoSD: 3.7, posTwoSD: 5.6, posThreeSD: 6.2),
  60.0: SdThresholds(negThreeSD: 4.5, negTwoSD: 4.8, posTwoSD: 7.2, posThreeSD: 8.0),
  65.0: SdThresholds(negThreeSD: 5.5, negTwoSD: 5.9, posTwoSD: 8.8, posThreeSD: 9.7),
  70.0: SdThresholds(negThreeSD: 6.5, negTwoSD: 6.9, posTwoSD: 10.2, posThreeSD: 11.4),
  75.0: SdThresholds(negThreeSD: 7.1, negTwoSD: 7.6, posTwoSD: 11.1, posThreeSD: 12.4),
  80.0: SdThresholds(negThreeSD: 7.9, negTwoSD: 8.4, posTwoSD: 12.4, posThreeSD: 13.7),
  85.0: SdThresholds(negThreeSD: 8.9, negTwoSD: 9.6, posTwoSD: 14.1, posThreeSD: 15.6),
  90.0: SdThresholds(negThreeSD: 9.7, negTwoSD: 10.7, posTwoSD: 15.0, posThreeSD: 16.5),
  95.0: SdThresholds(negThreeSD: 10.6, negTwoSD: 11.6, posTwoSD: 16.1, posThreeSD: 17.9),
  100.0: SdThresholds(negThreeSD: 11.5, negTwoSD: 12.6, posTwoSD: 17.7, posThreeSD: 19.9),
  105.0: SdThresholds(negThreeSD: 12.4, negTwoSD: 13.5, posTwoSD: 19.1, posThreeSD: 21.6),
  110.0: SdThresholds(negThreeSD: 13.9, negTwoSD: 15.1, posTwoSD: 21.4, posThreeSD: 24.2),
};

final weightForLengthGirls = <double, SdThresholds>{
  45.0: SdThresholds(negThreeSD: 1.8, negTwoSD: 2.0, posTwoSD: 3.0, posThreeSD: 3.4),
  50.0: SdThresholds(negThreeSD: 2.5, negTwoSD: 2.7, posTwoSD: 4.0, posThreeSD: 4.6),
  55.0: SdThresholds(negThreeSD: 3.4, negTwoSD: 3.6, posTwoSD: 5.7, posThreeSD: 6.4),
  60.0: SdThresholds(negThreeSD: 4.5, negTwoSD: 4.8, posTwoSD: 7.3, posThreeSD: 8.1),
  65.0: SdThresholds(negThreeSD: 5.6, negTwoSD: 6.0, posTwoSD: 9.0, posThreeSD: 9.9),
  70.0: SdThresholds(negThreeSD: 6.6, negTwoSD: 7.1, posTwoSD: 10.6, posThreeSD: 11.7),
  75.0: SdThresholds(negThreeSD: 7.1, negTwoSD: 7.7, posTwoSD: 11.4, posThreeSD: 12.6),
  80.0: SdThresholds(negThreeSD: 8.2, negTwoSD: 8.8, posTwoSD: 12.9, posThreeSD: 14.2),
  85.0: SdThresholds(negThreeSD: 9.3, negTwoSD: 10.0, posTwoSD: 14.5, posThreeSD: 16.0),
  90.0: SdThresholds(negThreeSD: 10.1, negTwoSD: 10.9, posTwoSD: 15.9, posThreeSD: 17.6),
  95.0: SdThresholds(negThreeSD: 10.8, negTwoSD: 11.8, posTwoSD: 17.1, posThreeSD: 19.0),
  100.0: SdThresholds(negThreeSD: 11.9, negTwoSD: 13.0, posTwoSD: 18.1, posThreeSD: 20.1),
  105.0: SdThresholds(negThreeSD: 12.9, negTwoSD: 14.0, posTwoSD: 20.0, posThreeSD: 22.3),
  110.0: SdThresholds(negThreeSD: 14.1, negTwoSD: 15.4, posTwoSD: 21.9, posThreeSD: 24.5),
};