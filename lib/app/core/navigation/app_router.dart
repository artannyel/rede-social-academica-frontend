import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:social_academic/features/authentication/presentation/pages/login_page.dart';
import 'package:social_academic/features/authentication/presentation/pages/register_page.dart';
import 'package:social_academic/features/authentication/presentation/pages/email_verification_page.dart';
import 'package:social_academic/app/core/auth/auth_notifier.dart';
import 'package:social_academic/features/home/presentation/pages/home_page.dart';
import 'package:social_academic/features/mini_courses/presentation/pages/mini_course_detail_page.dart';
import 'package:social_academic/features/mini_courses/presentation/pages/add_lesson_page.dart';
import 'package:social_academic/features/mini_courses/presentation/pages/lesson_player_page.dart';
import 'package:social_academic/features/mini_courses/presentation/pages/mini_courses_page.dart';
import 'package:social_academic/features/posts/presentation/pages/create_post_page.dart';
import 'package:social_academic/features/mini_courses/presentation/pages/create_mini_course_page.dart';
import 'package:social_academic/features/posts/domain/entities/post.dart';
import 'package:social_academic/features/posts/presentation/pages/edit_post_page.dart';
import 'package:social_academic/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:social_academic/features/profile/presentation/pages/profile_page_provider.dart';
import 'package:social_academic/features/posts/presentation/pages/post_list_page.dart';
import 'package:social_academic/features/profile/presentation/pages/user_profile_page.dart';
import 'package:social_academic/features/splash/presentation/pages/splash_page.dart';

GoRouter appRouter(AuthNotifier authNotifier) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable:
        authNotifier, // Faz o router reavaliar a rota quando o estado de auth mudar
    redirect: (BuildContext context, GoRouterState state) {
      final user = authNotifier.user;
      final bool isLoggedIn = user != null;
      final bool isEmailVerified = user?.emailVerified ?? false;

      final String location = state.matchedLocation;

      final bool isSplashRoute = location == '/';
      final bool isAuthRoute = location == '/login' || location == '/register';
      final bool isVerifying = location == '/verify-email';

      // Se o usuário NÃO está logado e está tentando acessar uma rota protegida,
      // redireciona para o login.
      // Se o usuário não está logado e não está em uma rota de autenticação, mande-o para o login.
      if (!isLoggedIn && !isAuthRoute) {
        return '/login';
      }

      // Se o usuário ESTÁ logado e está tentando acessar as rotas de login/cadastro,
      // redireciona para a home.
      if (isLoggedIn) {
        // Se o usuário está logado e na splash screen, redireciona para o lugar certo.
        if (isSplashRoute) {
          return isEmailVerified ? '/posts' : '/verify-email';
        }

        // Se o e-mail não foi verificado e ele não está na tela de verificação, redirecione-o.
        if (!isEmailVerified && !isVerifying) {
          return '/verify-email';
        }
        // Se o e-mail foi verificado e ele está em uma rota de autenticação/verificação, mande-o para a home.
        if (isEmailVerified && (isAuthRoute || isVerifying)) {
          return '/posts';
        }
      }

      // Em todos os outros casos, permite a navegação.
      return null;
    },
    routes: [
      // Rota inicial que exibe a splash screen
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),

      // Rota principal que contém a navegação por abas
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return HomePage(navigationShell: navigationShell);
        },
        branches: [
          // Ramo 1: Posts
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/posts',
                name: 'home',
                builder: (context, state) => const PostListPage(),
                routes: [
                  GoRoute(
                    path: 'create',
                    name: 'create-post',
                    pageBuilder: (context, state) {
                      return CustomTransitionPage(
                        key: state.pageKey,
                        child: const CreatePostPage(),
                        transitionsBuilder: _slideUpTransition,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          // Ramo 2: Mini Cursos
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/mini-courses',
                name: 'mini-courses',
                builder: (context, state) => const MiniCoursesPage(),
                routes: [
                  GoRoute(
                    path: 'create',
                    name: 'create-mini-course',
                    pageBuilder: (context, state) {
                      return CustomTransitionPage(
                        key: state.pageKey,
                        child: const CreateMiniCoursePage(),
                        transitionsBuilder: _slideUpTransition,
                      );
                    },
                  ),
                  GoRoute(
                    path: ':id',
                    name: 'mini-course-detail',
                    builder: (context, state) {
                      final miniCourseId = state.pathParameters['id']!;
                      return MiniCourseDetailPage(miniCourseId: miniCourseId);
                    },
                    routes: [
                      GoRoute(
                        path: 'add-lesson',
                        name: 'add-lesson',
                        pageBuilder: (context, state) {
                          final miniCourseId = state.pathParameters['id']!;
                          return CustomTransitionPage(
                            key: state.pageKey,
                            child: AddLessonPage(miniCourseId: miniCourseId),
                            transitionsBuilder: _slideUpTransition,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'lessons/:lessonId/player',
                        name: 'lesson-player',
                        pageBuilder: (context, state) {
                          final lessonId = state.pathParameters['lessonId']!;
                          return CustomTransitionPage(
                            key: state.pageKey,
                            child: LessonPlayerPage(lessonId: lessonId),
                            transitionsBuilder: _slideUpTransition,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),

      // Rotas que são exibidas SOBRE a navegação principal
      GoRoute(
        path: '/posts/:id/edit',
        name: 'edit-post',
        pageBuilder: (context, state) {
          final post = state.extra as Post;
          return CustomTransitionPage(
            key: state.pageKey,
            child: EditPostPage(post: post),
            transitionsBuilder: _slideUpTransition,
          );
        },
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const ProfilePageProvider(),
            transitionsBuilder: _slideRightToLeftTransition,
          );
        },
      ),
      GoRoute(
        path: '/users/:id',
        name: 'user-profile',
        pageBuilder: (context, state) {
          final userId = state.pathParameters['id']!;
          return CustomTransitionPage(
            key: state.pageKey,
            child: UserProfilePage(userId: userId),
            transitionsBuilder: _slideRightToLeftTransition,
          );
        },
      ),
      GoRoute(
        path: '/profile/edit',
        name: 'edit-profile',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const EditProfilePage(),
            transitionsBuilder: _slideUpTransition,
          );
        },
      ),
      // Rotas de autenticação
      GoRoute(
        path: '/login',
        name: 'login',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const LoginPage(),
            transitionsBuilder: _slideLeftToRightTransition,
          );
        },
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const RegisterPage(),
            transitionsBuilder: _slideRightToLeftTransition,
          );
        },
      ),
      GoRoute(
        path: '/verify-email',
        name: 'verify-email',
        builder: (context, state) => const EmailVerificationPage(),
      ),
    ],
  );
}

Widget _slideUpTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  const begin = Offset(0.0, 1.0);
  const end = Offset.zero;
  final tween = Tween(
    begin: begin,
    end: end,
  ).chain(CurveTween(curve: Curves.easeInOut));
  return SlideTransition(position: animation.drive(tween), child: child);
}

Widget _slideRightToLeftTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  const begin = Offset(1.0, 0.0);
  const end = Offset.zero;
  final tween = Tween(
    begin: begin,
    end: end,
  ).chain(CurveTween(curve: Curves.easeInOut));
  return SlideTransition(position: animation.drive(tween), child: child);
}

Widget _slideLeftToRightTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  const begin = Offset(-1.0, 0.0);
  const end = Offset.zero;
  final tween = Tween(
    begin: begin,
    end: end,
  ).chain(CurveTween(curve: Curves.easeInOut));
  return SlideTransition(position: animation.drive(tween), child: child);
}
