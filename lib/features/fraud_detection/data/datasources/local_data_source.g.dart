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
  static const VerificationMeta _audioFilePathMeta = const VerificationMeta(
    'audioFilePath',
  );
  @override
  late final GeneratedColumn<String> audioFilePath = GeneratedColumn<String>(
    'audio_file_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverAnalysisJsonMeta =
      const VerificationMeta('serverAnalysisJson');
  @override
  late final GeneratedColumn<String> serverAnalysisJson =
      GeneratedColumn<String>(
        'server_analysis_json',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _durationSecondsMeta = const VerificationMeta(
    'durationSeconds',
  );
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
    'duration_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _callDirectionMeta = const VerificationMeta(
    'callDirection',
  );
  @override
  late final GeneratedColumn<String> callDirection = GeneratedColumn<String>(
    'call_direction',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('outgoing'),
  );
  static const VerificationMeta _callTypeMeta = const VerificationMeta(
    'callType',
  );
  @override
  late final GeneratedColumn<String> callType = GeneratedColumn<String>(
    'call_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('voip'),
  );
  static const VerificationMeta _contactNameMeta = const VerificationMeta(
    'contactName',
  );
  @override
  late final GeneratedColumn<String> contactName = GeneratedColumn<String>(
    'contact_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _wasAnsweredMeta = const VerificationMeta(
    'wasAnswered',
  );
  @override
  late final GeneratedColumn<bool> wasAnswered = GeneratedColumn<bool>(
    'was_answered',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("was_answered" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    number,
    score,
    reason,
    timestamp,
    reported,
    audioFilePath,
    serverAnalysisJson,
    durationSeconds,
    callDirection,
    callType,
    contactName,
    wasAnswered,
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
    if (data.containsKey('audio_file_path')) {
      context.handle(
        _audioFilePathMeta,
        audioFilePath.isAcceptableOrUnknown(
          data['audio_file_path']!,
          _audioFilePathMeta,
        ),
      );
    }
    if (data.containsKey('server_analysis_json')) {
      context.handle(
        _serverAnalysisJsonMeta,
        serverAnalysisJson.isAcceptableOrUnknown(
          data['server_analysis_json']!,
          _serverAnalysisJsonMeta,
        ),
      );
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
        _durationSecondsMeta,
        durationSeconds.isAcceptableOrUnknown(
          data['duration_seconds']!,
          _durationSecondsMeta,
        ),
      );
    }
    if (data.containsKey('call_direction')) {
      context.handle(
        _callDirectionMeta,
        callDirection.isAcceptableOrUnknown(
          data['call_direction']!,
          _callDirectionMeta,
        ),
      );
    }
    if (data.containsKey('call_type')) {
      context.handle(
        _callTypeMeta,
        callType.isAcceptableOrUnknown(data['call_type']!, _callTypeMeta),
      );
    }
    if (data.containsKey('contact_name')) {
      context.handle(
        _contactNameMeta,
        contactName.isAcceptableOrUnknown(
          data['contact_name']!,
          _contactNameMeta,
        ),
      );
    }
    if (data.containsKey('was_answered')) {
      context.handle(
        _wasAnsweredMeta,
        wasAnswered.isAcceptableOrUnknown(
          data['was_answered']!,
          _wasAnsweredMeta,
        ),
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
      audioFilePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}audio_file_path'],
      ),
      serverAnalysisJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_analysis_json'],
      ),
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_seconds'],
      )!,
      callDirection: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}call_direction'],
      )!,
      callType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}call_type'],
      )!,
      contactName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contact_name'],
      ),
      wasAnswered: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}was_answered'],
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
  final String? audioFilePath;
  final String? serverAnalysisJson;
  final int durationSeconds;
  final String callDirection;
  final String callType;
  final String? contactName;
  final bool wasAnswered;
  const DetectionData({
    required this.id,
    required this.number,
    required this.score,
    required this.reason,
    required this.timestamp,
    required this.reported,
    this.audioFilePath,
    this.serverAnalysisJson,
    required this.durationSeconds,
    required this.callDirection,
    required this.callType,
    this.contactName,
    required this.wasAnswered,
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
    if (!nullToAbsent || audioFilePath != null) {
      map['audio_file_path'] = Variable<String>(audioFilePath);
    }
    if (!nullToAbsent || serverAnalysisJson != null) {
      map['server_analysis_json'] = Variable<String>(serverAnalysisJson);
    }
    map['duration_seconds'] = Variable<int>(durationSeconds);
    map['call_direction'] = Variable<String>(callDirection);
    map['call_type'] = Variable<String>(callType);
    if (!nullToAbsent || contactName != null) {
      map['contact_name'] = Variable<String>(contactName);
    }
    map['was_answered'] = Variable<bool>(wasAnswered);
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
      audioFilePath: audioFilePath == null && nullToAbsent
          ? const Value.absent()
          : Value(audioFilePath),
      serverAnalysisJson: serverAnalysisJson == null && nullToAbsent
          ? const Value.absent()
          : Value(serverAnalysisJson),
      durationSeconds: Value(durationSeconds),
      callDirection: Value(callDirection),
      callType: Value(callType),
      contactName: contactName == null && nullToAbsent
          ? const Value.absent()
          : Value(contactName),
      wasAnswered: Value(wasAnswered),
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
      audioFilePath: serializer.fromJson<String?>(json['audioFilePath']),
      serverAnalysisJson: serializer.fromJson<String?>(
        json['serverAnalysisJson'],
      ),
      durationSeconds: serializer.fromJson<int>(json['durationSeconds']),
      callDirection: serializer.fromJson<String>(json['callDirection']),
      callType: serializer.fromJson<String>(json['callType']),
      contactName: serializer.fromJson<String?>(json['contactName']),
      wasAnswered: serializer.fromJson<bool>(json['wasAnswered']),
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
      'audioFilePath': serializer.toJson<String?>(audioFilePath),
      'serverAnalysisJson': serializer.toJson<String?>(serverAnalysisJson),
      'durationSeconds': serializer.toJson<int>(durationSeconds),
      'callDirection': serializer.toJson<String>(callDirection),
      'callType': serializer.toJson<String>(callType),
      'contactName': serializer.toJson<String?>(contactName),
      'wasAnswered': serializer.toJson<bool>(wasAnswered),
    };
  }

  DetectionData copyWith({
    int? id,
    String? number,
    double? score,
    String? reason,
    DateTime? timestamp,
    bool? reported,
    Value<String?> audioFilePath = const Value.absent(),
    Value<String?> serverAnalysisJson = const Value.absent(),
    int? durationSeconds,
    String? callDirection,
    String? callType,
    Value<String?> contactName = const Value.absent(),
    bool? wasAnswered,
  }) => DetectionData(
    id: id ?? this.id,
    number: number ?? this.number,
    score: score ?? this.score,
    reason: reason ?? this.reason,
    timestamp: timestamp ?? this.timestamp,
    reported: reported ?? this.reported,
    audioFilePath: audioFilePath.present
        ? audioFilePath.value
        : this.audioFilePath,
    serverAnalysisJson: serverAnalysisJson.present
        ? serverAnalysisJson.value
        : this.serverAnalysisJson,
    durationSeconds: durationSeconds ?? this.durationSeconds,
    callDirection: callDirection ?? this.callDirection,
    callType: callType ?? this.callType,
    contactName: contactName.present ? contactName.value : this.contactName,
    wasAnswered: wasAnswered ?? this.wasAnswered,
  );
  DetectionData copyWithCompanion(DetectionTablesCompanion data) {
    return DetectionData(
      id: data.id.present ? data.id.value : this.id,
      number: data.number.present ? data.number.value : this.number,
      score: data.score.present ? data.score.value : this.score,
      reason: data.reason.present ? data.reason.value : this.reason,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      reported: data.reported.present ? data.reported.value : this.reported,
      audioFilePath: data.audioFilePath.present
          ? data.audioFilePath.value
          : this.audioFilePath,
      serverAnalysisJson: data.serverAnalysisJson.present
          ? data.serverAnalysisJson.value
          : this.serverAnalysisJson,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      callDirection: data.callDirection.present
          ? data.callDirection.value
          : this.callDirection,
      callType: data.callType.present ? data.callType.value : this.callType,
      contactName: data.contactName.present
          ? data.contactName.value
          : this.contactName,
      wasAnswered: data.wasAnswered.present
          ? data.wasAnswered.value
          : this.wasAnswered,
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
          ..write('reported: $reported, ')
          ..write('audioFilePath: $audioFilePath, ')
          ..write('serverAnalysisJson: $serverAnalysisJson, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('callDirection: $callDirection, ')
          ..write('callType: $callType, ')
          ..write('contactName: $contactName, ')
          ..write('wasAnswered: $wasAnswered')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    number,
    score,
    reason,
    timestamp,
    reported,
    audioFilePath,
    serverAnalysisJson,
    durationSeconds,
    callDirection,
    callType,
    contactName,
    wasAnswered,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DetectionData &&
          other.id == this.id &&
          other.number == this.number &&
          other.score == this.score &&
          other.reason == this.reason &&
          other.timestamp == this.timestamp &&
          other.reported == this.reported &&
          other.audioFilePath == this.audioFilePath &&
          other.serverAnalysisJson == this.serverAnalysisJson &&
          other.durationSeconds == this.durationSeconds &&
          other.callDirection == this.callDirection &&
          other.callType == this.callType &&
          other.contactName == this.contactName &&
          other.wasAnswered == this.wasAnswered);
}

class DetectionTablesCompanion extends UpdateCompanion<DetectionData> {
  final Value<int> id;
  final Value<String> number;
  final Value<double> score;
  final Value<String> reason;
  final Value<DateTime> timestamp;
  final Value<bool> reported;
  final Value<String?> audioFilePath;
  final Value<String?> serverAnalysisJson;
  final Value<int> durationSeconds;
  final Value<String> callDirection;
  final Value<String> callType;
  final Value<String?> contactName;
  final Value<bool> wasAnswered;
  const DetectionTablesCompanion({
    this.id = const Value.absent(),
    this.number = const Value.absent(),
    this.score = const Value.absent(),
    this.reason = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.reported = const Value.absent(),
    this.audioFilePath = const Value.absent(),
    this.serverAnalysisJson = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.callDirection = const Value.absent(),
    this.callType = const Value.absent(),
    this.contactName = const Value.absent(),
    this.wasAnswered = const Value.absent(),
  });
  DetectionTablesCompanion.insert({
    this.id = const Value.absent(),
    required String number,
    required double score,
    required String reason,
    required DateTime timestamp,
    this.reported = const Value.absent(),
    this.audioFilePath = const Value.absent(),
    this.serverAnalysisJson = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.callDirection = const Value.absent(),
    this.callType = const Value.absent(),
    this.contactName = const Value.absent(),
    this.wasAnswered = const Value.absent(),
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
    Expression<String>? audioFilePath,
    Expression<String>? serverAnalysisJson,
    Expression<int>? durationSeconds,
    Expression<String>? callDirection,
    Expression<String>? callType,
    Expression<String>? contactName,
    Expression<bool>? wasAnswered,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (number != null) 'number': number,
      if (score != null) 'score': score,
      if (reason != null) 'reason': reason,
      if (timestamp != null) 'timestamp': timestamp,
      if (reported != null) 'reported': reported,
      if (audioFilePath != null) 'audio_file_path': audioFilePath,
      if (serverAnalysisJson != null)
        'server_analysis_json': serverAnalysisJson,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (callDirection != null) 'call_direction': callDirection,
      if (callType != null) 'call_type': callType,
      if (contactName != null) 'contact_name': contactName,
      if (wasAnswered != null) 'was_answered': wasAnswered,
    });
  }

  DetectionTablesCompanion copyWith({
    Value<int>? id,
    Value<String>? number,
    Value<double>? score,
    Value<String>? reason,
    Value<DateTime>? timestamp,
    Value<bool>? reported,
    Value<String?>? audioFilePath,
    Value<String?>? serverAnalysisJson,
    Value<int>? durationSeconds,
    Value<String>? callDirection,
    Value<String>? callType,
    Value<String?>? contactName,
    Value<bool>? wasAnswered,
  }) {
    return DetectionTablesCompanion(
      id: id ?? this.id,
      number: number ?? this.number,
      score: score ?? this.score,
      reason: reason ?? this.reason,
      timestamp: timestamp ?? this.timestamp,
      reported: reported ?? this.reported,
      audioFilePath: audioFilePath ?? this.audioFilePath,
      serverAnalysisJson: serverAnalysisJson ?? this.serverAnalysisJson,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      callDirection: callDirection ?? this.callDirection,
      callType: callType ?? this.callType,
      contactName: contactName ?? this.contactName,
      wasAnswered: wasAnswered ?? this.wasAnswered,
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
    if (audioFilePath.present) {
      map['audio_file_path'] = Variable<String>(audioFilePath.value);
    }
    if (serverAnalysisJson.present) {
      map['server_analysis_json'] = Variable<String>(serverAnalysisJson.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (callDirection.present) {
      map['call_direction'] = Variable<String>(callDirection.value);
    }
    if (callType.present) {
      map['call_type'] = Variable<String>(callType.value);
    }
    if (contactName.present) {
      map['contact_name'] = Variable<String>(contactName.value);
    }
    if (wasAnswered.present) {
      map['was_answered'] = Variable<bool>(wasAnswered.value);
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
          ..write('reported: $reported, ')
          ..write('audioFilePath: $audioFilePath, ')
          ..write('serverAnalysisJson: $serverAnalysisJson, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('callDirection: $callDirection, ')
          ..write('callType: $callType, ')
          ..write('contactName: $contactName, ')
          ..write('wasAnswered: $wasAnswered')
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
      Value<String?> audioFilePath,
      Value<String?> serverAnalysisJson,
      Value<int> durationSeconds,
      Value<String> callDirection,
      Value<String> callType,
      Value<String?> contactName,
      Value<bool> wasAnswered,
    });
typedef $$DetectionTablesTableUpdateCompanionBuilder =
    DetectionTablesCompanion Function({
      Value<int> id,
      Value<String> number,
      Value<double> score,
      Value<String> reason,
      Value<DateTime> timestamp,
      Value<bool> reported,
      Value<String?> audioFilePath,
      Value<String?> serverAnalysisJson,
      Value<int> durationSeconds,
      Value<String> callDirection,
      Value<String> callType,
      Value<String?> contactName,
      Value<bool> wasAnswered,
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

  ColumnFilters<String> get audioFilePath => $composableBuilder(
    column: $table.audioFilePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serverAnalysisJson => $composableBuilder(
    column: $table.serverAnalysisJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get callDirection => $composableBuilder(
    column: $table.callDirection,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get callType => $composableBuilder(
    column: $table.callType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contactName => $composableBuilder(
    column: $table.contactName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get wasAnswered => $composableBuilder(
    column: $table.wasAnswered,
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

  ColumnOrderings<String> get audioFilePath => $composableBuilder(
    column: $table.audioFilePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serverAnalysisJson => $composableBuilder(
    column: $table.serverAnalysisJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get callDirection => $composableBuilder(
    column: $table.callDirection,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get callType => $composableBuilder(
    column: $table.callType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contactName => $composableBuilder(
    column: $table.contactName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get wasAnswered => $composableBuilder(
    column: $table.wasAnswered,
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

  GeneratedColumn<String> get audioFilePath => $composableBuilder(
    column: $table.audioFilePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get serverAnalysisJson => $composableBuilder(
    column: $table.serverAnalysisJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<String> get callDirection => $composableBuilder(
    column: $table.callDirection,
    builder: (column) => column,
  );

  GeneratedColumn<String> get callType =>
      $composableBuilder(column: $table.callType, builder: (column) => column);

  GeneratedColumn<String> get contactName => $composableBuilder(
    column: $table.contactName,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get wasAnswered => $composableBuilder(
    column: $table.wasAnswered,
    builder: (column) => column,
  );
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
                Value<String?> audioFilePath = const Value.absent(),
                Value<String?> serverAnalysisJson = const Value.absent(),
                Value<int> durationSeconds = const Value.absent(),
                Value<String> callDirection = const Value.absent(),
                Value<String> callType = const Value.absent(),
                Value<String?> contactName = const Value.absent(),
                Value<bool> wasAnswered = const Value.absent(),
              }) => DetectionTablesCompanion(
                id: id,
                number: number,
                score: score,
                reason: reason,
                timestamp: timestamp,
                reported: reported,
                audioFilePath: audioFilePath,
                serverAnalysisJson: serverAnalysisJson,
                durationSeconds: durationSeconds,
                callDirection: callDirection,
                callType: callType,
                contactName: contactName,
                wasAnswered: wasAnswered,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String number,
                required double score,
                required String reason,
                required DateTime timestamp,
                Value<bool> reported = const Value.absent(),
                Value<String?> audioFilePath = const Value.absent(),
                Value<String?> serverAnalysisJson = const Value.absent(),
                Value<int> durationSeconds = const Value.absent(),
                Value<String> callDirection = const Value.absent(),
                Value<String> callType = const Value.absent(),
                Value<String?> contactName = const Value.absent(),
                Value<bool> wasAnswered = const Value.absent(),
              }) => DetectionTablesCompanion.insert(
                id: id,
                number: number,
                score: score,
                reason: reason,
                timestamp: timestamp,
                reported: reported,
                audioFilePath: audioFilePath,
                serverAnalysisJson: serverAnalysisJson,
                durationSeconds: durationSeconds,
                callDirection: callDirection,
                callType: callType,
                contactName: contactName,
                wasAnswered: wasAnswered,
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
