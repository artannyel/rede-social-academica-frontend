import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:social_academic/app/core/theme/theme_notifier.dart';
import 'package:social_academic/features/authentication/presentation/provider/user_notifier.dart';
import 'package:social_academic/shared/widgets/user_avatar.dart';

class HomePage extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const HomePage({super.key, required this.navigationShell});

  // Títulos para a AppBar
  static const List<String> _appBarTitles = <String>[
    'Feed de Publicações',
    'Mini Cursos',
  ];

  void _onItemTapped(BuildContext context, int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
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

        return Scaffold(
          appBar: AppBar(
            title: Text(_appBarTitles[navigationShell.currentIndex]),
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
                      selectedIndex: navigationShell.currentIndex,
                      backgroundColor: theme.canvasColor,
                      onDestinationSelected: (index) =>
                          _onItemTapped(context, index),
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
                    Expanded(child: navigationShell),
                  ],
                )
              : navigationShell,
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
                  currentIndex: navigationShell.currentIndex,
                  onTap: (index) => _onItemTapped(context, index),
                ),
        );
      },
    );
  }
}
