import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:social_academic/features/authentication/presentation/pages/login_page.dart';
import 'package:social_academic/features/authentication/presentation/pages/register_page.dart';
import 'package:social_academic/app/core/auth/auth_notifier.dart';
import 'package:social_academic/features/home/presentation/pages/home_page.dart';

GoRouter appRouter(AuthNotifier authNotifier) {
  return GoRouter(
    initialLocation: '/login',
    refreshListenable: authNotifier, // Faz o router reavaliar a rota quando o estado de auth mudar
    redirect: (BuildContext context, GoRouterState state) {
      final bool isLoggedIn = authNotifier.user != null;
      final String location = state.matchedLocation;

      final bool isAuthRoute = location == '/login' || location == '/register';

      // Se o usuário NÃO está logado e está tentando acessar uma rota protegida,
      // redireciona para o login.
      if (!isLoggedIn && !isAuthRoute) {
        return '/login';
      }

      // Se o usuário ESTÁ logado e está tentando acessar as rotas de login/cadastro,
      // redireciona para a home.
      if (isLoggedIn && isAuthRoute) {
        return '/home';
      }

      // Em todos os outros casos, permite a navegação.
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
    ],
  );
}