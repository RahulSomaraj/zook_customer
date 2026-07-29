import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';
import '../datasources/google_auth_data_source.dart';
import '../models/auth_user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final GoogleAuthDataSource googleAuthDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.googleAuthDataSource,
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
      return Left(ServerFailure(e.message, e.retryAfterSeconds));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, AuthUser>> signInWithGoogle() async {
    try {
      final supabaseToken = await googleAuthDataSource.signIn();
      if (supabaseToken == null) {
        // User cancelled the account picker — not an error worth alerting.
        return const Left(AuthFailure('Sign-in cancelled.'));
      }
      final user = await remoteDataSource.socialGoogle(supabaseToken);
      if (user.accessToken != null) {
        await localDataSource.saveTokens(
          accessToken: user.accessToken!,
          refreshToken: user.refreshToken,
        );
      }
      await localDataSource.saveUser(user.toJson());
      return Right(user);
    } on ServerException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (_) {
      return const Left(AuthFailure('Google sign-in failed. Try again.'));
    }
  }

  @override
  Future<Either<Failure, String?>> sendPhoneAttachOtp(
      String phoneNumber) async {
    try {
      final devCode = await remoteDataSource.sendPhoneAttachOtp(phoneNumber);
      return Right(devCode);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.retryAfterSeconds));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> verifyPhoneAttach({
    required String phoneNumber,
    required String otp,
  }) async {
    try {
      await remoteDataSource.verifyPhoneAttach(phone: phoneNumber, code: otp);
      // Reflect the newly attached phone in the cached profile so gates that
      // read the local user (e.g. checkout) see it immediately.
      final cached = localDataSource.cachedUser;
      if (cached != null) {
        await localDataSource
            .saveUser({...cached, 'phoneNumber': phoneNumber});
      }
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (_) {
      return const Left(AuthFailure());
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
      // Cache the profile so the greeting/avatar survive app relaunches.
      await localDataSource.saveUser(user.toJson());
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
  AuthUser? get currentUser {
    if (!localDataSource.isLoggedIn) return null;
    final json = localDataSource.cachedUser;
    if (json == null) return null;
    return AuthUserModel.fromJson(json);
  }

  @override
  Future<void> logout() => localDataSource.clear();
}
