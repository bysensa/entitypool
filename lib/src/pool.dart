import 'package:entitypool/entitypool.dart';
import 'package:flutter/widgets.dart';

import 'entity.dart';

class ReleaseKey {
  final Object? _value;

  ReleaseKey(this._value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReleaseKey &&
          runtimeType == other.runtimeType &&
          _value == other._value;

  @override
  int get hashCode => _value.hashCode;

  @override
  String toString() {
    return 'ReleaseKey{_value: $_value}';
  }
}

class EntityPoolKey<T extends Entity<T, ID>, ID extends Object> {
  final ID entityId;
  final Type entityType;

  EntityPoolKey(this.entityId, this.entityType);

  static EntityPoolKey<T, ID>
      fromEntity<T extends Entity<T, ID>, ID extends Object>(
    Entity<T, ID> entity,
  ) {
    return EntityPoolKey<T, ID>(entity.id, entity.entityType);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EntityPoolKey &&
          runtimeType == other.runtimeType &&
          entityId == other.entityId &&
          entityType == other.entityType;

  @override
  int get hashCode => entityId.hashCode ^ entityType.hashCode;

  @override
  String toString() {
    return 'EntityPoolKey{entityId: $entityId, entityType: $entityType}';
  }
}

abstract class Pool {
  static Map<EntityPoolKey, Entity> Function() createPoolStorage = () => {};

  ReleaseKey currentReleaseKey = ReleaseKey(null);

  /// Store [EntityPoolKey]s for [ReleaseKey]
  ///
  /// When the method [release] called we get provided [ReleaseKey] remove it
  /// from this structure and remove all entities stored in [Pool] for given
  /// [EntityPoolKey]s collection
  final Map<ReleaseKey?, Set<EntityPoolKey>> _releaseKeyBindings = {};

  late final Map<EntityPoolKey, Entity> _storage = createPoolStorage();

  int get size => _storage.length;

  bool containsKey(EntityPoolKey key) => _storage.containsKey(key);

  Entity<T, ID>? get<T extends Entity<T, ID>, ID extends Object>(
    EntityPoolKey<T, ID> key,
  ) {
    final maybeEntity = _storage[key];
    if (maybeEntity is Entity<T, ID>) {
      return maybeEntity;
    }
    return null;
  }

  List<Entity<T, Object>> entitiesOfType<T extends Entity<T, Object>>() {
    return _storage.entries
        .where((element) => element.key.entityType == T)
        .map((e) => e.value)
        .cast<Entity<T, Object>>()
        .toList();
  }

  EntityPoolKey<T, ID> put<T extends Entity<T, ID>, ID extends Object>(
    Entity<T, ID> entity,
  ) {
    final key = EntityPoolKey.fromEntity<T, ID>(entity);
    _releaseKeyBindings.update(
      currentReleaseKey,
      (value) => value..add(key),
      ifAbsent: () => {key},
    );
    _storage[key] = entity;
    return key;
  }

  Entity<T, ID>? update<T extends Entity<T, ID>, ID extends Object>(
    Entity<T, ID> entity,
  ) {
    final key = EntityPoolKey.fromEntity<T, ID>(entity);
    if (_storage.containsKey(key)) {
      _storage[key] = entity;
      return entity;
    }
    return null;
  }

  Entity<T, ID>? remove<T extends Entity<T, ID>, ID extends Object>(
    EntityPoolKey<T, ID> key,
  ) {
    final maybeTargetEntity = _storage.remove(key);
    if (maybeTargetEntity is Entity<T, ID>) {
      return maybeTargetEntity;
    }
    return null;
  }

  void release(ReleaseKey releaseKey) {
    final entitiesKeys = _releaseKeyBindings.remove(releaseKey);
    entitiesKeys?.forEach(_storage.remove);
  }

  clear() {
    _storage.clear();
    _releaseKeyBindings.clear();
  }
}

class NavigationBasedPoolManager extends NavigatorObserver {
  final Pool _pool;

  NavigationBasedPoolManager({
    required Pool pool,
  }) : _pool = pool;

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _pool.release(ReleaseKey(route));
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _pool.release(ReleaseKey(oldRoute));
    _pool.currentReleaseKey = ReleaseKey(newRoute);
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _pool.currentReleaseKey = ReleaseKey(route);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    _pool.release(ReleaseKey(route));
  }
}

abstract class Repository<T extends Entity<T, ID>, ID extends Object> {
  final Pool _pool;

  Repository({
    required Pool pool,
  }) : _pool = pool;

  bool containsEntity(ID id) {
    final poolKey = EntityPoolKey<T, ID>(id, T);
    return _pool.containsKey(poolKey);
  }

  List<T> list() {
    return _pool.entitiesOfType<T>().map((e) => e.downcast()).toList();
  }

  List<T> listWhere(bool Function(T) predicate) {
    return _pool
        .entitiesOfType<T>()
        .map((e) => e.downcast())
        .where(predicate)
        .toList();
  }

  T? get(ID id) {
    final poolKey = EntityPoolKey<T, ID>(id, T);
    final entity = _pool.get<T, ID>(poolKey);
    return entity?.downcast();
  }

  EntityPoolKey<T, ID> put(T entity) {
    return _pool.put(entity);
  }

  T? remove(ID id) {
    final poolKey = EntityPoolKey<T, ID>(id, T);
    return _pool.remove(poolKey)?.downcast();
  }

  T? update(ID id, {T Function(T)? using, T Function()? ifAbsent}) {
    if (using == null) {
      return null;
    }
    final maybeEntity = get(id);
    if (maybeEntity == null && ifAbsent != null) {
      final entity = ifAbsent();
      _pool.put(entity);
      return entity;
    }
    if (maybeEntity == null && ifAbsent == null) {
      return null;
    }
    final updatedEntity = using(maybeEntity!);
    assert(
      maybeEntity.id == updatedEntity.id,
      'Entity after update must have same id'
      'Before update id was ${maybeEntity.id} '
      'and after update it become ${updatedEntity.id}',
    );
    assert(
      maybeEntity.entityType == updatedEntity.entityType,
      'Entity after update must have same entity type. '
      'Before update the type was ${maybeEntity.entityType} '
      'and after update it become ${updatedEntity.entityType}',
    );
    return _pool.update(updatedEntity)?.downcast();
  }
}
