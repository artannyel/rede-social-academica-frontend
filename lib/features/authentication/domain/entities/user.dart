import 'package:social_academic/features/courses/domain/entities/course.dart';

// Entidade pura que representa o usuário no domínio do app.
class User {
  final String id;
  final String name;
  final String email;
  final String firebaseUid;
  final List<Course>? courses;
  final String? photoUrl;
  final String? bio;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.firebaseUid,
    this.photoUrl,
    this.courses,
    this.bio,
  });
}
