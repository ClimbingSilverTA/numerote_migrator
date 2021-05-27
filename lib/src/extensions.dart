import 'package:numerote_core/numerote_core.dart';

extension ResultsListExt on List<Map<String, Object?>> {
  Map<String, Label> toLabelIdMap() {
    final Map<String, Label> labels = {};
    for (final map in this) {
      final id = map['id'] as String?;
      final name = map['name'] as String?;
      final lastUpdated = map['last_updated'] as int?;
      if (id == null || name == null || lastUpdated == null) continue;

      final label = Label.create(name: name).copyWith(
        createdAtMillis: lastUpdated,
      );
      labels[id] = label;
    }
    return labels;
  }
}

class MigratorExtensions {}
