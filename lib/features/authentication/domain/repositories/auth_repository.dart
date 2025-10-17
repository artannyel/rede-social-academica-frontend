import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_academic/app/core/error/failure.dart';
import 'package:social_academic/features/authentication/domain/entities/user.dart';
import 'package:social_academic/features/authentication/domain/entities/user_profile.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, User>> register({
    required String name,
    required String email,
    required String password,
    List<Map<String, dynamic>>? userCourses,
    String? bio,
    XFile? photo,
  });

  Future<Either<Failure, User>> updateUser({
    required String name,
    String? bio,
    List<Map<String, dynamic>>? userCourses,
    XFile? photo,
    bool removePhoto,
  });

  Future<Either<Failure, void>> sendPasswordResetEmail({required String email});
  Future<Either<Failure, User>> getCurrentUser();
  Future<Either<Failure, UserProfile>> getUserProfile({
    required String userId,
    required int page,
  });
}