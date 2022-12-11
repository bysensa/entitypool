import 'package:entitypool/entitypool.dart';
import 'package:flutter_test/flutter_test.dart';

import 'entity_pool_key_test.dart';

class TestEntity with Entity<TestEntity, int> {
  @override
  int get id => throw UnimplementedError();
}

void main() {
  test('should return entity type', () {
    final instance = TestEntity();
    expect(instance.entityType, TestEntity);
  });

  test('should return id type', () {
    final instance = TestEntity();
    expect(instance.idType, int);
  });

  test('can downcast', () {
    final Entity<TestEntity, int> instance = TestEntity();
    final TestEntity downcasted = instance.downcast();
  });
}
