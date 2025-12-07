import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/detection.dart';

abstract class FraudDetectionRepository {
  Future<Either<Failure, Detection>> detectCallFraud(String number);
  Future<Either<Failure, List<Detection>>> getRecentDetections();
  Future<Either<Failure, void>> reportDetection(int detectionId);
}
