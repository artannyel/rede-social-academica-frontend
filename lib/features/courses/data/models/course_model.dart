import 'package:social_academic/features/course_levels/data/models/course_level_model.dart';

import '../../domain/entities/course.dart';

/// Estende a entidade Course, adicionando a lógica de serialização (fromJson/toJson).
class CourseModel extends Course {
  const CourseModel({
    required super.id,
    required super.name,
    super.description,
    super.institutionId,
    super.courseLevelId,
    super.logoUrl,
    super.semester,
    CourseLevelModel? super.courseLevel,
    super.currentSemester,
    super.finished,
  });

  /// Converte um mapa (JSON) em um CourseModel.
  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      institutionId: json['institution_id'],
      courseLevelId: json['course_level_id'],
      logoUrl: json['logo_url'],
      semester: json['semester'],
      courseLevel: json['course_level'] != null
          ? CourseLevelModel.fromJson(json['course_level'])
          : null,
      currentSemester:
          json['pivot'] != null && json['pivot']['current_semester'] != null
          ? json['pivot']['current_semester']
          : null,
      finished: json['pivot'] != null && json['pivot']['finished'] != null
          ? json['pivot']['finished']
          : null,
    );
  }

  /// Converte o CourseModel em um mapa (JSON).
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'institution_id': institutionId,
      'course_level_id': courseLevelId,
      'logo_url': logoUrl,
      'semester': semester,
      'course_level': (courseLevel as CourseLevelModel?)?.toJson(),
      'current_semester': currentSemester,
      'finished': finished,
    };
  }
}
