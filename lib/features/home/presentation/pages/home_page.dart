import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:social_academic/features/mini_courses/domain/entities/mini_course.dart';
import 'package:social_academic/features/mini_courses/presentation/providers/my_mini_course_list_change_notifier.dart';
import 'package:social_academic/features/mini_courses/presentation/providers/mini_course_list_change_notifier.dart';
import 'package:social_academic/app/core/theme/theme_notifier.dart';
import 'package:social_academic/features/authentication/presentation/provider/user_notifier.dart';
import 'package:social_academic/features/mini_courses/presentation/pages/mini_courses_page.dart';
import 'package:social_academic/features/posts/presentation/pages/post_list_page.dart';
import 'package:social_academic/shared/widgets/user_avatar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // Títulos para a AppBar
  static const List<String> _appBarTitles = <String>[
    'Feed de Publicações',
    'Mini Cursos',
  ];

  // Telas que serão exibidas
  static const List<Widget> _widgetOptions = <Widget>[
    PostListPage(),
    MiniCoursesPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        const double breakpoint = 900;
        const double breakpoint2 = 1200;

        final bool isWideScreen = constraints.maxWidth > breakpoint;
        final bool isExtraWideScreen = constraints.maxWidth > breakpoint2;

        // Lista de FloatingActionButtons que agora são construídos aqui para ter acesso ao `context`.
        final List<Widget?> floatingActionButtons = [
          FloatingActionButton(
            onPressed: () => context.push('/posts/create'),
            tooltip: 'Nova Publicação',
            child: const Icon(Icons.add),
          ),
          FloatingActionButton(
            onPressed: () async {
              final newMiniCourse = await context.push<MiniCourse>(
                '/mini-courses/create',
              );
              if (newMiniCourse != null && context.mounted) {
                // Adiciona o novo curso na lista de "Todos"
                context.read<MiniCourseListChangeNotifier>().addNewMiniCourse(
                  newMiniCourse,
                );
                // Adiciona o novo curso na lista de "Meus Cursos"
                // O `read` funciona pois o provider foi criado na MiniCoursesPage, que já está na árvore.
                context.read<MyMiniCourseListChangeNotifier>().addMiniCourse(
                  newMiniCourse,
                );
              }
            },
            tooltip: 'Novo Mini Curso',
            child: const Icon(Icons.school_outlined),
          ),
        ];

        final mainContent = IndexedStack(
          index: _selectedIndex,
          children: _widgetOptions,
        );

        return Scaffold(
          appBar: AppBar(
            title: Text(_appBarTitles[_selectedIndex]),
            actions: [
              Consumer<UserNotifier>(
                builder: (context, userNotifier, _) {
                  return GestureDetector(
                    onTap: () => context.push('/profile'),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: UserAvatar(
                        photoUrl: userNotifier.appUser?.photoUrl,
                      ),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.brightness_6),
                tooltip: 'Mudar Tema',
                onPressed: () {
                  Provider.of<ThemeNotifier>(
                    context,
                    listen: false,
                  ).toggleTheme();
                },
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Sair',
                onPressed: () {
                  Provider.of<FirebaseAuth>(context, listen: false).signOut();
                },
              ),
            ],
          ),
          body: isWideScreen
              ? Row(
                  children: [
                    NavigationRail(
                      selectedIndex: _selectedIndex,
                      backgroundColor: theme.canvasColor,
                      onDestinationSelected: _onItemTapped,
                      labelType: isExtraWideScreen
                          ? NavigationRailLabelType.none
                          : NavigationRailLabelType.all,
                      extended: isExtraWideScreen,
                      selectedIconTheme: IconThemeData(color: colorScheme.primary),
                      unselectedIconTheme: IconThemeData(color: colorScheme.onSurfaceVariant),
                      selectedLabelTextStyle: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                      unselectedLabelTextStyle: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      destinations: const <NavigationRailDestination>[
                        NavigationRailDestination(
                          icon: Icon(Icons.article_outlined),
                          label: Text('Posts'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.school_outlined),
                          label: Text('Mini Cursos'),
                        ),
                      ],
                    ),
                    const VerticalDivider(thickness: 1, width: 1),
                    Expanded(child: mainContent),
                  ],
                )
              : mainContent,
          bottomNavigationBar: isWideScreen
              ? null
              : BottomNavigationBar(
                  items: const <BottomNavigationBarItem>[
                    BottomNavigationBarItem(
                      icon: Icon(Icons.article_outlined),
                      label: 'Posts',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.school_outlined),
                      label: 'Mini Cursos',
                    ),
                  ],
                  currentIndex: _selectedIndex,
                  onTap: _onItemTapped,
                ),
          floatingActionButton: Padding(
            padding: EdgeInsets.only(right: isWideScreen ? 16.0 : 0.0),
            child: floatingActionButtons[_selectedIndex],
          ),
        );
      },
    );
  }
}
