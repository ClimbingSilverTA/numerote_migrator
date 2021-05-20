import 'package:flutter_test/flutter_test.dart';
import 'package:numerote_migrator/numerote_migrator.dart';

void main() {
  group('Simulated migration', () {
    test('Ensure hasLegacyData returns true', () async {
      final migrator = NumeroteMigrator(
        testing: true,
        databaseName: 'en.db',
      );

      expect(await migrator.hasLegacyData, true);
    });

    test('Try retrieving labels from old database', () async {
      final migrator = NumeroteMigrator(
        testing: true,
        databaseName: 'en.db',
      );

      final labelsMap = await migrator.extractLabels();
      expect(labelsMap['8o5hbadz3qqj2f3x'], isNotNull);
      expect(labelsMap['pmxa7zowpwa3ea0f'], isNotNull);
    });
  });
}
