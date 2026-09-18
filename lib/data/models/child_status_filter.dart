class ChildStatusFilter {
  final String weightForAge;
  final String heightForAge;
  final String wasting;
  final bool onlyNotWeighed;

  const ChildStatusFilter({
    this.weightForAge = 'All',
    this.heightForAge = 'All',
    this.wasting = 'All',
    this.onlyNotWeighed = false,
  });

  bool get isActive => weightForAge != 'All' || heightForAge != 'All' || wasting != 'All' || onlyNotWeighed;

  ChildStatusFilter copyWith({String? weightForAge, String? heightForAge, String? wasting, bool? onlyNotWeighed}) =>
      ChildStatusFilter(
        weightForAge: weightForAge ?? this.weightForAge,
        heightForAge: heightForAge ?? this.heightForAge,
        wasting: wasting ?? this.wasting,
        onlyNotWeighed: onlyNotWeighed ?? this.onlyNotWeighed,
      );
}