import 'dart:async';
import 'dart:io';
import 'package:moor/moor.dart';
import 'package:moor/ffi.dart';
import 'package:numerote_core/numerote_core.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class NumeroteMigrator {
  NumeroteMigrator({
    required this.core,
    this.testing = false,
    this.databaseName = 'watermelon.db',
  });

  final NumeroteCore core;
  final bool testing;
  final String databaseName;

  Future<R> _useDatabase<R>(Future<R> Function(LazyDatabase) body) async {
    final database = LazyDatabase(() async => VmDatabase(await _dbFile));
    await database.ensureOpen(_WatermelonExecutor());
    final result = await body.call(database);
    await database.close();
    return result;
  }

  Future<void> runMigration({int chunkSize = 50}) async {
    final labelsMap = await extractLabels();

    for (final label in labelsMap.values.toList()) {
      await core.labels.save(label);
    }

    var offset = 0;
    var notes = await extractNotes(
      labelsMap: labelsMap,
      offset: offset,
      limit: chunkSize,
    );

    while (notes.isNotEmpty) {
      for (final note in notes) {
        await core.notes.save(note);
      }

      offset += notes.length;
      notes = await extractNotes(
        labelsMap: labelsMap,
        offset: offset,
        limit: chunkSize,
      );
    }
  }

  Future<Map<String, Label>> extractLabels() async {
    return _useDatabase((db) async {
      final results = await db.runSelect("SELECT * FROM labels", []);
      final Map<String, Label> labels = {};
      for (final map in results) {
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
    });
  }

  Future<List<Note>> extractNotes({
    required Map<String, Label> labelsMap,
    int limit = 10,
    int offset = 0,
  }) async {
    return _useDatabase((db) async {
      final List<Note> notes = [];

      final results = await db.runSelect(
        "SELECT notes.id, contents, timestamp, label_id FROM notes LEFT JOIN note_labels on note_labels.note_id = notes.id LIMIT ? OFFSET ?",
        [limit, offset],
      );

      for (final map in results) {
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
    });
  }

  Future<File> get _dbFile async {
    if (!testing) {
      final dbFolder = await getApplicationDocumentsDirectory();
      return File(p.join(dbFolder.path, databaseName));
    } else {
      return File('./test/resources/$databaseName');
    }
  }

  Future<bool> get hasLegacyData async =>
      _dbFile.then((value) => value.existsSync());
}

class _WatermelonExecutor extends QueryExecutorUser {
  @override
  int get schemaVersion => 1;

  @override
  Future<void> beforeOpen(
      QueryExecutor executor, OpeningDetails details) async {}
}
