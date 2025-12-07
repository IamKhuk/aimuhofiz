import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/detection.dart';
import '../repositories/fraud_detection_repository.dart';

class GetRecentDetections implements UseCase<List<Detection>, NoParams> {
  final FraudDetectionRepository repository;

  GetRecentDetections(this.repository);

  @override
  Future<Either<Failure, List<Detection>>> call(NoParams params) async {
    return await repository.getRecentDetections();
  }
}

