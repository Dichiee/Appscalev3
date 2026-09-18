/// SD cutoff points from a single row of an NNC/WHO growth standards
/// table. posThreeSD is only used for weight-for-length/height (wasting);
/// weight-for-age and height-for-age tables don't define it.
class SdThresholds {
  final double negThreeSD;
  final double negTwoSD;
  final double posTwoSD;
  final double? posThreeSD;

  const SdThresholds({
    required this.negThreeSD,
    required this.negTwoSD,
    required this.posTwoSD,
    this.posThreeSD,
  });
}