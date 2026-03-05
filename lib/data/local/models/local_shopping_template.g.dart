// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_shopping_template.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetLocalShoppingTemplateCollection on Isar {
  IsarCollection<LocalShoppingTemplate> get localShoppingTemplates =>
      this.collection();
}

const LocalShoppingTemplateSchema = CollectionSchema(
  name: r'LocalShoppingTemplate',
  id: 612774245175672525,
  properties: {
    r'appwriteId': PropertySchema(
      id: 0,
      name: r'appwriteId',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 1,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'itemsJson': PropertySchema(
      id: 2,
      name: r'itemsJson',
      type: IsarType.string,
    ),
    r'name': PropertySchema(
      id: 3,
      name: r'name',
      type: IsarType.string,
    ),
    r'userId': PropertySchema(
      id: 4,
      name: r'userId',
      type: IsarType.string,
    )
  },
  estimateSize: _localShoppingTemplateEstimateSize,
  serialize: _localShoppingTemplateSerialize,
  deserialize: _localShoppingTemplateDeserialize,
  deserializeProp: _localShoppingTemplateDeserializeProp,
  idName: r'id',
  indexes: {
    r'appwriteId': IndexSchema(
      id: -7929600070833471002,
      name: r'appwriteId',
      unique: true,
      replace: false,
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
  getId: _localShoppingTemplateGetId,
  getLinks: _localShoppingTemplateGetLinks,
  attach: _localShoppingTemplateAttach,
  version: '3.1.0+1',
);

int _localShoppingTemplateEstimateSize(
  LocalShoppingTemplate object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.appwriteId.length * 3;
  bytesCount += 3 + object.itemsJson.length * 3;
  bytesCount += 3 + object.name.length * 3;
  bytesCount += 3 + object.userId.length * 3;
  return bytesCount;
}

void _localShoppingTemplateSerialize(
  LocalShoppingTemplate object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.appwriteId);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeString(offsets[2], object.itemsJson);
  writer.writeString(offsets[3], object.name);
  writer.writeString(offsets[4], object.userId);
}

LocalShoppingTemplate _localShoppingTemplateDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = LocalShoppingTemplate();
  object.appwriteId = reader.readString(offsets[0]);
  object.createdAt = reader.readDateTime(offsets[1]);
  object.id = id;
  object.itemsJson = reader.readString(offsets[2]);
  object.name = reader.readString(offsets[3]);
  object.userId = reader.readString(offsets[4]);
  return object;
}

P _localShoppingTemplateDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _localShoppingTemplateGetId(LocalShoppingTemplate object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _localShoppingTemplateGetLinks(
    LocalShoppingTemplate object) {
  return [];
}

void _localShoppingTemplateAttach(
    IsarCollection<dynamic> col, Id id, LocalShoppingTemplate object) {
  object.id = id;
}

extension LocalShoppingTemplateByIndex
    on IsarCollection<LocalShoppingTemplate> {
  Future<LocalShoppingTemplate?> getByAppwriteId(String appwriteId) {
    return getByIndex(r'appwriteId', [appwriteId]);
  }

  LocalShoppingTemplate? getByAppwriteIdSync(String appwriteId) {
    return getByIndexSync(r'appwriteId', [appwriteId]);
  }

  Future<bool> deleteByAppwriteId(String appwriteId) {
    return deleteByIndex(r'appwriteId', [appwriteId]);
  }

  bool deleteByAppwriteIdSync(String appwriteId) {
    return deleteByIndexSync(r'appwriteId', [appwriteId]);
  }

  Future<List<LocalShoppingTemplate?>> getAllByAppwriteId(
      List<String> appwriteIdValues) {
    final values = appwriteIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'appwriteId', values);
  }

  List<LocalShoppingTemplate?> getAllByAppwriteIdSync(
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

  Future<Id> putByAppwriteId(LocalShoppingTemplate object) {
    return putByIndex(r'appwriteId', object);
  }

  Id putByAppwriteIdSync(LocalShoppingTemplate object,
      {bool saveLinks = true}) {
    return putByIndexSync(r'appwriteId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByAppwriteId(List<LocalShoppingTemplate> objects) {
    return putAllByIndex(r'appwriteId', objects);
  }

  List<Id> putAllByAppwriteIdSync(List<LocalShoppingTemplate> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'appwriteId', objects, saveLinks: saveLinks);
  }
}

extension LocalShoppingTemplateQueryWhereSort
    on QueryBuilder<LocalShoppingTemplate, LocalShoppingTemplate, QWhere> {
  QueryBuilder<LocalShoppingTemplate, LocalShoppingTemplate, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension LocalShoppingTemplateQueryWhere on QueryBuilder<LocalShoppingTemplate,
    LocalShoppingTemplate, QWhereClause> {
  QueryBuilder<LocalShoppingTemplate, LocalShoppingTemplate, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<LocalShoppingTemplate, LocalShoppingTemplate, QAfterWhereClause>
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

  QueryBuilder<LocalShoppingTemplate, LocalShoppingTemplate, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<LocalShoppingTemplate, LocalShoppingTemplate, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<LocalShoppingTemplate, LocalShoppingTemplate, QAfterWhereClause>
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

  QueryBuilder<LocalShoppingTemplate, LocalShoppingTemplate, QAfterWhereClause>
      appwriteIdEqualTo(String appwriteId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'appwriteId',
        value: [appwriteId],
      ));
    });
  }

  QueryBuilder<LocalShoppingTemplate, LocalShoppingTemplate, QAfterWhereClause>
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

extension LocalShoppingTemplateQueryFilter on QueryBuilder<
    LocalShoppingTemplate, LocalShoppingTemplate, QFilterCondition> {
  QueryBuilder<LocalShoppingTemplate, LocalShoppingTemplate,
      QAfterFilterCondition> appwriteIdEqualTo(
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

  QueryBuilder<LocalShoppingTemplate, LocalShoppingTemplate,
      QAfterFilterCondition> appwriteIdGreaterThan(
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

  QueryBuilder<LocalShoppingTemplate, LocalShoppingTemplate,
      QAfterFilterCondition> appwriteIdLessThan(
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

  QueryBuilder<LocalShoppingTemplate, LocalShoppingTemplate,
      QAfterFilterCondition> appwriteIdBetween(
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

  QueryBuilder<LocalShoppingTemplate, LocalShoppingTemplate,
      QAfterFilterCondition> appwriteIdStartsWith(
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

  QueryBuilder<LocalShoppingTemplate, LocalShoppingTemplate,
      QAfterFilterCondition> appwriteIdEndsWith(
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

  QueryBuilder<LocalShoppingTemplate, LocalShoppingTemplate,
          QAfterFilterCondition>
      appwriteIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'appwriteId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalShoppingTemplate, LocalShoppingTemplate,
          QAfterFilterCondition>
      appwriteIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'appwriteId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalShoppingTemplate, LocalShoppingTemplate,
      QAfterFilterCondition> appwriteIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'appwriteId',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalShoppingTemplate, LocalShoppingTemplate,
      QAfterFilterCondition> appwriteIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'appwriteId',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalShoppingTemplate, LocalShoppingTemplate,
      QAfterFilterCondition> createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalShoppingTemplate, LocalShoppingTemplate,
      QAfterFilterCondition> createdAtGreaterThan(
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

  QueryBuilder<LocalShoppingTemplate, LocalShoppingTemplate,
      QAfterFilterCondition> createdAtLessThan(
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

  QueryBuilder<LocalShoppingTemplate, LocalShoppingTemplate,
      QAfterFilterCondition> createdAtBetween(
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

  QueryBuilder<LocalShoppingTemplate, LocalShoppingTemplate,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalShoppingTemplate, LocalShoppingTemplate,
      QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<LocalShoppingTemplate, LocalShoppingTemplate,
      QAfterFilterCondition> idLessThan(
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

  QueryBuilder<LocalShoppingTemplate, LocalShoppingTemplate,
      QAfterFilterCondition> idBetween(
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

  QueryBuilder<LocalShoppingTemplate, LocalShoppingTemplate,
      QAfterFilterCondition> itemsJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'itemsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalShoppingTemplate, LocalShoppingTemplate,
      QAfterFilterCondition> itemsJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'itemsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalShoppingTemplate, LocalShoppingTemplate,
      QAfterFilterCondition> itemsJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'itemsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalShoppingTemplate, LocalShoppingTemplate,
      QAfterFilterCondition> itemsJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'itemsJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalShoppingTemplate, LocalShoppingTemplate,
      QAfterFilterCondition> itemsJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'itemsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalShoppingTemplate, LocalShoppingTemplate,
      QAfterFilterCondition> itemsJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'itemsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalShoppingTemplate, LocalShoppingTemplate,
          QAfterFilterCondition>
      itemsJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'itemsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalShoppingTemplate, LocalShoppingTemplate,
          QAfterFilterCondition>
      itemsJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'itemsJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalShoppingTemplate, LocalShoppingTemplate,
      QAfterFilterCondition> itemsJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'itemsJson',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalShoppingTemplate, LocalShoppingTemplate,
      QAfterFilterCondition> itemsJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'itemsJson',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalShoppingTemplate, LocalShoppingTemplate,
      QAfterFilterCondition> nameEqualTo(
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

  QueryBuilder<LocalShoppingTemplate, LocalShoppingTemplate,
      QAfterFilterCondition> nameGreaterThan(
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

  QueryBuilder<LocalShoppingTemplate, LocalShoppingTemplate,
      QAfterFilterCondition> nameLessThan(
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

  QueryBuilder<LocalShoppingTemplate, LocalShoppingTemplate,
      QAfterFilterCondition> nameBetween(
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

  QueryBuilder<LocalShoppingTemplate, LocalShoppingTemplate,
      QAfterFilterCondition> nameStartsWith(
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

  QueryBuilder<LocalShoppingTemplate, LocalShoppingTemplate,
      QAfterFilterCondition> nameEndsWith(
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

  QueryBuilder<LocalShoppingTemplate, LocalShoppingTemplate,
          QAfterFilterCondition>
      nameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalShoppingTemplate, LocalShoppingTemplate,
          QAfterFilterCondition>
      nameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalShoppingTemplate, LocalShoppingTemplate,
      QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalShoppingTemplate, LocalShoppingTemplate,
      QAfterFilterCondition> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalShoppingTemplate, LocalShoppingTemplate,
      QAfterFilterCondition> userIdEqualTo(
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

  QueryBuilder<LocalShoppingTemplate, LocalShoppingTemplate,
      QAfterFilterCondition> userIdGreaterThan(
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

  QueryBuilder<LocalShoppingTemplate, LocalShoppingTemplate,
      QAfterFilterCondition> userIdLessThan(
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

  QueryBuilder<LocalShoppingTemplate, LocalShoppingTemplate,
      QAfterFilterCondition> userIdBetween(
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

  QueryBuilder<LocalShoppingTemplate, LocalShoppingTemplate,
      QAfterFilterCondition> userIdStartsWith(
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

  QueryBuilder<LocalShoppingTemplate, LocalShoppingTemplate,
      QAfterFilterCondition> userIdEndsWith(
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

  QueryBuilder<LocalShoppingTemplate, LocalShoppingTemplate,
          QAfterFilterCondition>
      userIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalShoppingTemplate, LocalShoppingTemplate,
          QAfterFilterCondition>
      userIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'userId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalShoppingTemplate, LocalShoppingTemplate,
      QAfterFilterCondition> userIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalShoppingTemplate, LocalShoppingTemplate,
      QAfterFilterCondition> userIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userId',
        value: '',
      ));
    });
  }
}

extension LocalShoppingTemplateQueryObject on QueryBuilder<
    LocalShoppingTemplate, LocalShoppingTemplate, QFilterCondition> {}

extension LocalShoppingTemplateQueryLinks on QueryBuilder<LocalShoppingTemplate,
    LocalShoppingTemplate, QFilterCondition> {}

extension LocalShoppingTemplateQuerySortBy
    on QueryBuilder<LocalShoppingTemplate, LocalShoppingTemplate, QSortBy> {
  QueryBuilder<LocalShoppingTemplate, LocalShoppingTemplate, QAfterSortBy>
      sortByAppwriteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'appwriteId', Sort.asc);
    });
  }

  QueryBuilder<LocalShoppingTemplate, LocalShoppingTemplate, QAfterSortBy>
      sortByAppwriteIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'appwriteId', Sort.desc);
    });
  }

  QueryBuilder<LocalShoppingTemplate, LocalShoppingTemplate, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<LocalShoppingTemplate, LocalShoppingTemplate, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<LocalShoppingTemplate, LocalShoppingTemplate, QAfterSortBy>
      sortByItemsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemsJson', Sort.asc);
    });
  }

  QueryBuilder<LocalShoppingTemplate, LocalShoppingTemplate, QAfterSortBy>
      sortByItemsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemsJson', Sort.desc);
    });
  }

  QueryBuilder<LocalShoppingTemplate, LocalShoppingTemplate, QAfterSortBy>
      sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<LocalShoppingTemplate, LocalShoppingTemplate, QAfterSortBy>
      sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<LocalShoppingTemplate, LocalShoppingTemplate, QAfterSortBy>
      sortByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<LocalShoppingTemplate, LocalShoppingTemplate, QAfterSortBy>
      sortByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension LocalShoppingTemplateQuerySortThenBy
    on QueryBuilder<LocalShoppingTemplate, LocalShoppingTemplate, QSortThenBy> {
  QueryBuilder<LocalShoppingTemplate, LocalShoppingTemplate, QAfterSortBy>
      thenByAppwriteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'appwriteId', Sort.asc);
    });
  }

  QueryBuilder<LocalShoppingTemplate, LocalShoppingTemplate, QAfterSortBy>
      thenByAppwriteIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'appwriteId', Sort.desc);
    });
  }

  QueryBuilder<LocalShoppingTemplate, LocalShoppingTemplate, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<LocalShoppingTemplate, LocalShoppingTemplate, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<LocalShoppingTemplate, LocalShoppingTemplate, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<LocalShoppingTemplate, LocalShoppingTemplate, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<LocalShoppingTemplate, LocalShoppingTemplate, QAfterSortBy>
      thenByItemsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemsJson', Sort.asc);
    });
  }

  QueryBuilder<LocalShoppingTemplate, LocalShoppingTemplate, QAfterSortBy>
      thenByItemsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemsJson', Sort.desc);
    });
  }

  QueryBuilder<LocalShoppingTemplate, LocalShoppingTemplate, QAfterSortBy>
      thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<LocalShoppingTemplate, LocalShoppingTemplate, QAfterSortBy>
      thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<LocalShoppingTemplate, LocalShoppingTemplate, QAfterSortBy>
      thenByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<LocalShoppingTemplate, LocalShoppingTemplate, QAfterSortBy>
      thenByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension LocalShoppingTemplateQueryWhereDistinct
    on QueryBuilder<LocalShoppingTemplate, LocalShoppingTemplate, QDistinct> {
  QueryBuilder<LocalShoppingTemplate, LocalShoppingTemplate, QDistinct>
      distinctByAppwriteId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'appwriteId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalShoppingTemplate, LocalShoppingTemplate, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<LocalShoppingTemplate, LocalShoppingTemplate, QDistinct>
      distinctByItemsJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'itemsJson', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalShoppingTemplate, LocalShoppingTemplate, QDistinct>
      distinctByName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalShoppingTemplate, LocalShoppingTemplate, QDistinct>
      distinctByUserId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userId', caseSensitive: caseSensitive);
    });
  }
}

extension LocalShoppingTemplateQueryProperty on QueryBuilder<
    LocalShoppingTemplate, LocalShoppingTemplate, QQueryProperty> {
  QueryBuilder<LocalShoppingTemplate, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<LocalShoppingTemplate, String, QQueryOperations>
      appwriteIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'appwriteId');
    });
  }

  QueryBuilder<LocalShoppingTemplate, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<LocalShoppingTemplate, String, QQueryOperations>
      itemsJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'itemsJson');
    });
  }

  QueryBuilder<LocalShoppingTemplate, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<LocalShoppingTemplate, String, QQueryOperations>
      userIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userId');
    });
  }
}
