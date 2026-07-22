import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, Unit>> register({
    required String fullName,
    required String email,
    required String countryCode,
    required String phone,
  }) async {
    try {
      await remoteDataSource.register(
        fullName: fullName,
        email: email,
        countryCode: countryCode,
        phone: phone,
      );
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, String?>> sendOtp(String phoneNumber) async {
    try {
      final devCode = await remoteDataSource.sendOtp(phoneNumber);
      return Right(devCode);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, AuthUser>> verifyOtp({
    required String phoneNumber,
    required String otp,
  }) async {
    try {
      final user = await remoteDataSource.verifyOtp(
        phone: phoneNumber,
        code: otp,
      );
      if (user.accessToken != null) {
        await localDataSource.saveTokens(
          accessToken: user.accessToken!,
          refreshToken: user.refreshToken,
        );
      }
      return Right(user);
    } on ServerException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (_) {
      return const Left(AuthFailure());
    }
  }

  @override
  bool get isLoggedIn => localDataSource.isLoggedIn;

  @override
  Future<void> logout() => localDataSource.clear();
}
