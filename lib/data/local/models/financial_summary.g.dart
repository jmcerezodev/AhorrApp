// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'financial_summary.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetFinancialSummaryCollection on Isar {
  IsarCollection<FinancialSummary> get financialSummarys => this.collection();
}

const FinancialSummarySchema = CollectionSchema(
  name: r'FinancialSummary',
  id: -5040217225553337199,
  properties: {
    r'savingGoal': PropertySchema(
      id: 0,
      name: r'savingGoal',
      type: IsarType.double,
    ),
    r'totalBalance': PropertySchema(
      id: 1,
      name: r'totalBalance',
      type: IsarType.double,
    ),
    r'userId': PropertySchema(
      id: 2,
      name: r'userId',
      type: IsarType.string,
    )
  },
  estimateSize: _financialSummaryEstimateSize,
  serialize: _financialSummarySerialize,
  deserialize: _financialSummaryDeserialize,
  deserializeProp: _financialSummaryDeserializeProp,
  idName: r'id',
  indexes: {
    r'userId': IndexSchema(
      id: -2005826577402374815,
      name: r'userId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'userId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _financialSummaryGetId,
  getLinks: _financialSummaryGetLinks,
  attach: _financialSummaryAttach,
  version: '3.1.0+1',
);

int _financialSummaryEstimateSize(
  FinancialSummary object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.userId.length * 3;
  return bytesCount;
}

void _financialSummarySerialize(
  FinancialSummary object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.savingGoal);
  writer.writeDouble(offsets[1], object.totalBalance);
  writer.writeString(offsets[2], object.userId);
}

FinancialSummary _financialSummaryDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = FinancialSummary();
  object.id = id;
  object.savingGoal = reader.readDouble(offsets[0]);
  object.totalBalance = reader.readDouble(offsets[1]);
  object.userId = reader.readString(offsets[2]);
  return object;
}

P _financialSummaryDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readDouble(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _financialSummaryGetId(FinancialSummary object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _financialSummaryGetLinks(FinancialSummary object) {
  return [];
}

void _financialSummaryAttach(
    IsarCollection<dynamic> col, Id id, FinancialSummary object) {
  object.id = id;
}

extension FinancialSummaryByIndex on IsarCollection<FinancialSummary> {
  Future<FinancialSummary?> getByUserId(String userId) {
    return getByIndex(r'userId', [userId]);
  }

  FinancialSummary? getByUserIdSync(String userId) {
    return getByIndexSync(r'userId', [userId]);
  }

  Future<bool> deleteByUserId(String userId) {
    return deleteByIndex(r'userId', [userId]);
  }

  bool deleteByUserIdSync(String userId) {
    return deleteByIndexSync(r'userId', [userId]);
  }

  Future<List<FinancialSummary?>> getAllByUserId(List<String> userIdValues) {
    final values = userIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'userId', values);
  }

  List<FinancialSummary?> getAllByUserIdSync(List<String> userIdValues) {
    final values = userIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'userId', values);
  }

  Future<int> deleteAllByUserId(List<String> userIdValues) {
    final values = userIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'userId', values);
  }

  int deleteAllByUserIdSync(List<String> userIdValues) {
    final values = userIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'userId', values);
  }

  Future<Id> putByUserId(FinancialSummary object) {
    return putByIndex(r'userId', object);
  }

  Id putByUserIdSync(FinancialSummary object, {bool saveLinks = true}) {
    return putByIndexSync(r'userId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByUserId(List<FinancialSummary> objects) {
    return putAllByIndex(r'userId', objects);
  }

  List<Id> putAllByUserIdSync(List<FinancialSummary> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'userId', objects, saveLinks: saveLinks);
  }
}

extension FinancialSummaryQueryWhereSort
    on QueryBuilder<FinancialSummary, FinancialSummary, QWhere> {
  QueryBuilder<FinancialSummary, FinancialSummary, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension FinancialSummaryQueryWhere
    on QueryBuilder<FinancialSummary, FinancialSummary, QWhereClause> {
  QueryBuilder<FinancialSummary, FinancialSummary, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<FinancialSummary, FinancialSummary, QAfterWhereClause>
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

  QueryBuilder<FinancialSummary, FinancialSummary, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<FinancialSummary, FinancialSummary, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<FinancialSummary, FinancialSummary, QAfterWhereClause> idBetween(
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

  QueryBuilder<FinancialSummary, FinancialSummary, QAfterWhereClause>
      userIdEqualTo(String userId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'userId',
        value: [userId],
      ));
    });
  }

  QueryBuilder<FinancialSummary, FinancialSummary, QAfterWhereClause>
      userIdNotEqualTo(String userId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'userId',
              lower: [],
              upper: [userId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'userId',
              lower: [userId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'userId',
              lower: [userId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'userId',
              lower: [],
              upper: [userId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension FinancialSummaryQueryFilter
    on QueryBuilder<FinancialSummary, FinancialSummary, QFilterCondition> {
  QueryBuilder<FinancialSummary, FinancialSummary, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<FinancialSummary, FinancialSummary, QAfterFilterCondition>
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

  QueryBuilder<FinancialSummary, FinancialSummary, QAfterFilterCondition>
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

  QueryBuilder<FinancialSummary, FinancialSummary, QAfterFilterCondition>
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

  QueryBuilder<FinancialSummary, FinancialSummary, QAfterFilterCondition>
      savingGoalEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'savingGoal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FinancialSummary, FinancialSummary, QAfterFilterCondition>
      savingGoalGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'savingGoal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FinancialSummary, FinancialSummary, QAfterFilterCondition>
      savingGoalLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'savingGoal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FinancialSummary, FinancialSummary, QAfterFilterCondition>
      savingGoalBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'savingGoal',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FinancialSummary, FinancialSummary, QAfterFilterCondition>
      totalBalanceEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalBalance',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FinancialSummary, FinancialSummary, QAfterFilterCondition>
      totalBalanceGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalBalance',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FinancialSummary, FinancialSummary, QAfterFilterCondition>
      totalBalanceLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalBalance',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FinancialSummary, FinancialSummary, QAfterFilterCondition>
      totalBalanceBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalBalance',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FinancialSummary, FinancialSummary, QAfterFilterCondition>
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

  QueryBuilder<FinancialSummary, FinancialSummary, QAfterFilterCondition>
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

  QueryBuilder<FinancialSummary, FinancialSummary, QAfterFilterCondition>
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

  QueryBuilder<FinancialSummary, FinancialSummary, QAfterFilterCondition>
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

  QueryBuilder<FinancialSummary, FinancialSummary, QAfterFilterCondition>
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

  QueryBuilder<FinancialSummary, FinancialSummary, QAfterFilterCondition>
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

  QueryBuilder<FinancialSummary, FinancialSummary, QAfterFilterCondition>
      userIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialSummary, FinancialSummary, QAfterFilterCondition>
      userIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'userId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialSummary, FinancialSummary, QAfterFilterCondition>
      userIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<FinancialSummary, FinancialSummary, QAfterFilterCondition>
      userIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userId',
        value: '',
      ));
    });
  }
}

extension FinancialSummaryQueryObject
    on QueryBuilder<FinancialSummary, FinancialSummary, QFilterCondition> {}

extension FinancialSummaryQueryLinks
    on QueryBuilder<FinancialSummary, FinancialSummary, QFilterCondition> {}

extension FinancialSummaryQuerySortBy
    on QueryBuilder<FinancialSummary, FinancialSummary, QSortBy> {
  QueryBuilder<FinancialSummary, FinancialSummary, QAfterSortBy>
      sortBySavingGoal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'savingGoal', Sort.asc);
    });
  }

  QueryBuilder<FinancialSummary, FinancialSummary, QAfterSortBy>
      sortBySavingGoalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'savingGoal', Sort.desc);
    });
  }

  QueryBuilder<FinancialSummary, FinancialSummary, QAfterSortBy>
      sortByTotalBalance() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalBalance', Sort.asc);
    });
  }

  QueryBuilder<FinancialSummary, FinancialSummary, QAfterSortBy>
      sortByTotalBalanceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalBalance', Sort.desc);
    });
  }

  QueryBuilder<FinancialSummary, FinancialSummary, QAfterSortBy>
      sortByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<FinancialSummary, FinancialSummary, QAfterSortBy>
      sortByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension FinancialSummaryQuerySortThenBy
    on QueryBuilder<FinancialSummary, FinancialSummary, QSortThenBy> {
  QueryBuilder<FinancialSummary, FinancialSummary, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<FinancialSummary, FinancialSummary, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<FinancialSummary, FinancialSummary, QAfterSortBy>
      thenBySavingGoal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'savingGoal', Sort.asc);
    });
  }

  QueryBuilder<FinancialSummary, FinancialSummary, QAfterSortBy>
      thenBySavingGoalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'savingGoal', Sort.desc);
    });
  }

  QueryBuilder<FinancialSummary, FinancialSummary, QAfterSortBy>
      thenByTotalBalance() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalBalance', Sort.asc);
    });
  }

  QueryBuilder<FinancialSummary, FinancialSummary, QAfterSortBy>
      thenByTotalBalanceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalBalance', Sort.desc);
    });
  }

  QueryBuilder<FinancialSummary, FinancialSummary, QAfterSortBy>
      thenByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<FinancialSummary, FinancialSummary, QAfterSortBy>
      thenByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension FinancialSummaryQueryWhereDistinct
    on QueryBuilder<FinancialSummary, FinancialSummary, QDistinct> {
  QueryBuilder<FinancialSummary, FinancialSummary, QDistinct>
      distinctBySavingGoal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'savingGoal');
    });
  }

  QueryBuilder<FinancialSummary, FinancialSummary, QDistinct>
      distinctByTotalBalance() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalBalance');
    });
  }

  QueryBuilder<FinancialSummary, FinancialSummary, QDistinct> distinctByUserId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userId', caseSensitive: caseSensitive);
    });
  }
}

extension FinancialSummaryQueryProperty
    on QueryBuilder<FinancialSummary, FinancialSummary, QQueryProperty> {
  QueryBuilder<FinancialSummary, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<FinancialSummary, double, QQueryOperations>
      savingGoalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'savingGoal');
    });
  }

  QueryBuilder<FinancialSummary, double, QQueryOperations>
      totalBalanceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalBalance');
    });
  }

  QueryBuilder<FinancialSummary, String, QQueryOperations> userIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userId');
    });
  }
}
