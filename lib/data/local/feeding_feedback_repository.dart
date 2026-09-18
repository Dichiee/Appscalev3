import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import 'app_data_bus.dart';
import 'hive_boxes.dart';
import '../models/feeding_feedback.dart';

class FeedingFeedbackRepository {
  Box get _box => Hive.box(HiveBoxes.feedingFeedback);

  Future<void> add(FeedingFeedback feedback) async {
    await _box.put(feedback.id, feedback.toMap());
    AppDataBus.notifyChanged();
  }

  List<FeedingFeedback> getForBarangay(String barangay) {
    final list = _box.values
        .map((e) => FeedingFeedback.fromMap(Map<String, dynamic>.from(e as Map)))
        .where((f) => f.barangay == barangay)
        .toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  static String generateId() => const Uuid().v4();
}