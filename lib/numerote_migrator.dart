import 'dart:async';
import 'dart:io';
import 'package:moor/moor.dart';
import 'package:moor/ffi.dart';
import 'package:numerote_core/numerote_core.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class NumeroteMigrator {
  NumeroteMigrator({
    this.testing = false,
    this.databaseName = 'watermelon.db',
  });
  final bool testing;
  final String databaseName;

  Future<R> _useDatabase<R>(Future<R> Function(LazyDatabase) body) async {
    final database = LazyDatabase(() async => VmDatabase(await _dbFile));
    await database.ensureOpen(_WatermelonExecutor());
    final result = await body.call(database);
    await database.close();
    return result;
  }

  Future<Map<String, Label>> extractLabels() async {
    return await _useDatabase((db) async {
      final results = await db.runSelect("SELECT * from labels", []);
      final Map<String, Label> labels = {};
      for (final map in results) {
        final id = map['id'] as String;
        final label = Label.create(name: map['name'] as String).copyWith(
          createdAtMillis: map['last_updated'] as int,
        );

        labels[id] = label;
      }
      return labels;
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
      await _dbFile.then((value) => value.existsSync());
}

class _WatermelonExecutor extends QueryExecutorUser {
  @override
  int get schemaVersion => 1;

  @override
  Future<void> beforeOpen(
      QueryExecutor executor, OpeningDetails details) async {}
}
