import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:social_academic/features/courses/data/datasources/course_remote_datasource.dart';
import 'package:social_academic/features/courses/data/repositories/course_repository_impl.dart';
import 'package:social_academic/features/courses/domain/repositories/course_repository.dart';
import 'package:social_academic/features/courses/domain/usecases/get_courses.dart';
import 'package:social_academic/features/courses/presentation/provider/course_change_notifier.dart';

final List<SingleChildWidget> courseProviders = [
  // Data
  Provider<CourseRemoteDataSource>(
    create: (context) => CourseRemoteDataSourceImpl(dio: context.read()),
  ),
  Provider<CourseRepository>(
    create: (context) => CourseRepositoryImpl(remoteDataSource: context.read()),
  ),
  // Domain
  Provider<GetCourses>(create: (context) => GetCourses(context.read())),
  // Presentation
  ChangeNotifierProvider<CourseChangeNotifier>(create: (context) => CourseChangeNotifier(context.read())),
];