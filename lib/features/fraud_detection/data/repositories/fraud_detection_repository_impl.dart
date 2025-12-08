import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/detection.dart';
import '../../domain/repositories/fraud_detection_repository.dart';
import '../datasources/local_data_source.dart';
import '../datasources/model_data_source.dart';
import 'package:drift/drift.dart' as drift;

class FraudDetectionRepositoryImpl implements FraudDetectionRepository {
  final AppDatabase localDataSource;
  final ModelDataSource modelDataSource;

  FraudDetectionRepositoryImpl({
    required this.localDataSource,
    required this.modelDataSource,
  });

  @override
  Future<Either<Failure, Detection>> detectCallFraud(String number) async {
    try {
      // 1. Extract features (mocked for now)
      final features = [1.0, 0.0, 0.5]; // Example features

      // 2. Run model
      final score = await modelDataSource.predict(features);

      // 3. Create detection record
      final detection = Detection(
        number: number,
        score: score,
        reason: 'Suspicious pattern',
        timestamp: DateTime.now(),
      );

      // 4. Save to local DB
      await localDataSource.insertDetection(
        DetectionTablesCompanion(
          number: drift.Value(detection.number),
          score: drift.Value(detection.score),
          reason: drift.Value(detection.reason),
          timestamp: drift.Value(detection.timestamp),
          reported: drift.Value(detection.reported),
        ),
      );

      return Right(detection);
    } catch (e) {
      return Left(DatabaseFailure());
    }
  }

  @override
  Future<Either<Failure, List<Detection>>> getRecentDetections() async {
    try {
      // Add short timeout to prevent blocking UI - database loads in background
      final detectionsData = await localDataSource.getAllDetections()
          .timeout(const Duration(seconds: 3), onTimeout: () => []);
      final detections = detectionsData.map((d) => Detection(
        id: d.id,
        number: d.number,
        score: d.score,
        reason: d.reason,
        timestamp: d.timestamp,
        reported: d.reported,
      )).toList();
      return Right(detections);
    } catch (e) {
      // Return empty list instead of failure on first run when database is initializing
      return const Right([]);
    }
  }

  @override
  Future<Either<Failure, void>> reportDetection(int detectionId) async {
    // Implement reporting logic
    return const Right(null);
  }
}
