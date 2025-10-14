import 'package:social_academic/features/courses/data/models/course_model.dart';
import '../../domain/entities/user.dart';

// Estende a entidade User, adicionando a lógica de serialização (fromJson/toJson).
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.firebaseUid,
    CourseModel? super.course,
  });

  // Converte um mapa (JSON) em um UserModel.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      firebaseUid: json['firebase_uid'],
      course: json['course_level'] != null
          ? CourseModel.fromJson(json['course_level'])
          : null,
    );
  }

  // Converte o UserModel em um mapa (JSON).
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'firebase_uid': firebaseUid,
      'course_level': (course as CourseModel?)?.toJson(),
    };
  }
}
