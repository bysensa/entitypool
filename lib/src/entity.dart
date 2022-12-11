import 'package:entitypool/entitypool.dart';

class EntityExtensionFieldNotPresent implements Exception {
  final Type extensionFieldType;
  final Type entityType;
  final Object entityId;

  EntityExtensionFieldNotPresent(
      this.extensionFieldType, this.entityType, this.entityId);

  @override
  String toString() {
    return 'ExtensionField of type $extensionFieldType not present in entity $entityType with id $entityId';
  }
}

class UnexpectedEntityExtensionFieldType implements Exception {
  final Type expectedType;
  final Type actualType;

  UnexpectedEntityExtensionFieldType(this.expectedType, this.actualType);

  @override
  String toString() {
    return 'The type of extension field expected to be $expectedType but actual type is $actualType';
  }
}

mixin Entity<T extends Entity<T, ID>, ID extends Object> {
  static final _extensionFields = Expando<Map<Type, ExtensionField>>();

  ID get id;

  bool _ensureCorrectEntityType() {
    return T is! Entity<dynamic, Object>;
  }

  Type get idType => ID;

  Type get entityType {
    assert(_ensureCorrectEntityType(), 'Entity type must not be dynamic');
    return T;
  }

  T downcast() => this as T;

  /// In case when [ifAbsent] not provided and [ExtensionField] of type [E] absent
  /// the [EntityExtensionFieldNotPresent] will be thrown.
  ExtensionField<E> extensionFieldOf<E>({E Function()? ifAbsent}) {
    var thisExtensionFields = _extensionFields[this];
    if (thisExtensionFields == null) {
      thisExtensionFields = <Type, ExtensionField>{};
      _extensionFields[this] = thisExtensionFields;
    }

    final hasExtensionField = thisExtensionFields.containsKey(E);
    if (hasExtensionField) {
      final extensionField = thisExtensionFields[E]!;
      if (extensionField is! ExtensionField<E>) {
        throw UnexpectedEntityExtensionFieldType(E, extensionField.type);
      }
      return extensionField;
    }

    if (ifAbsent == null) {
      throw EntityExtensionFieldNotPresent(E, entityType, id);
    }

    final extensionFieldValue = ifAbsent();
    final extensionField = ExtensionField<E>(extensionFieldValue);
    thisExtensionFields[extensionField.type] = extensionField;
    return extensionField;
  }

  E valueOf<E>({E Function()? ifAbsent}) {
    return extensionFieldOf<E>(ifAbsent: ifAbsent).value;
  }

  void updateExtensionField<E>(
    E Function(E?) ifPresent, {
    E Function()? ifAbsent,
  }) {
    final extensionField = extensionFieldOf<E>(ifAbsent: ifAbsent);
    final updatedValue = ifPresent(extensionField.value);
    extensionField.value = updatedValue;
  }
}

class ExtensionField<T> {
  Type get type => T;

  T value;

  ExtensionField(this.value);
}
