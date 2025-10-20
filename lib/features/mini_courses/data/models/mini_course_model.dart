import 'package:social_academic/features/courses/data/models/course_model.dart';
import 'package:social_academic/features/mini_courses/domain/entities/mini_course.dart';

class MiniCourseModel extends MiniCourse {
  const MiniCourseModel({
    required super.id,
    required super.title,
    required super.description,
    super.photoUrl,
    super.courses,
  });

  factory MiniCourseModel.fromJson(Map<String, dynamic> json) {
    return MiniCourseModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      photoUrl: json['photo_url'],
      courses: json['courses'] != null
          ? (json['courses'] as List).map((e) => CourseModel.fromJson(e)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'photo_url': photoUrl,
        'courses': courses?.map((e) => (e as CourseModel).toJson()).toList(),
      };
}