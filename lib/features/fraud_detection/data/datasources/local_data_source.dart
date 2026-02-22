import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'local_data_source.g.dart';

@DataClassName('DetectionData')
class DetectionTables extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get number => text()();
  RealColumn get score => real()();
  TextColumn get reason => text()();
  DateTimeColumn get timestamp => dateTime()();
  BoolColumn get reported => boolean().withDefault(const Constant(false))();
  TextColumn get audioFilePath => text().nullable()();
  TextColumn get serverAnalysisJson => text().nullable()();
  IntColumn get durationSeconds => integer().withDefault(const Constant(0))();
  TextColumn get callDirection => text().withDefault(const Constant('outgoing'))();
  TextColumn get callType => text().withDefault(const Constant('voip'))();
  TextColumn get contactName => text().nullable()();
  BoolColumn get wasAnswered => boolean().withDefault(const Constant(true))();
}

@DriftDatabase(tables: [DetectionTables])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        // Create index on timestamp for faster queries
        await customStatement('CREATE INDEX IF NOT EXISTS idx_detection_timestamp ON detection_tables (timestamp DESC)');
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          // Add index in migration if upgrading from version 1
          await customStatement('CREATE INDEX IF NOT EXISTS idx_detection_timestamp ON detection_tables (timestamp DESC)');
        }
        if (from < 3) {
          await customStatement('ALTER TABLE detection_tables ADD COLUMN audio_file_path TEXT');
          await customStatement('ALTER TABLE detection_tables ADD COLUMN server_analysis_json TEXT');
        }
        if (from < 4) {
          await customStatement("ALTER TABLE detection_tables ADD COLUMN duration_seconds INTEGER NOT NULL DEFAULT 0");
          await customStatement("ALTER TABLE detection_tables ADD COLUMN call_direction TEXT NOT NULL DEFAULT 'outgoing'");
          await customStatement("ALTER TABLE detection_tables ADD COLUMN call_type TEXT NOT NULL DEFAULT 'voip'");
          await customStatement("ALTER TABLE detection_tables ADD COLUMN contact_name TEXT");
          await customStatement("ALTER TABLE detection_tables ADD COLUMN was_answered INTEGER NOT NULL DEFAULT 1");
        }
      },
    );
  }

  Future<int> insertDetection(DetectionTablesCompanion detection) {
    return into(detectionTables).insert(detection);
  }

  Future<int> markAsReported(int id) {
    return (update(detectionTables)..where((t) => t.id.equals(id)))
        .write(const DetectionTablesCompanion(reported: Value(true)));
  }

  Future<int> updateAudioFilePath(int id, String path) {
    return (update(detectionTables)..where((t) => t.id.equals(id)))
        .write(DetectionTablesCompanion(audioFilePath: Value(path)));
  }

  Future<int> updateServerAnalysis(int id, String json) {
    return (update(detectionTables)..where((t) => t.id.equals(id)))
        .write(DetectionTablesCompanion(serverAnalysisJson: Value(json)));
  }

  Future<int> deleteDetection(int id) {
    return (delete(detectionTables)..where((t) => t.id.equals(id))).go();
  }

  Future<int> deleteAllDetections() {
    return delete(detectionTables).go();
  }

  Future<void> seedSampleData() async {
    final count = await detectionTables.count().getSingle();
    if (count > 0) return;

    final now = DateTime.now();
    final samples = [
      DetectionTablesCompanion(
        number: const Value('+998901234567'),
        score: const Value(92),
        reason: const Value('Soliq xizmati firibgarligi aniqlandi: shoshilinch to\'lov talab qilindi'),
        timestamp: Value(now.subtract(const Duration(hours: 2))),
        durationSeconds: const Value(185),
        callDirection: const Value('incoming'),
        callType: const Value('voip'),
        wasAnswered: const Value(true),
      ),
      DetectionTablesCompanion(
        number: const Value('+998935551234'),
        score: const Value(78),
        reason: const Value('Tech support firibgarligi: kompyuteringizga masofaviy kirish so\'raldi'),
        timestamp: Value(now.subtract(const Duration(hours: 18))),
        durationSeconds: const Value(342),
        callDirection: const Value('incoming'),
        callType: const Value('voip'),
        wasAnswered: const Value(true),
      ),
      DetectionTablesCompanion(
        number: const Value('+998911112233'),
        score: const Value(65),
        reason: const Value('Bank hisobini tekshirish so\'rovi: shubhali so\'rov'),
        timestamp: Value(now.subtract(const Duration(days: 1, hours: 5))),
        durationSeconds: const Value(120),
        callDirection: const Value('outgoing'),
        callType: const Value('voip'),
        wasAnswered: const Value(true),
      ),
      DetectionTablesCompanion(
        number: const Value('+998943334455'),
        score: const Value(45),
        reason: const Value('Lotereya yutug\'i haqida shubhali xabar'),
        timestamp: Value(now.subtract(const Duration(days: 2, hours: 10))),
        durationSeconds: const Value(67),
        callDirection: const Value('incoming'),
        callType: const Value('voip'),
        wasAnswered: const Value(true),
      ),
      DetectionTablesCompanion(
        number: const Value('+998977778899'),
        score: const Value(12),
        reason: const Value('Oddiy qo\'ng\'iroq, xavf aniqlanmadi'),
        timestamp: Value(now.subtract(const Duration(days: 3))),
        durationSeconds: const Value(480),
        callDirection: const Value('outgoing'),
        callType: const Value('voip'),
        wasAnswered: const Value(true),
      ),
    ];

    await batch((b) => b.insertAll(detectionTables, samples));
  }

  /// Get all detections ordered by timestamp (newest first) with a reasonable limit
  /// This prevents loading too many records into memory at once
  Future<List<DetectionData>> getAllDetections({int limit = 1000}) {
    return (select(detectionTables)
          ..orderBy([
            (t) => OrderingTerm(expression: t.timestamp, mode: OrderingMode.desc)
          ])
          ..limit(limit))
        .get();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'firib_lock_db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
