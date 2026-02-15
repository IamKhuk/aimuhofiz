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
      // 1. Extract features from phone number
      final features = _extractFeatures(number);

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
      final detectionsData = await localDataSource.getAllDetections();
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
      return Left(DatabaseFailure());
    }
  }

  @override
  Future<Either<Failure, void>> reportDetection(int detectionId) async {
    try {
      await localDataSource.markAsReported(detectionId);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure());
    }
  }

  /// Convert phone number digits to a padded feature list of length 50
  List<double> _extractFeatures(String number) {
    final digits = number.replaceAll(RegExp(r'[^0-9]'), '');
    final features = List<double>.filled(50, 0.0);
    for (int i = 0; i < digits.length && i < 50; i++) {
      features[i] = double.parse(digits[i]) / 9.0;
    }
    return features;
  }
}
