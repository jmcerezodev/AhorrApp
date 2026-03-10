// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_debt_loan.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetLocalDebtLoanCollection on Isar {
  IsarCollection<LocalDebtLoan> get localDebtLoans => this.collection();
}

const LocalDebtLoanSchema = CollectionSchema(
  name: r'LocalDebtLoan',
  id: -5125156093398999272,
  properties: {
    r'appwriteId': PropertySchema(
      id: 0,
      name: r'appwriteId',
      type: IsarType.string,
    ),
    r'category': PropertySchema(
      id: 1,
      name: r'category',
      type: IsarType.string,
    ),
    r'date': PropertySchema(
      id: 2,
      name: r'date',
      type: IsarType.dateTime,
    ),
    r'dueDate': PropertySchema(
      id: 3,
      name: r'dueDate',
      type: IsarType.dateTime,
    ),
    r'installmentAmount': PropertySchema(
      id: 4,
      name: r'installmentAmount',
      type: IsarType.double,
    ),
    r'isCompleted': PropertySchema(
      id: 5,
      name: r'isCompleted',
      type: IsarType.bool,
    ),
    r'isInstallment': PropertySchema(
      id: 6,
      name: r'isInstallment',
      type: IsarType.bool,
    ),
    r'name': PropertySchema(
      id: 7,
      name: r'name',
      type: IsarType.string,
    ),
    r'paidAmount': PropertySchema(
      id: 8,
      name: r'paidAmount',
      type: IsarType.double,
    ),
    r'person': PropertySchema(
      id: 9,
      name: r'person',
      type: IsarType.string,
    ),
    r'recurrentExpenseId': PropertySchema(
      id: 10,
      name: r'recurrentExpenseId',
      type: IsarType.string,
    ),
    r'totalAmount': PropertySchema(
      id: 11,
      name: r'totalAmount',
      type: IsarType.double,
    ),
    r'totalInstallments': PropertySchema(
      id: 12,
      name: r'totalInstallments',
      type: IsarType.long,
    ),
    r'type': PropertySchema(
      id: 13,
      name: r'type',
      type: IsarType.byte,
      enumMap: _LocalDebtLoantypeEnumValueMap,
    ),
    r'userId': PropertySchema(
      id: 14,
      name: r'userId',
      type: IsarType.string,
    )
  },
  estimateSize: _localDebtLoanEstimateSize,
  serialize: _localDebtLoanSerialize,
  deserialize: _localDebtLoanDeserialize,
  deserializeProp: _localDebtLoanDeserializeProp,
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
  getId: _localDebtLoanGetId,
  getLinks: _localDebtLoanGetLinks,
  attach: _localDebtLoanAttach,
  version: '3.1.0+1',
);

int _localDebtLoanEstimateSize(
  LocalDebtLoan object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.appwriteId.length * 3;
  bytesCount += 3 + object.category.length * 3;
  bytesCount += 3 + object.name.length * 3;
  bytesCount += 3 + object.person.length * 3;
  {
    final value = object.recurrentExpenseId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.userId.length * 3;
  return bytesCount;
}

void _localDebtLoanSerialize(
  LocalDebtLoan object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.appwriteId);
  writer.writeString(offsets[1], object.category);
  writer.writeDateTime(offsets[2], object.date);
  writer.writeDateTime(offsets[3], object.dueDate);
  writer.writeDouble(offsets[4], object.installmentAmount);
  writer.writeBool(offsets[5], object.isCompleted);
  writer.writeBool(offsets[6], object.isInstallment);
  writer.writeString(offsets[7], object.name);
  writer.writeDouble(offsets[8], object.paidAmount);
  writer.writeString(offsets[9], object.person);
  writer.writeString(offsets[10], object.recurrentExpenseId);
  writer.writeDouble(offsets[11], object.totalAmount);
  writer.writeLong(offsets[12], object.totalInstallments);
  writer.writeByte(offsets[13], object.type.index);
  writer.writeString(offsets[14], object.userId);
}

LocalDebtLoan _localDebtLoanDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = LocalDebtLoan();
  object.appwriteId = reader.readString(offsets[0]);
  object.category = reader.readString(offsets[1]);
  object.date = reader.readDateTimeOrNull(offsets[2]);
  object.dueDate = reader.readDateTimeOrNull(offsets[3]);
  object.id = id;
  object.installmentAmount = reader.readDoubleOrNull(offsets[4]);
  object.isCompleted = reader.readBool(offsets[5]);
  object.isInstallment = reader.readBool(offsets[6]);
  object.name = reader.readString(offsets[7]);
  object.paidAmount = reader.readDouble(offsets[8]);
  object.person = reader.readString(offsets[9]);
  object.recurrentExpenseId = reader.readStringOrNull(offsets[10]);
  object.totalAmount = reader.readDouble(offsets[11]);
  object.totalInstallments = reader.readLongOrNull(offsets[12]);
  object.type =
      _LocalDebtLoantypeValueEnumMap[reader.readByteOrNull(offsets[13])] ??
          DebtLoanType.debt;
  object.userId = reader.readString(offsets[14]);
  return object;
}

P _localDebtLoanDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 3:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 4:
      return (reader.readDoubleOrNull(offset)) as P;
    case 5:
      return (reader.readBool(offset)) as P;
    case 6:
      return (reader.readBool(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readDouble(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readStringOrNull(offset)) as P;
    case 11:
      return (reader.readDouble(offset)) as P;
    case 12:
      return (reader.readLongOrNull(offset)) as P;
    case 13:
      return (_LocalDebtLoantypeValueEnumMap[reader.readByteOrNull(offset)] ??
          DebtLoanType.debt) as P;
    case 14:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _LocalDebtLoantypeEnumValueMap = {
  'debt': 0,
  'loan': 1,
};
const _LocalDebtLoantypeValueEnumMap = {
  0: DebtLoanType.debt,
  1: DebtLoanType.loan,
};

Id _localDebtLoanGetId(LocalDebtLoan object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _localDebtLoanGetLinks(LocalDebtLoan object) {
  return [];
}

void _localDebtLoanAttach(
    IsarCollection<dynamic> col, Id id, LocalDebtLoan object) {
  object.id = id;
}

extension LocalDebtLoanByIndex on IsarCollection<LocalDebtLoan> {
  Future<LocalDebtLoan?> getByAppwriteId(String appwriteId) {
    return getByIndex(r'appwriteId', [appwriteId]);
  }

  LocalDebtLoan? getByAppwriteIdSync(String appwriteId) {
    return getByIndexSync(r'appwriteId', [appwriteId]);
  }

  Future<bool> deleteByAppwriteId(String appwriteId) {
    return deleteByIndex(r'appwriteId', [appwriteId]);
  }

  bool deleteByAppwriteIdSync(String appwriteId) {
    return deleteByIndexSync(r'appwriteId', [appwriteId]);
  }

  Future<List<LocalDebtLoan?>> getAllByAppwriteId(
      List<String> appwriteIdValues) {
    final values = appwriteIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'appwriteId', values);
  }

  List<LocalDebtLoan?> getAllByAppwriteIdSync(List<String> appwriteIdValues) {
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

  Future<Id> putByAppwriteId(LocalDebtLoan object) {
    return putByIndex(r'appwriteId', object);
  }

  Id putByAppwriteIdSync(LocalDebtLoan object, {bool saveLinks = true}) {
    return putByIndexSync(r'appwriteId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByAppwriteId(List<LocalDebtLoan> objects) {
    return putAllByIndex(r'appwriteId', objects);
  }

  List<Id> putAllByAppwriteIdSync(List<LocalDebtLoan> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'appwriteId', objects, saveLinks: saveLinks);
  }
}

extension LocalDebtLoanQueryWhereSort
    on QueryBuilder<LocalDebtLoan, LocalDebtLoan, QWhere> {
  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension LocalDebtLoanQueryWhere
    on QueryBuilder<LocalDebtLoan, LocalDebtLoan, QWhereClause> {
  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterWhereClause> idNotEqualTo(
      Id id) {
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

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterWhereClause> idBetween(
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

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterWhereClause>
      appwriteIdEqualTo(String appwriteId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'appwriteId',
        value: [appwriteId],
      ));
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterWhereClause>
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

extension LocalDebtLoanQueryFilter
    on QueryBuilder<LocalDebtLoan, LocalDebtLoan, QFilterCondition> {
  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition>
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

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition>
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

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition>
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

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition>
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

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition>
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

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition>
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

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition>
      appwriteIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'appwriteId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition>
      appwriteIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'appwriteId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition>
      appwriteIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'appwriteId',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition>
      appwriteIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'appwriteId',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition>
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

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition>
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

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition>
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

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition>
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

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition>
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

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition>
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

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition>
      categoryContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition>
      categoryMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'category',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition>
      categoryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'category',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition>
      categoryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'category',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition>
      dateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'date',
      ));
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition>
      dateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'date',
      ));
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition> dateEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition>
      dateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition>
      dateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition> dateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'date',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition>
      dueDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'dueDate',
      ));
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition>
      dueDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'dueDate',
      ));
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition>
      dueDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dueDate',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition>
      dueDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dueDate',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition>
      dueDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dueDate',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition>
      dueDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dueDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition>
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

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition> idBetween(
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

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition>
      installmentAmountIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'installmentAmount',
      ));
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition>
      installmentAmountIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'installmentAmount',
      ));
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition>
      installmentAmountEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'installmentAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition>
      installmentAmountGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'installmentAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition>
      installmentAmountLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'installmentAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition>
      installmentAmountBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'installmentAmount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition>
      isCompletedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isCompleted',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition>
      isInstallmentEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isInstallment',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition> nameEqualTo(
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

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition>
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

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition>
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

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition> nameBetween(
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

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition>
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

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition>
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

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition>
      nameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition> nameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition>
      nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition>
      nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition>
      paidAmountEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'paidAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition>
      paidAmountGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'paidAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition>
      paidAmountLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'paidAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition>
      paidAmountBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'paidAmount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition>
      personEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'person',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition>
      personGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'person',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition>
      personLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'person',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition>
      personBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'person',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition>
      personStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'person',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition>
      personEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'person',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition>
      personContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'person',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition>
      personMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'person',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition>
      personIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'person',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition>
      personIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'person',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition>
      recurrentExpenseIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'recurrentExpenseId',
      ));
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition>
      recurrentExpenseIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'recurrentExpenseId',
      ));
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition>
      recurrentExpenseIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'recurrentExpenseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition>
      recurrentExpenseIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'recurrentExpenseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition>
      recurrentExpenseIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'recurrentExpenseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition>
      recurrentExpenseIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'recurrentExpenseId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition>
      recurrentExpenseIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'recurrentExpenseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition>
      recurrentExpenseIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'recurrentExpenseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition>
      recurrentExpenseIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'recurrentExpenseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition>
      recurrentExpenseIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'recurrentExpenseId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition>
      recurrentExpenseIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'recurrentExpenseId',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition>
      recurrentExpenseIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'recurrentExpenseId',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition>
      totalAmountEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition>
      totalAmountGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition>
      totalAmountLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition>
      totalAmountBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalAmount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition>
      totalInstallmentsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'totalInstallments',
      ));
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition>
      totalInstallmentsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'totalInstallments',
      ));
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition>
      totalInstallmentsEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalInstallments',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition>
      totalInstallmentsGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalInstallments',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition>
      totalInstallmentsLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalInstallments',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition>
      totalInstallmentsBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalInstallments',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition> typeEqualTo(
      DebtLoanType value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition>
      typeGreaterThan(
    DebtLoanType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'type',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition>
      typeLessThan(
    DebtLoanType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'type',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition> typeBetween(
    DebtLoanType lower,
    DebtLoanType upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'type',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition>
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

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition>
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

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition>
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

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition>
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

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition>
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

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition>
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

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition>
      userIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition>
      userIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'userId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition>
      userIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterFilterCondition>
      userIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userId',
        value: '',
      ));
    });
  }
}

extension LocalDebtLoanQueryObject
    on QueryBuilder<LocalDebtLoan, LocalDebtLoan, QFilterCondition> {}

extension LocalDebtLoanQueryLinks
    on QueryBuilder<LocalDebtLoan, LocalDebtLoan, QFilterCondition> {}

extension LocalDebtLoanQuerySortBy
    on QueryBuilder<LocalDebtLoan, LocalDebtLoan, QSortBy> {
  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterSortBy> sortByAppwriteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'appwriteId', Sort.asc);
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterSortBy>
      sortByAppwriteIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'appwriteId', Sort.desc);
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterSortBy> sortByCategory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.asc);
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterSortBy>
      sortByCategoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.desc);
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterSortBy> sortByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterSortBy> sortByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterSortBy> sortByDueDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dueDate', Sort.asc);
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterSortBy> sortByDueDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dueDate', Sort.desc);
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterSortBy>
      sortByInstallmentAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'installmentAmount', Sort.asc);
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterSortBy>
      sortByInstallmentAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'installmentAmount', Sort.desc);
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterSortBy> sortByIsCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.asc);
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterSortBy>
      sortByIsCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.desc);
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterSortBy>
      sortByIsInstallment() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isInstallment', Sort.asc);
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterSortBy>
      sortByIsInstallmentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isInstallment', Sort.desc);
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterSortBy> sortByPaidAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paidAmount', Sort.asc);
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterSortBy>
      sortByPaidAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paidAmount', Sort.desc);
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterSortBy> sortByPerson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'person', Sort.asc);
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterSortBy> sortByPersonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'person', Sort.desc);
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterSortBy>
      sortByRecurrentExpenseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recurrentExpenseId', Sort.asc);
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterSortBy>
      sortByRecurrentExpenseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recurrentExpenseId', Sort.desc);
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterSortBy> sortByTotalAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalAmount', Sort.asc);
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterSortBy>
      sortByTotalAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalAmount', Sort.desc);
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterSortBy>
      sortByTotalInstallments() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalInstallments', Sort.asc);
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterSortBy>
      sortByTotalInstallmentsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalInstallments', Sort.desc);
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterSortBy> sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterSortBy> sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterSortBy> sortByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterSortBy> sortByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension LocalDebtLoanQuerySortThenBy
    on QueryBuilder<LocalDebtLoan, LocalDebtLoan, QSortThenBy> {
  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterSortBy> thenByAppwriteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'appwriteId', Sort.asc);
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterSortBy>
      thenByAppwriteIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'appwriteId', Sort.desc);
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterSortBy> thenByCategory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.asc);
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterSortBy>
      thenByCategoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.desc);
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterSortBy> thenByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterSortBy> thenByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterSortBy> thenByDueDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dueDate', Sort.asc);
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterSortBy> thenByDueDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dueDate', Sort.desc);
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterSortBy>
      thenByInstallmentAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'installmentAmount', Sort.asc);
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterSortBy>
      thenByInstallmentAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'installmentAmount', Sort.desc);
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterSortBy> thenByIsCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.asc);
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterSortBy>
      thenByIsCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.desc);
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterSortBy>
      thenByIsInstallment() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isInstallment', Sort.asc);
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterSortBy>
      thenByIsInstallmentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isInstallment', Sort.desc);
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterSortBy> thenByPaidAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paidAmount', Sort.asc);
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterSortBy>
      thenByPaidAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paidAmount', Sort.desc);
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterSortBy> thenByPerson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'person', Sort.asc);
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterSortBy> thenByPersonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'person', Sort.desc);
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterSortBy>
      thenByRecurrentExpenseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recurrentExpenseId', Sort.asc);
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterSortBy>
      thenByRecurrentExpenseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recurrentExpenseId', Sort.desc);
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterSortBy> thenByTotalAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalAmount', Sort.asc);
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterSortBy>
      thenByTotalAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalAmount', Sort.desc);
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterSortBy>
      thenByTotalInstallments() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalInstallments', Sort.asc);
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterSortBy>
      thenByTotalInstallmentsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalInstallments', Sort.desc);
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterSortBy> thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterSortBy> thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterSortBy> thenByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QAfterSortBy> thenByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension LocalDebtLoanQueryWhereDistinct
    on QueryBuilder<LocalDebtLoan, LocalDebtLoan, QDistinct> {
  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QDistinct> distinctByAppwriteId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'appwriteId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QDistinct> distinctByCategory(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'category', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QDistinct> distinctByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'date');
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QDistinct> distinctByDueDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dueDate');
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QDistinct>
      distinctByInstallmentAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'installmentAmount');
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QDistinct>
      distinctByIsCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isCompleted');
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QDistinct>
      distinctByIsInstallment() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isInstallment');
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QDistinct> distinctByPaidAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'paidAmount');
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QDistinct> distinctByPerson(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'person', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QDistinct>
      distinctByRecurrentExpenseId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'recurrentExpenseId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QDistinct>
      distinctByTotalAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalAmount');
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QDistinct>
      distinctByTotalInstallments() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalInstallments');
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QDistinct> distinctByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'type');
    });
  }

  QueryBuilder<LocalDebtLoan, LocalDebtLoan, QDistinct> distinctByUserId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userId', caseSensitive: caseSensitive);
    });
  }
}

extension LocalDebtLoanQueryProperty
    on QueryBuilder<LocalDebtLoan, LocalDebtLoan, QQueryProperty> {
  QueryBuilder<LocalDebtLoan, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<LocalDebtLoan, String, QQueryOperations> appwriteIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'appwriteId');
    });
  }

  QueryBuilder<LocalDebtLoan, String, QQueryOperations> categoryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'category');
    });
  }

  QueryBuilder<LocalDebtLoan, DateTime?, QQueryOperations> dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'date');
    });
  }

  QueryBuilder<LocalDebtLoan, DateTime?, QQueryOperations> dueDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dueDate');
    });
  }

  QueryBuilder<LocalDebtLoan, double?, QQueryOperations>
      installmentAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'installmentAmount');
    });
  }

  QueryBuilder<LocalDebtLoan, bool, QQueryOperations> isCompletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isCompleted');
    });
  }

  QueryBuilder<LocalDebtLoan, bool, QQueryOperations> isInstallmentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isInstallment');
    });
  }

  QueryBuilder<LocalDebtLoan, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<LocalDebtLoan, double, QQueryOperations> paidAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'paidAmount');
    });
  }

  QueryBuilder<LocalDebtLoan, String, QQueryOperations> personProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'person');
    });
  }

  QueryBuilder<LocalDebtLoan, String?, QQueryOperations>
      recurrentExpenseIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'recurrentExpenseId');
    });
  }

  QueryBuilder<LocalDebtLoan, double, QQueryOperations> totalAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalAmount');
    });
  }

  QueryBuilder<LocalDebtLoan, int?, QQueryOperations>
      totalInstallmentsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalInstallments');
    });
  }

  QueryBuilder<LocalDebtLoan, DebtLoanType, QQueryOperations> typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }

  QueryBuilder<LocalDebtLoan, String, QQueryOperations> userIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userId');
    });
  }
}
