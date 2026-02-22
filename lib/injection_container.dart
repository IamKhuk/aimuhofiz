import 'package:get_it/get_it.dart';
import 'core/services/sip_service.dart';
import 'features/fraud_detection/data/datasources/local_data_source.dart';
import 'features/fraud_detection/data/datasources/model_data_source.dart';
import 'features/fraud_detection/data/repositories/fraud_detection_repository_impl.dart';
import 'features/fraud_detection/domain/repositories/fraud_detection_repository.dart';
import 'features/fraud_detection/domain/usecases/detect_fraud.dart';
import 'features/fraud_detection/domain/usecases/get_recent_detections.dart';
import 'features/fraud_detection/presentation/bloc/detection_bloc.dart';
import 'features/fraud_detection/presentation/bloc/call_history_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Bloc
  sl.registerFactory(() => DetectionBloc(
        detectFraud: sl(),
        getRecentDetections: sl(),
      ));
  sl.registerFactory(() => CallHistoryBloc(localDb: sl()));

  // Services
  sl.registerLazySingleton<SipService>(() => SipService());

  // Use cases
  sl.registerLazySingleton(() => DetectFraud(sl()));
  sl.registerLazySingleton(() => GetRecentDetections(sl()));

  // Repository
  sl.registerLazySingleton<FraudDetectionRepository>(
    () => FraudDetectionRepositoryImpl(
      localDataSource: sl(),
      modelDataSource: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton(() => AppDatabase());
  sl.registerLazySingleton<ModelDataSource>(() => ModelDataSourceImpl());

  // Seed sample data on first launch
  await sl<AppDatabase>().seedSampleData();
}
