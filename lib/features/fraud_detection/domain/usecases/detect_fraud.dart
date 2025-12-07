import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/detection.dart';
import '../repositories/fraud_detection_repository.dart';

class DetectFraud implements UseCase<Detection, DetectFraudParams> {
  final FraudDetectionRepository repository;

  DetectFraud(this.repository);

  @override
  Future<Either<Failure, Detection>> call(DetectFraudParams params) async {
    return await repository.detectCallFraud(params.number);
  }
}

class DetectFraudParams extends Equatable {
  final String number;

  const DetectFraudParams({required this.number});

  @override
  List<Object> get props => [number];
}
