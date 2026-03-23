import 'package:dartz/dartz.dart';
import 'package:votera/core/error/error_message_extractor.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/network/network_info.dart';
import 'package:votera/core/network/paginated_response.dart';
import 'package:votera/features/events/data/datasources/remote/event_remote_data_source.dart';
import 'package:votera/features/events/data/models/event_model.dart';
import 'package:votera/features/events/domain/entities/event_entity.dart';
import 'package:votera/features/events/domain/repositories/event_repository.dart';

class EventRepositoryImpl implements EventRepository {
  const EventRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  final EventRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  @override
  Future<Either<Failure, PaginatedResponse<EventEntity>>> getEvents({
    EventStatus? status,
    required int page,
    required int size,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(
        NetworkFailure(message: 'No internet connection'),
      );
    }
    try {
      final result = await remoteDataSource.getEvents(
        status: status,
        page: page,
        size: size,
      );
      return Right(
        PaginatedResponse.fromJson(result, EventModel.fromJson),
      );
    } on Exception catch (e) {
      return Left(ServerFailure(message: extractErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, EventEntity>> getEventById(String id) async {
    if (!await networkInfo.isConnected) {
      return const Left(
        NetworkFailure(message: 'No internet connection'),
      );
    }
    try {
      final result = await remoteDataSource.getEventById(id);
      return Right(EventModel.fromJson(result));
    } on Exception catch (e) {
      return Left(ServerFailure(message: extractErrorMessage(e)));
    }
  }
}
