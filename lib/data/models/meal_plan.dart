class MealPlan {
  final String id;
  final List<String> foodItems;
  final DateTime effectiveFrom;
  final DateTime? effectiveTo; // null = active until a new plan replaces it
  final String barangay;
  final DateTime createdAt;

  const MealPlan({
    required this.id,
    required this.foodItems,
    required this.effectiveFrom,
    this.effectiveTo,
    required this.barangay,
    required this.createdAt,
  });

  String get itemsSummary => foodItems.join(', ');

  MealPlan copyWith({DateTime? effectiveTo}) => MealPlan(
        id: id,
        foodItems: foodItems,
        effectiveFrom: effectiveFrom,
        effectiveTo: effectiveTo ?? this.effectiveTo,
        barangay: barangay,
        createdAt: createdAt,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'foodItems': foodItems,
        'effectiveFrom': effectiveFrom.toIso8601String(),
        'effectiveTo': effectiveTo?.toIso8601String(),
        'barangay': barangay,
        'createdAt': createdAt.toIso8601String(),
      };

  factory MealPlan.fromMap(Map<String, dynamic> map) => MealPlan(
        id: map['id'] as String,
        foodItems: (map['foodItems'] as List?)?.map((e) => e.toString()).toList() ?? [],
        effectiveFrom: DateTime.parse(map['effectiveFrom'] as String),
        effectiveTo: map['effectiveTo'] != null ? DateTime.parse(map['effectiveTo'] as String) : null,
        barangay: map['barangay'] as String,
        createdAt: DateTime.parse(map['createdAt'] as String),
      );
}