import 'package:entitypool/entitypool.dart';
import 'package:flutter_test/flutter_test.dart';

class TestEntity with Entity<TestEntity, int> {
  @override
  int get id => 0;
}

void main() {
  test('can create EntityPoolKey', () {
    final entity = TestEntity();
    final key = EntityPoolKey.fromEntity(entity);
    expect(key, isA<EntityPoolKey<TestEntity, int>>());
  });
}
