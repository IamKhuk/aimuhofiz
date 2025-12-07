// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_data_source.dart';

// ignore_for_file: type=lint
class $DetectionTablesTable extends DetectionTables
    with TableInfo<$DetectionTablesTable, DetectionData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DetectionTablesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _numberMeta = const VerificationMeta('number');
  @override
  late final GeneratedColumn<String> number = GeneratedColumn<String>(
    'number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<double> score = GeneratedColumn<double>(
    'score',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reportedMeta = const VerificationMeta(
    'reported',
  );
  @override
  late final GeneratedColumn<bool> reported = GeneratedColumn<bool>(
    'reported',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("reported" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    number,
    score,
    reason,
    timestamp,
    reported,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'detection_tables';
  @override
  VerificationContext validateIntegrity(
    Insertable<DetectionData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('number')) {
      context.handle(
        _numberMeta,
        number.isAcceptableOrUnknown(data['number']!, _numberMeta),
      );
    } else if (isInserting) {
      context.missing(_numberMeta);
    }
    if (data.containsKey('score')) {
      context.handle(
        _scoreMeta,
        score.isAcceptableOrUnknown(data['score']!, _scoreMeta),
      );
    } else if (isInserting) {
      context.missing(_scoreMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    } else if (isInserting) {
      context.missing(_reasonMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('reported')) {
      context.handle(
        _reportedMeta,
        reported.isAcceptableOrUnknown(data['reported']!, _reportedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DetectionData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DetectionData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      number: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}number'],
      )!,
      score: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}score'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
      reported: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}reported'],
      )!,
    );
  }

  @override
  $DetectionTablesTable createAlias(String alias) {
    return $DetectionTablesTable(attachedDatabase, alias);
  }
}

class DetectionData extends DataClass implements Insertable<DetectionData> {
  final int id;
  final String number;
  final double score;
  final String reason;
  final DateTime timestamp;
  final bool reported;
  const DetectionData({
    required this.id,
    required this.number,
    required this.score,
    required this.reason,
    required this.timestamp,
    required this.reported,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['number'] = Variable<String>(number);
    map['score'] = Variable<double>(score);
    map['reason'] = Variable<String>(reason);
    map['timestamp'] = Variable<DateTime>(timestamp);
    map['reported'] = Variable<bool>(reported);
    return map;
  }

  DetectionTablesCompanion toCompanion(bool nullToAbsent) {
    return DetectionTablesCompanion(
      id: Value(id),
      number: Value(number),
      score: Value(score),
      reason: Value(reason),
      timestamp: Value(timestamp),
      reported: Value(reported),
    );
  }

  factory DetectionData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DetectionData(
      id: serializer.fromJson<int>(json['id']),
      number: serializer.fromJson<String>(json['number']),
      score: serializer.fromJson<double>(json['score']),
      reason: serializer.fromJson<String>(json['reason']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      reported: serializer.fromJson<bool>(json['reported']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'number': serializer.toJson<String>(number),
      'score': serializer.toJson<double>(score),
      'reason': serializer.toJson<String>(reason),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'reported': serializer.toJson<bool>(reported),
    };
  }

  DetectionData copyWith({
    int? id,
    String? number,
    double? score,
    String? reason,
    DateTime? timestamp,
    bool? reported,
  }) => DetectionData(
    id: id ?? this.id,
    number: number ?? this.number,
    score: score ?? this.score,
    reason: reason ?? this.reason,
    timestamp: timestamp ?? this.timestamp,
    reported: reported ?? this.reported,
  );
  DetectionData copyWithCompanion(DetectionTablesCompanion data) {
    return DetectionData(
      id: data.id.present ? data.id.value : this.id,
      number: data.number.present ? data.number.value : this.number,
      score: data.score.present ? data.score.value : this.score,
      reason: data.reason.present ? data.reason.value : this.reason,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      reported: data.reported.present ? data.reported.value : this.reported,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DetectionData(')
          ..write('id: $id, ')
          ..write('number: $number, ')
          ..write('score: $score, ')
          ..write('reason: $reason, ')
          ..write('timestamp: $timestamp, ')
          ..write('reported: $reported')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, number, score, reason, timestamp, reported);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DetectionData &&
          other.id == this.id &&
          other.number == this.number &&
          other.score == this.score &&
          other.reason == this.reason &&
          other.timestamp == this.timestamp &&
          other.reported == this.reported);
}

class DetectionTablesCompanion extends UpdateCompanion<DetectionData> {
  final Value<int> id;
  final Value<String> number;
  final Value<double> score;
  final Value<String> reason;
  final Value<DateTime> timestamp;
  final Value<bool> reported;
  const DetectionTablesCompanion({
    this.id = const Value.absent(),
    this.number = const Value.absent(),
    this.score = const Value.absent(),
    this.reason = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.reported = const Value.absent(),
  });
  DetectionTablesCompanion.insert({
    this.id = const Value.absent(),
    required String number,
    required double score,
    required String reason,
    required DateTime timestamp,
    this.reported = const Value.absent(),
  }) : number = Value(number),
       score = Value(score),
       reason = Value(reason),
       timestamp = Value(timestamp);
  static Insertable<DetectionData> custom({
    Expression<int>? id,
    Expression<String>? number,
    Expression<double>? score,
    Expression<String>? reason,
    Expression<DateTime>? timestamp,
    Expression<bool>? reported,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (number != null) 'number': number,
      if (score != null) 'score': score,
      if (reason != null) 'reason': reason,
      if (timestamp != null) 'timestamp': timestamp,
      if (reported != null) 'reported': reported,
    });
  }

  DetectionTablesCompanion copyWith({
    Value<int>? id,
    Value<String>? number,
    Value<double>? score,
    Value<String>? reason,
    Value<DateTime>? timestamp,
    Value<bool>? reported,
  }) {
    return DetectionTablesCompanion(
      id: id ?? this.id,
      number: number ?? this.number,
      score: score ?? this.score,
      reason: reason ?? this.reason,
      timestamp: timestamp ?? this.timestamp,
      reported: reported ?? this.reported,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (number.present) {
      map['number'] = Variable<String>(number.value);
    }
    if (score.present) {
      map['score'] = Variable<double>(score.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (reported.present) {
      map['reported'] = Variable<bool>(reported.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DetectionTablesCompanion(')
          ..write('id: $id, ')
          ..write('number: $number, ')
          ..write('score: $score, ')
          ..write('reason: $reason, ')
          ..write('timestamp: $timestamp, ')
          ..write('reported: $reported')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $DetectionTablesTable detectionTables = $DetectionTablesTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [detectionTables];
}

typedef $$DetectionTablesTableCreateCompanionBuilder =
    DetectionTablesCompanion Function({
      Value<int> id,
      required String number,
      required double score,
      required String reason,
      required DateTime timestamp,
      Value<bool> reported,
    });
typedef $$DetectionTablesTableUpdateCompanionBuilder =
    DetectionTablesCompanion Function({
      Value<int> id,
      Value<String> number,
      Value<double> score,
      Value<String> reason,
      Value<DateTime> timestamp,
      Value<bool> reported,
    });

class $$DetectionTablesTableFilterComposer
    extends Composer<_$AppDatabase, $DetectionTablesTable> {
  $$DetectionTablesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get reported => $composableBuilder(
    column: $table.reported,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DetectionTablesTableOrderingComposer
    extends Composer<_$AppDatabase, $DetectionTablesTable> {
  $$DetectionTablesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get reported => $composableBuilder(
    column: $table.reported,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DetectionTablesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DetectionTablesTable> {
  $$DetectionTablesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get number =>
      $composableBuilder(column: $table.number, builder: (column) => column);

  GeneratedColumn<double> get score =>
      $composableBuilder(column: $table.score, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<bool> get reported =>
      $composableBuilder(column: $table.reported, builder: (column) => column);
}

class $$DetectionTablesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DetectionTablesTable,
          DetectionData,
          $$DetectionTablesTableFilterComposer,
          $$DetectionTablesTableOrderingComposer,
          $$DetectionTablesTableAnnotationComposer,
          $$DetectionTablesTableCreateCompanionBuilder,
          $$DetectionTablesTableUpdateCompanionBuilder,
          (
            DetectionData,
            BaseReferences<_$AppDatabase, $DetectionTablesTable, DetectionData>,
          ),
          DetectionData,
          PrefetchHooks Function()
        > {
  $$DetectionTablesTableTableManager(
    _$AppDatabase db,
    $DetectionTablesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DetectionTablesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DetectionTablesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DetectionTablesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> number = const Value.absent(),
                Value<double> score = const Value.absent(),
                Value<String> reason = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<bool> reported = const Value.absent(),
              }) => DetectionTablesCompanion(
                id: id,
                number: number,
                score: score,
                reason: reason,
                timestamp: timestamp,
                reported: reported,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String number,
                required double score,
                required String reason,
                required DateTime timestamp,
                Value<bool> reported = const Value.absent(),
              }) => DetectionTablesCompanion.insert(
                id: id,
                number: number,
                score: score,
                reason: reason,
                timestamp: timestamp,
                reported: reported,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DetectionTablesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DetectionTablesTable,
      DetectionData,
      $$DetectionTablesTableFilterComposer,
      $$DetectionTablesTableOrderingComposer,
      $$DetectionTablesTableAnnotationComposer,
      $$DetectionTablesTableCreateCompanionBuilder,
      $$DetectionTablesTableUpdateCompanionBuilder,
      (
        DetectionData,
        BaseReferences<_$AppDatabase, $DetectionTablesTable, DetectionData>,
      ),
      DetectionData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$DetectionTablesTableTableManager get detectionTables =>
      $$DetectionTablesTableTableManager(_db, _db.detectionTables);
}
