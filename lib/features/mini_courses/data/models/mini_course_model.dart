import 'package:social_academic/features/courses/data/models/course_model.dart';
import 'package:social_academic/features/authentication/data/models/user_model.dart';
import 'package:social_academic/features/mini_courses/domain/entities/mini_course.dart';

class MiniCourseModel extends MiniCourse {
  const MiniCourseModel({
    required super.id,
    required super.title,
    required super.description,
    super.photoUrl,
    super.courses,
    super.user,
    super.isEnrolled,
    super.isPublished,
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
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      isEnrolled: json['is_enrolled'] ?? false,
      isPublished: json['published'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'photo_url': photoUrl,
        'courses': courses?.map((e) => (e as CourseModel).toJson()).toList(),
        'user': user != null ? (user as UserModel).toJson() : null,
        'is_enrolled': isEnrolled,
        'published': isPublished,
      };

  MiniCourse toEntity() {
    return MiniCourse(
      id: id,
      title: title,
      description: description,
      photoUrl: photoUrl,
      courses: courses,
      user: user,
      isEnrolled: isEnrolled,
      isPublished: isPublished,
    );
  }
}