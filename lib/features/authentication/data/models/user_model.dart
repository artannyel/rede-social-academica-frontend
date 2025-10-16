import 'package:social_academic/features/courses/data/models/course_model.dart';
import '../../domain/entities/user.dart';

// Estende a entidade User, adicionando a lógica de serialização (fromJson/toJson).
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.firebaseUid,
    super.photoUrl,
    List<CourseModel>? super.courses,
    super.bio,    
  });

  // Converte um mapa (JSON) em um UserModel.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    final coursesData = json['courses'] as List<dynamic>?;
    return UserModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Usuário Anônimo',
      email: json['email'] as String? ?? '',
      firebaseUid: json['firebase_uid'] ?? '',
      bio: json['bio'],
      photoUrl: json['photo_url'],
      // Mapeia a lista de JSONs de cursos para uma lista de CourseModel
      courses: coursesData
          ?.map((courseJson) => CourseModel.fromJson(courseJson))
          .toList(),
    );
  }

  // Converte o UserModel em um mapa (JSON).
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'firebase_uid': firebaseUid,
      'bio': bio,
      'photo_url': photoUrl,
      // Mapeia a lista de CourseModel para uma lista de JSONs
      'courses': (courses as List<CourseModel>?)
          ?.map((course) => course.toJson())
          .toList(),
    };
  }
}
