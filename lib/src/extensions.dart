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

  List<Note> toNotesList({required Map<String, Label> labelsMap}) {
    final List<Note> notes = [];
    for (final map in this) {
      final contents = map['contents'] as String?;
      final timestamp = map['timestamp'] as int?;
      final labelId = map['label_id'] as String?;
      if (contents == null || timestamp == null) continue;

      var note = Note.create(contents: contents).copyWith(
        createdAtMillis: timestamp,
        updatedAtMillis: timestamp,
      );

      if (labelId != null &&
          labelId != 'null' &&
          labelsMap.containsKey(labelId)) {
        final label = labelsMap[labelId];
        if (label != null) {
          note = note.copyWith(labels: [label]);
        }
      }

      notes.add(note);
    }
    return notes;
  }
}

class MigratorExtensions {}
