import 'package:social_academic/features/course_levels/domain/entities/course_level.dart';

/// Entidade pura que representa o curso no domínio do app.
class Course {
  final String id;
  final String name;
  final String? description;
  final String? institutionId;
  final String? courseLevelId;
  final String? logoUrl;
  final int? semester;
  final CourseLevel? courseLevel;
  final int? currentSemester;
  final bool? finished;

  const Course({
    required this.id,
    required this.name,
    this.description,
    this.institutionId,
    this.courseLevelId,
    this.logoUrl,
    this.semester,
    this.courseLevel,
    this.currentSemester,
    this.finished,
  });
}
