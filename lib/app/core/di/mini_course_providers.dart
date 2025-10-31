import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:social_academic/features/mini_courses/data/datasources/mini_course_remote_datasource.dart';
import 'package:social_academic/features/mini_courses/data/repositories/mini_course_repository_impl.dart';
import 'package:social_academic/features/mini_courses/domain/repositories/mini_course_repository.dart';
import 'package:social_academic/features/mini_courses/domain/usecases/add_lesson_to_mini_course.dart';
import 'package:social_academic/features/mini_courses/domain/usecases/create_mini_course.dart';
import 'package:social_academic/features/mini_courses/domain/usecases/enroll_mini_course.dart';
import 'package:social_academic/features/mini_courses/domain/usecases/get_lesson_detail.dart';
import 'package:social_academic/features/mini_courses/domain/usecases/get_mini_course_detail.dart';
import 'package:social_academic/features/mini_courses/domain/usecases/get_mini_courses.dart';
import 'package:social_academic/features/mini_courses/domain/usecases/get_my_mini_courses.dart';
import 'package:social_academic/features/mini_courses/domain/usecases/publish_mini_course.dart';

final List<SingleChildWidget> miniCourseProviders = [
  // Data
  Provider<MiniCourseRemoteDataSource>(
    create: (context) => MiniCourseRemoteDataSourceImpl(dio: context.read(), firebaseAuth: context.read()),
  ),
  Provider<MiniCourseRepository>(
    create: (context) => MiniCourseRepositoryImpl(remoteDataSource: context.read()),
  ),
  // Domain
  Provider<CreateMiniCourse>(create: (context) => CreateMiniCourse(context.read())),
  Provider<GetMiniCourses>(create: (context) => GetMiniCourses(context.read())),
  Provider<GetMyMiniCourses>(create: (context) => GetMyMiniCourses(context.read())),
  Provider<EnrollMiniCourse>(create: (context) => EnrollMiniCourse(context.read())),
  Provider<GetMiniCourseDetail>(create: (context) => GetMiniCourseDetail(context.read())),
  Provider<PublishMiniCourse>(create: (context) => PublishMiniCourse(context.read())),
  Provider<AddLessonToMiniCourse>(create: (context) => AddLessonToMiniCourse(context.read())),
  Provider<GetLessonDetail>(create: (context) => GetLessonDetail(context.read())),
];