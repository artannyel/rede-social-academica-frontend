import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:social_academic/features/authentication/presentation/pages/login_page.dart';
import 'package:social_academic/features/authentication/presentation/pages/register_page.dart';
import 'package:social_academic/features/authentication/presentation/pages/email_verification_page.dart';
import 'package:social_academic/app/core/auth/auth_notifier.dart';
import 'package:social_academic/features/home/presentation/pages/home_page.dart';
import 'package:social_academic/features/posts/presentation/pages/create_post_page.dart';

GoRouter appRouter(AuthNotifier authNotifier) {
  return GoRouter(
    initialLocation: '/login',
    refreshListenable:
        authNotifier, // Faz o router reavaliar a rota quando o estado de auth mudar
    redirect: (BuildContext context, GoRouterState state) {
      final user = authNotifier.user;
      final bool isLoggedIn = user != null;
      final bool isEmailVerified = user?.emailVerified ?? false;

      final String location = state.matchedLocation;

      final bool isAuthRoute = location == '/login' || location == '/register';
      final bool isVerifying = location == '/verify-email';

      debugPrint(
        'isLoggedIn: $isLoggedIn, isEmailVerified: $isEmailVerified, location: $location',
      );

      // Se o usuário NÃO está logado e está tentando acessar uma rota protegida,
      // redireciona para o login.
      if (!isLoggedIn && !isAuthRoute && !isVerifying) {
        debugPrint('Redirecionando para /login');
        return '/login';
      }

      // Se o usuário ESTÁ logado e está tentando acessar as rotas de login/cadastro,
      // redireciona para a home.
      if (isLoggedIn) {
        // Se o e-mail não foi verificado e ele não está na tela de verificação, redirecione-o.
        if (!isEmailVerified && !isVerifying) {
          return '/verify-email';
        }
        // Se o e-mail foi verificado e ele está em uma rota de autenticação/verificação, mande-o para a home.
        if (isEmailVerified && (isAuthRoute || isVerifying)) {
          return '/home';
        }
      }

      // Em todos os outros casos, permite a navegação.
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        name: 'root',
        builder: (context, state) => Center(child: CircularProgressIndicator()),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const LoginPage(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  // Animação de slide da esquerda para a direita
                  const begin = Offset(-1.0, 0.0);
                  const end = Offset.zero;
                  final tween = Tween(
                    begin: begin,
                    end: end,
                  ).chain(CurveTween(curve: Curves.easeInOut));
                  return SlideTransition(
                    position: animation.drive(tween),
                    child: child,
                  );
                },
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
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  // Animação de slide da direita para a esquerda
                  const begin = Offset(1.0, 0.0);
                  const end = Offset.zero;
                  final tween = Tween(
                    begin: begin,
                    end: end,
                  ).chain(CurveTween(curve: Curves.easeInOut));
                  return SlideTransition(
                    position: animation.drive(tween),
                    child: child,
                  );
                },
          );
        },
      ),
      GoRoute(
        path: '/verify-email',
        name: 'verify-email',
        builder: (context, state) => const EmailVerificationPage(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/posts/create',
        name: 'create-post',
        builder: (context, state) => const CreatePostPage(),
      ),
    ],
  );
}
