import 'dart:collection';

import 'package:entitypool/entitypool.dart';
import 'package:flutter_test/flutter_test.dart';

class TestPool extends Pool {}

class SomeEntity with Entity<SomeEntity, int> {
  final int id;

  SomeEntity(this.id);
}

class AnotherEntity with Entity<AnotherEntity, int> {
  final int id;

  AnotherEntity(this.id);
}

void main() {
  late TestPool pool;

  setUp(() {
    pool = TestPool();
  });

  test('can provide custom storage', () {
    Pool.createPoolStorage = () => SplayTreeMap();
    Pool.createPoolStorage = () => {};
  });

  test('can put entities of same type', () {
    final entity1 = SomeEntity(1);
    final entity2 = SomeEntity(2);
    final entity1key = pool.put(entity1);
    final entity2key = pool.put(entity2);
    expect(pool.containsKey(entity1key), isTrue);
    expect(pool.containsKey(entity2key), isTrue);
  });

  test('can put entities of different type', () {
    final entity1 = SomeEntity(1);
    final entity2 = AnotherEntity(1);
    final entity1key = pool.put(entity1);
    final entity2key = pool.put(entity2);
    expect(pool.containsKey(entity1key), isTrue);
    expect(pool.containsKey(entity2key), isTrue);
  });

  test('can get entities of type', () {
    final some1 = SomeEntity(1);
    final some2 = SomeEntity(2);
    final another1 = AnotherEntity(1);
    final another2 = AnotherEntity(2);

    final some1Key = pool.put(some1);
    final some2Key = pool.put(some2);
    final another1Key = pool.put(another1);
    final another2Key = pool.put(another2);

    final someEntities = pool.entitiesOfType<SomeEntity>();
    expect(someEntities.length, 2);
    expect(someEntities.contains(some1), isTrue);
    expect(someEntities.contains(some2), isTrue);

    final anotherEntities = pool.entitiesOfType<AnotherEntity>();
    expect(anotherEntities.length, 2);
    expect(anotherEntities.contains(another1), isTrue);
    expect(anotherEntities.contains(another2), isTrue);
  });

  test('can remove instance', () {
    final entity = SomeEntity(1);
    final key = pool.put(entity);
    expect(pool.containsKey(key), isTrue);
    final removedEntity = pool.remove(key);
    expect(pool.containsKey(key), isFalse);
    expect(removedEntity, entity);
  });

  test('can remove instance not contained entity', () {
    final entity = SomeEntity(1);
    final differentEntity = SomeEntity(2);
    final key = pool.put(entity);
    expect(pool.containsKey(key), isTrue);
    final removedEntity = pool.remove(
      EntityPoolKey.fromEntity(differentEntity),
    );
    expect(pool.containsKey(key), isTrue);
    expect(removedEntity, isNull);
  });

  test('can set new release key and remove entity for specific release key',
      () {
    final some1 = SomeEntity(1);
    final some2 = SomeEntity(2);
    final another1 = AnotherEntity(1);
    final another2 = AnotherEntity(2);

    final some1Key = pool.put(some1);
    pool.currentReleaseKey = ReleaseKey(1);
    final some2Key = pool.put(some2);
    pool.currentReleaseKey = ReleaseKey(2);
    final another1Key = pool.put(another1);
    pool.currentReleaseKey = ReleaseKey(3);
    final another2Key = pool.put(another2);

    expect(pool.containsKey(some1Key), isTrue);
    expect(pool.containsKey(some2Key), isTrue);
    expect(pool.containsKey(another1Key), isTrue);
    expect(pool.containsKey(another2Key), isTrue);

    pool.release(ReleaseKey(3));
    expect(pool.containsKey(some1Key), isTrue);
    expect(pool.containsKey(some2Key), isTrue);
    expect(pool.containsKey(another1Key), isTrue);
    expect(pool.containsKey(another2Key), isFalse);

    pool.release(ReleaseKey(2));
    expect(pool.containsKey(some1Key), isTrue);
    expect(pool.containsKey(some2Key), isTrue);
    expect(pool.containsKey(another1Key), isFalse);
    expect(pool.containsKey(another2Key), isFalse);

    pool.release(ReleaseKey(1));
    expect(pool.containsKey(some1Key), isTrue);
    expect(pool.containsKey(some2Key), isFalse);
    expect(pool.containsKey(another1Key), isFalse);
    expect(pool.containsKey(another2Key), isFalse);

    pool.release(ReleaseKey(1));
    expect(pool.containsKey(some1Key), isTrue);
    expect(pool.containsKey(some2Key), isFalse);
    expect(pool.containsKey(another1Key), isFalse);
    expect(pool.containsKey(another2Key), isFalse);

    pool.release(ReleaseKey(null));
    expect(pool.containsKey(some1Key), isFalse);
    expect(pool.containsKey(some2Key), isFalse);
    expect(pool.containsKey(another1Key), isFalse);
    expect(pool.containsKey(another2Key), isFalse);
  });
}
