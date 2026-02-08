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
}

@DriftDatabase(tables: [DetectionTables])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

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
