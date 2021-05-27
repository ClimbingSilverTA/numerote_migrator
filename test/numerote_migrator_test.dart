import 'package:flutter_test/flutter_test.dart';
import 'package:numerote_core/numerote_core.dart';
import 'package:numerote_migrator/numerote_migrator.dart';

void main() {
  group('Simulated migration', () {
    final core = NumeroteCore.sql(testing: true);

    test('Ensure hasLegacyData returns true', () async {
      final migrator = NumeroteMigrator(
        core: core,
        testing: true,
        databaseName: 'en.db',
      );

      expect(await migrator.hasLegacyData, true);
    });

    // TODO: Need to try running with a larger sample size
    test('Try retrieving notes/labels from old database', () async {
      final migrator = NumeroteMigrator(
        core: core,
        testing: true,
        databaseName: 'en.db',
      );

      final labelsMap = await migrator.extractLabels();
      expect(labelsMap['8o5hbadz3qqj2f3x'], isNotNull);
      expect(labelsMap['pmxa7zowpwa3ea0f'], isNotNull);

      final notes = await migrator.extractNotes(labelsMap: labelsMap);
      expect(notes.length, 3);

      final picnicNote = notes.firstWhere(
        (element) => element.createdAtMillis == 1619673016841,
      );
      expect(picnicNote.contents,
          "I was planning a picnic for this week but that didn’t turn out happening so I wasn’t too happy but oh well");
      expect(picnicNote.labels.first.name, "Work");

      final fruitsNote = notes.firstWhere(
        (element) => element.createdAtMillis == 1619672095759,
      );
      expect(fruitsNote.contents,
          "Apples, oranges, strawberries, pears, watermelon, grapefruits and grapes.");
      expect(fruitsNote.labels.isEmpty, true);

      final optionsNote = notes.firstWhere(
        (element) => element.createdAtMillis == 1619673025020,
      );

      expect(optionsNote.contents,
          "There’s not much really left to say about my current options but that’s just how things are I suppose");
      expect(optionsNote.labels.first.name, "Ramblings");
    });

    test('Try running actual migration', () async {
      final migrator = NumeroteMigrator(
        core: core,
        testing: true,
        databaseName: 'ja.db',
      );

      await migrator.runMigration();
      final labels = await core.labels.find();
      expect(labels.length, 2);

      final notes = await core.notes.find();
      expect(notes.length, 3);

      await core.notes
          .find(label: labels.first)
          .then((value) => expect(value.isNotEmpty, true));

      await core.notes
          .find(label: labels.last)
          .then((value) => expect(value.isNotEmpty, true));
    });
  });
}
