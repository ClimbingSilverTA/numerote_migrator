import 'package:flutter_test/flutter_test.dart';
import 'package:numerote_migrator/src/legacy_database.dart';

void main() {
  group('Tests for extracting data', () {
    test('Try retrieving notes/labels from old database', () async {
      final legacyDb = LegacyDatabase(
        testing: true,
        databaseName: 'en.db',
      );

      final labelsMap = await legacyDb.extractLabels();
      expect(labelsMap['8o5hbadz3qqj2f3x'], isNotNull);
      expect(labelsMap['pmxa7zowpwa3ea0f'], isNotNull);

      final notes = await legacyDb.extractNotes(labelsMap: labelsMap);
      expect(notes.length, 3);

      final picnicNote = notes.firstWhere(
        (element) =>
            element.createdAtMillis == 1619673016841 &&
            element.updatedAtMillis == 1619673016841,
      );
      expect(picnicNote.contents,
          "I was planning a picnic for this week but that didn’t turn out happening so I wasn’t too happy but oh well");
      expect(picnicNote.labels.first.name, "Work");

      final fruitsNote = notes.firstWhere(
        (element) =>
            element.createdAtMillis == 1619672095759 &&
            element.updatedAtMillis == 1619672095759,
      );
      expect(fruitsNote.contents,
          "Apples, oranges, strawberries, pears, watermelon, grapefruits and grapes.");
      expect(fruitsNote.labels.isEmpty, true);

      final optionsNote = notes.firstWhere(
        (element) =>
            element.createdAtMillis == 1619673025020 &&
            element.updatedAtMillis == 1619673025020,
      );

      expect(optionsNote.contents,
          "There’s not much really left to say about my current options but that’s just how things are I suppose");
      expect(optionsNote.labels.first.name, "Ramblings");
    });
  });
}
