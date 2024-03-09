import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:notes/data/hierarchyDatabase.dart';
import 'package:notes/services/nodeService.dart';

class MockHierarchyDatabase extends Mock implements HierarchyDatabase {}

void main() {
  MockHierarchyDatabase mockDb = MockHierarchyDatabase();
  NodeService nodeService = NodeService(hierarchyDb: mockDb);

  group('Cointains disallowed chars', () {
    test('Without disallowed chars', () {
      String name = "NameOfTheNote";
      expect(nodeService.containsDisabledChars(name), false);
    });

    test('With disallowed chars', () {
      String name = "Home/name";
      expect(nodeService.containsDisabledChars(name), true);
    });
  });
}
