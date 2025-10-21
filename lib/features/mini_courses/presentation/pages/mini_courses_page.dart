import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_academic/features/mini_courses/domain/usecases/get_mini_courses.dart';
import 'package:social_academic/features/mini_courses/domain/usecases/get_my_mini_courses.dart';
import 'package:social_academic/features/mini_courses/presentation/pages/mini_course_list_page.dart';
import 'package:social_academic/features/mini_courses/presentation/pages/my_mini_course_list_page.dart';
import 'package:social_academic/features/mini_courses/presentation/providers/mini_course_list_change_notifier.dart';
import 'package:social_academic/features/mini_courses/presentation/providers/my_mini_course_list_change_notifier.dart';

class MiniCoursesPage extends StatelessWidget {
  const MiniCoursesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) =>
              MiniCourseListChangeNotifier(context.read<GetMiniCourses>()),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              MyMiniCourseListChangeNotifier(context.read<GetMyMiniCourses>()),
        ),
      ],
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            toolbarHeight: 0, // Esconde a AppBar, pois a HomePage já tem uma
            bottom: const TabBar(
              tabs: [
                Tab(text: 'Todos'),
                Tab(text: 'Meus Cursos'),
              ],
            ),
          ),
          body: const TabBarView(
            children: [MiniCourseListPage(), MyMiniCourseListPage()],
          ),
        ),
      ),
    );
  }
}