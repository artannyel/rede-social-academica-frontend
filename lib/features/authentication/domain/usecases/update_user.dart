import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_academic/app/core/error/failure.dart';
import 'package:social_academic/features/authentication/domain/entities/user.dart';
import 'package:social_academic/features/authentication/domain/repositories/auth_repository.dart';

class UpdateUser {
  final AuthRepository repository;

  UpdateUser(this.repository);

  Future<Either<Failure, User>> call({
    required String name,
    String? bio,
    List<Map<String, dynamic>>? userCourses,
    XFile? photo,
    bool removePhoto = false,
  }) async {
    return await repository.updateUser(
      name: name,
      bio: bio,
      userCourses: userCourses,
      photo: photo,
      removePhoto: removePhoto,
    );
  }
}