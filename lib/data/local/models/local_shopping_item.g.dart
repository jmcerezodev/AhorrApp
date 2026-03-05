// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_shopping_item.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetLocalShoppingItemCollection on Isar {
  IsarCollection<LocalShoppingItem> get localShoppingItems => this.collection();
}

const LocalShoppingItemSchema = CollectionSchema(
  name: r'LocalShoppingItem',
  id: 832595163065033985,
  properties: {
    r'amount': PropertySchema(
      id: 0,
      name: r'amount',
      type: IsarType.double,
    ),
    r'appwriteId': PropertySchema(
      id: 1,
      name: r'appwriteId',
      type: IsarType.string,
    ),
    r'category': PropertySchema(
      id: 2,
      name: r'category',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 3,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'isBought': PropertySchema(
      id: 4,
      name: r'isBought',
      type: IsarType.bool,
    ),
    r'name': PropertySchema(
      id: 5,
      name: r'name',
      type: IsarType.string,
    ),
    r'position': PropertySchema(
      id: 6,
      name: r'position',
      type: IsarType.long,
    ),
    r'userId': PropertySchema(
      id: 7,
      name: r'userId',
      type: IsarType.string,
    )
  },
  estimateSize: _localShoppingItemEstimateSize,
  serialize: _localShoppingItemSerialize,
  deserialize: _localShoppingItemDeserialize,
  deserializeProp: _localShoppingItemDeserializeProp,
  idName: r'id',
  indexes: {
    r'appwriteId': IndexSchema(
      id: -7929600070833471002,
      name: r'appwriteId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'appwriteId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _localShoppingItemGetId,
  getLinks: _localShoppingItemGetLinks,
  attach: _localShoppingItemAttach,
  version: '3.1.0+1',
);

int _localShoppingItemEstimateSize(
  LocalShoppingItem object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.appwriteId.length * 3;
  bytesCount += 3 + object.category.length * 3;
  bytesCount += 3 + object.name.length * 3;
  bytesCount += 3 + object.userId.length * 3;
  return bytesCount;
}

void _localShoppingItemSerialize(
  LocalShoppingItem object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.amount);
  writer.writeString(offsets[1], object.appwriteId);
  writer.writeString(offsets[2], object.category);
  writer.writeDateTime(offsets[3], object.createdAt);
  writer.writeBool(offsets[4], object.isBought);
  writer.writeString(offsets[5], object.name);
  writer.writeLong(offsets[6], object.position);
  writer.writeString(offsets[7], object.userId);
}

LocalShoppingItem _localShoppingItemDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = LocalShoppingItem();
  object.amount = reader.readDouble(offsets[0]);
  object.appwriteId = reader.readString(offsets[1]);
  object.category = reader.readString(offsets[2]);
  object.createdAt = reader.readDateTime(offsets[3]);
  object.id = id;
  object.isBought = reader.readBool(offsets[4]);
  object.name = reader.readString(offsets[5]);
  object.position = reader.readLong(offsets[6]);
  object.userId = reader.readString(offsets[7]);
  return object;
}

P _localShoppingItemDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readBool(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _localShoppingItemGetId(LocalShoppingItem object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _localShoppingItemGetLinks(
    LocalShoppingItem object) {
  return [];
}

void _localShoppingItemAttach(
    IsarCollection<dynamic> col, Id id, LocalShoppingItem object) {
  object.id = id;
}

extension LocalShoppingItemByIndex on IsarCollection<LocalShoppingItem> {
  Future<LocalShoppingItem?> getByAppwriteId(String appwriteId) {
    return getByIndex(r'appwriteId', [appwriteId]);
  }

  LocalShoppingItem? getByAppwriteIdSync(String appwriteId) {
    return getByIndexSync(r'appwriteId', [appwriteId]);
  }

  Future<bool> deleteByAppwriteId(String appwriteId) {
    return deleteByIndex(r'appwriteId', [appwriteId]);
  }

  bool deleteByAppwriteIdSync(String appwriteId) {
    return deleteByIndexSync(r'appwriteId', [appwriteId]);
  }

  Future<List<LocalShoppingItem?>> getAllByAppwriteId(
      List<String> appwriteIdValues) {
    final values = appwriteIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'appwriteId', values);
  }

  List<LocalShoppingItem?> getAllByAppwriteIdSync(
      List<String> appwriteIdValues) {
    final values = appwriteIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'appwriteId', values);
  }

  Future<int> deleteAllByAppwriteId(List<String> appwriteIdValues) {
    final values = appwriteIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'appwriteId', values);
  }

  int deleteAllByAppwriteIdSync(List<String> appwriteIdValues) {
    final values = appwriteIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'appwriteId', values);
  }

  Future<Id> putByAppwriteId(LocalShoppingItem object) {
    return putByIndex(r'appwriteId', object);
  }

  Id putByAppwriteIdSync(LocalShoppingItem object, {bool saveLinks = true}) {
    return putByIndexSync(r'appwriteId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByAppwriteId(List<LocalShoppingItem> objects) {
    return putAllByIndex(r'appwriteId', objects);
  }

  List<Id> putAllByAppwriteIdSync(List<LocalShoppingItem> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'appwriteId', objects, saveLinks: saveLinks);
  }
}

extension LocalShoppingItemQueryWhereSort
    on QueryBuilder<LocalShoppingItem, LocalShoppingItem, QWhere> {
  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension LocalShoppingItemQueryWhere
    on QueryBuilder<LocalShoppingItem, LocalShoppingItem, QWhereClause> {
  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QAfterWhereClause>
      idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QAfterWhereClause>
      idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QAfterWhereClause>
      appwriteIdEqualTo(String appwriteId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'appwriteId',
        value: [appwriteId],
      ));
    });
  }

  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QAfterWhereClause>
      appwriteIdNotEqualTo(String appwriteId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'appwriteId',
              lower: [],
              upper: [appwriteId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'appwriteId',
              lower: [appwriteId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'appwriteId',
              lower: [appwriteId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'appwriteId',
              lower: [],
              upper: [appwriteId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension LocalShoppingItemQueryFilter
    on QueryBuilder<LocalShoppingItem, LocalShoppingItem, QFilterCondition> {
  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QAfterFilterCondition>
      amountEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'amount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QAfterFilterCondition>
      amountGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'amount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QAfterFilterCondition>
      amountLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'amount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QAfterFilterCondition>
      amountBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'amount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QAfterFilterCondition>
      appwriteIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'appwriteId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QAfterFilterCondition>
      appwriteIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'appwriteId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QAfterFilterCondition>
      appwriteIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'appwriteId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QAfterFilterCondition>
      appwriteIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'appwriteId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QAfterFilterCondition>
      appwriteIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'appwriteId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QAfterFilterCondition>
      appwriteIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'appwriteId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QAfterFilterCondition>
      appwriteIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'appwriteId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QAfterFilterCondition>
      appwriteIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'appwriteId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QAfterFilterCondition>
      appwriteIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'appwriteId',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QAfterFilterCondition>
      appwriteIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'appwriteId',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QAfterFilterCondition>
      categoryEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QAfterFilterCondition>
      categoryGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QAfterFilterCondition>
      categoryLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QAfterFilterCondition>
      categoryBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'category',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QAfterFilterCondition>
      categoryStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QAfterFilterCondition>
      categoryEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QAfterFilterCondition>
      categoryContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QAfterFilterCondition>
      categoryMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'category',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QAfterFilterCondition>
      categoryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'category',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QAfterFilterCondition>
      categoryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'category',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QAfterFilterCondition>
      createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QAfterFilterCondition>
      createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QAfterFilterCondition>
      idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QAfterFilterCondition>
      isBoughtEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isBought',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QAfterFilterCondition>
      nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QAfterFilterCondition>
      nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QAfterFilterCondition>
      nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QAfterFilterCondition>
      nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QAfterFilterCondition>
      nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QAfterFilterCondition>
      nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QAfterFilterCondition>
      nameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QAfterFilterCondition>
      nameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QAfterFilterCondition>
      nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QAfterFilterCondition>
      nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QAfterFilterCondition>
      positionEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'position',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QAfterFilterCondition>
      positionGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'position',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QAfterFilterCondition>
      positionLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'position',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QAfterFilterCondition>
      positionBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'position',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QAfterFilterCondition>
      userIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QAfterFilterCondition>
      userIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QAfterFilterCondition>
      userIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QAfterFilterCondition>
      userIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'userId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QAfterFilterCondition>
      userIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QAfterFilterCondition>
      userIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QAfterFilterCondition>
      userIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QAfterFilterCondition>
      userIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'userId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QAfterFilterCondition>
      userIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QAfterFilterCondition>
      userIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userId',
        value: '',
      ));
    });
  }
}

extension LocalShoppingItemQueryObject
    on QueryBuilder<LocalShoppingItem, LocalShoppingItem, QFilterCondition> {}

extension LocalShoppingItemQueryLinks
    on QueryBuilder<LocalShoppingItem, LocalShoppingItem, QFilterCondition> {}

extension LocalShoppingItemQuerySortBy
    on QueryBuilder<LocalShoppingItem, LocalShoppingItem, QSortBy> {
  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QAfterSortBy>
      sortByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.asc);
    });
  }

  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QAfterSortBy>
      sortByAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.desc);
    });
  }

  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QAfterSortBy>
      sortByAppwriteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'appwriteId', Sort.asc);
    });
  }

  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QAfterSortBy>
      sortByAppwriteIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'appwriteId', Sort.desc);
    });
  }

  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QAfterSortBy>
      sortByCategory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.asc);
    });
  }

  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QAfterSortBy>
      sortByCategoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.desc);
    });
  }

  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QAfterSortBy>
      sortByIsBought() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isBought', Sort.asc);
    });
  }

  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QAfterSortBy>
      sortByIsBoughtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isBought', Sort.desc);
    });
  }

  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QAfterSortBy>
      sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QAfterSortBy>
      sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QAfterSortBy>
      sortByPosition() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'position', Sort.asc);
    });
  }

  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QAfterSortBy>
      sortByPositionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'position', Sort.desc);
    });
  }

  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QAfterSortBy>
      sortByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QAfterSortBy>
      sortByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension LocalShoppingItemQuerySortThenBy
    on QueryBuilder<LocalShoppingItem, LocalShoppingItem, QSortThenBy> {
  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QAfterSortBy>
      thenByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.asc);
    });
  }

  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QAfterSortBy>
      thenByAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.desc);
    });
  }

  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QAfterSortBy>
      thenByAppwriteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'appwriteId', Sort.asc);
    });
  }

  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QAfterSortBy>
      thenByAppwriteIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'appwriteId', Sort.desc);
    });
  }

  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QAfterSortBy>
      thenByCategory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.asc);
    });
  }

  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QAfterSortBy>
      thenByCategoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.desc);
    });
  }

  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QAfterSortBy>
      thenByIsBought() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isBought', Sort.asc);
    });
  }

  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QAfterSortBy>
      thenByIsBoughtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isBought', Sort.desc);
    });
  }

  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QAfterSortBy>
      thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QAfterSortBy>
      thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QAfterSortBy>
      thenByPosition() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'position', Sort.asc);
    });
  }

  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QAfterSortBy>
      thenByPositionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'position', Sort.desc);
    });
  }

  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QAfterSortBy>
      thenByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QAfterSortBy>
      thenByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension LocalShoppingItemQueryWhereDistinct
    on QueryBuilder<LocalShoppingItem, LocalShoppingItem, QDistinct> {
  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QDistinct>
      distinctByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'amount');
    });
  }

  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QDistinct>
      distinctByAppwriteId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'appwriteId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QDistinct>
      distinctByCategory({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'category', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QDistinct>
      distinctByIsBought() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isBought');
    });
  }

  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QDistinct>
      distinctByPosition() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'position');
    });
  }

  QueryBuilder<LocalShoppingItem, LocalShoppingItem, QDistinct>
      distinctByUserId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userId', caseSensitive: caseSensitive);
    });
  }
}

extension LocalShoppingItemQueryProperty
    on QueryBuilder<LocalShoppingItem, LocalShoppingItem, QQueryProperty> {
  QueryBuilder<LocalShoppingItem, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<LocalShoppingItem, double, QQueryOperations> amountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'amount');
    });
  }

  QueryBuilder<LocalShoppingItem, String, QQueryOperations>
      appwriteIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'appwriteId');
    });
  }

  QueryBuilder<LocalShoppingItem, String, QQueryOperations> categoryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'category');
    });
  }

  QueryBuilder<LocalShoppingItem, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<LocalShoppingItem, bool, QQueryOperations> isBoughtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isBought');
    });
  }

  QueryBuilder<LocalShoppingItem, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<LocalShoppingItem, int, QQueryOperations> positionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'position');
    });
  }

  QueryBuilder<LocalShoppingItem, String, QQueryOperations> userIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userId');
    });
  }
}
