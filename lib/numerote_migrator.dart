import 'dart:async';
import 'dart:io';
import 'package:moor/moor.dart';
import 'package:moor/ffi.dart';
import 'package:numerote_core/numerote_core.dart';
import 'package:numerote_migrator/src/extensions.dart';
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
    return _useDatabase(
      (db) async => db.runSelect("SELECT * FROM labels", []).then(
        (value) => value.toLabelIdMap(),
      ),
    );
  }

  Future<List<Note>> extractNotes({
    required Map<String, Label> labelsMap,
    int limit = 10,
    int offset = 0,
  }) async {
    return _useDatabase(
      (db) async => db.runSelect(
        "SELECT notes.id, contents, timestamp, label_id FROM notes LEFT JOIN note_labels on note_labels.note_id = notes.id LIMIT ? OFFSET ?",
        [limit, offset],
      ).then(
        (value) => value.toNotesList(labelsMap: labelsMap),
      ),
    );
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
