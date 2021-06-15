import 'dart:async';
import 'package:numerote_core/numerote_core.dart';
import 'package:numerote_migrator/src/legacy_database.dart';

class NumeroteMigrator {
  NumeroteMigrator({
    required this.core,
    this.testing = false,
    this.databaseName = 'watermelon.db',
  }) : _legacyDb = LegacyDatabase(
          testing: testing,
          databaseName: databaseName,
        );

  final NumeroteCore core;
  final bool testing;
  final String databaseName;
  final LegacyDatabase _legacyDb;

  Future<void> runMigration({
    int chunkSize = 50,
    bool deleteExistingData = false,
  }) async {
    if (deleteExistingData) await core.nuke();

    final labelsMap = await _legacyDb.extractLabels();

    for (final label in labelsMap.values.toList()) {
      await core.labels.save(label);
    }

    var offset = 0;
    var notes = await _legacyDb.extractNotes(
      labelsMap: labelsMap,
      offset: offset,
      limit: chunkSize,
    );

    while (notes.isNotEmpty) {
      for (final note in notes) {
        await core.notes.save(note);
      }

      offset += notes.length;
      notes = await _legacyDb.extractNotes(
        labelsMap: labelsMap,
        offset: offset,
        limit: chunkSize,
      );
    }
  }

  Future<bool> get hasLegacyData async => _legacyDb.dbFileExists;
}
