import 'package:dartz/dartz.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/network/network_info.dart';
import 'package:votera/features/authentication/data/datasources/remote/auth_remote_data_source.dart';
import 'package:votera/features/authentication/data/models/user_model.dart';
import 'package:votera/features/authentication/data/services/token_service.dart';
import 'package:votera/features/authentication/domain/entities/user_entity.dart';
import 'package:votera/features/authentication/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
    required this.tokenService,
  });

  final AuthRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  final TokenService tokenService;

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final result = await remoteDataSource.login(
        email: email,
        password: password,
      );
      final token = result['token'] as String?;
      final refreshToken = result['refreshToken'] as String?;
      if (token != null) {
        await tokenService.saveAccessToken(token);
      }
      if (refreshToken != null) {
        await tokenService.saveRefreshToken(refreshToken);
      }
      final user = UserModel.fromJson(
        result['user'] as Map<String, dynamic>,
      );
      return Right(user);
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(
        NetworkFailure(message: 'No internet connection'),
      );
    }
    try {
      final result = await remoteDataSource.register(
        name: name,
        email: email,
        password: password,
      );
      final token = result['token'] as String?;
      final refreshToken = result['refreshToken'] as String?;
      if (token != null) {
        await tokenService.saveAccessToken(token);
      }
      if (refreshToken != null) {
        await tokenService.saveRefreshToken(refreshToken);
      }
      final user = UserModel.fromJson(
        result['user'] as Map<String, dynamic>,
      );
      return Right(user);
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      await tokenService.clearTokens();
      return const Right(null);
    } on Exception catch (_) {
      await tokenService.clearTokens();
      return const Right(null);
    }
  }
}
