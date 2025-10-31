import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:social_academic/app/core/auth/auth_notifier.dart';
import 'package:social_academic/app/core/di/dependency_injection.dart';
import 'package:social_academic/app/core/navigation/app_router.dart';
import 'package:social_academic/app/core/theme/app_theme.dart';
import 'package:social_academic/app/core/theme/theme_notifier.dart';
import 'package:social_academic/firebase_options.dart';

late final FirebaseApp app;
late final FirebaseAuth auth;
late final Dio dio;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // A variável de ambiente BASE_URL agora é fornecida via --dart-define
  const baseUrl = String.fromEnvironment('BASE_URL');

  // Remove o # (hash) da URL na web
  setPathUrlStrategy();

  // We store the app and auth to make testing with a named instance easier.
  app = await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  auth = FirebaseAuth.instanceFor(app: app);
  dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      headers: {'Content-Type': 'application/json', 'accept': 'application/json'},
      contentType: 'application/json',
    ),
  );
  
  GoRouter.optionURLReflectsImperativeAPIs = true;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: allProviders,
      // Usamos um Consumer para obter um `context` que está abaixo do MultiProvider
      // e, assim, ter acesso ao AuthNotifier.
      child: Consumer<AuthNotifier>(
        builder: (context, authNotifier, _) {
          final themeNotifier = Provider.of<ThemeNotifier>(context);
          return MaterialApp.router(
            routerConfig: appRouter(authNotifier),
            debugShowCheckedModeBanner: false,
            title: 'Social Academic',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeNotifier.themeMode,
          );
        },
      ),
    );
  }
}
