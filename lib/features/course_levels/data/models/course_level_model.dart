import '../../domain/entities/course_level.dart';

/// Estende a entidade CourseLevel, adicionando a lógica de serialização (fromJson/toJson).
class CourseLevelModel extends CourseLevel {
  const CourseLevelModel({
    required super.id,
    required super.name,
  });

  /// Converte um mapa (JSON) em um CourseLevelModel.
  factory CourseLevelModel.fromJson(Map<String, dynamic> json) {
    return CourseLevelModel(
      id: json['id'],
      name: json['name'],
    );
  }

  /// Converte o CourseLevelModel em um mapa (JSON).
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}