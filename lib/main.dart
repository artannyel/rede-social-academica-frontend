import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import 'package:url_strategy/url_strategy.dart';
import 'package:social_academic/features/authentication/data/datasources/auth_remote_datasource.dart';
import 'package:social_academic/app/core/auth/auth_notifier.dart';
import 'package:social_academic/app/core/navigation/app_router.dart';
import 'package:social_academic/app/core/theme/app_theme.dart';
import 'package:social_academic/app/core/theme/theme_notifier.dart';
import 'package:social_academic/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:social_academic/features/authentication/domain/repositories/auth_repository.dart';
import 'package:social_academic/features/authentication/domain/usecases/login.dart';
import 'package:social_academic/features/authentication/domain/usecases/register.dart';
import 'package:social_academic/features/authentication/presentation/provider/login_change_notifier.dart';
import 'package:social_academic/features/authentication/presentation/provider/register_change_notifier.dart';
import 'package:social_academic/firebase_options.dart';

late final FirebaseApp app;
late final FirebaseAuth auth;
late final Dio dio;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Remove o # (hash) da URL na web
  setPathUrlStrategy();

  // We store the app and auth to make testing with a named instance easier.
  app = await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  auth = FirebaseAuth.instanceFor(app: app);
  dio = Dio(BaseOptions(baseUrl: 'http://192.168.3.28:8888/api/v1'));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Dependências Externas
        // Este notifier irá ouvir as mudanças de autenticação do Firebase
        ChangeNotifierProvider<AuthNotifier>(
          create: (context) => AuthNotifier(auth),
        ),
        ChangeNotifierProvider<ThemeNotifier>(
          create: (context) => ThemeNotifier(),
        ),
        Provider<FirebaseAuth>.value(value: auth),
        Provider<Dio>.value(value: dio),

        // Camada de Dados (Data)
        Provider<AuthRemoteDataSource>(
          create: (context) => AuthRemoteDataSourceImpl(
            firebaseAuth: context.read<FirebaseAuth>(),
            dio: context.read<Dio>(),
          ),
        ),
        Provider<AuthRepository>(
          create: (context) => AuthRepositoryImpl(
            remoteDataSource: context.read<AuthRemoteDataSource>(),
          ),
        ),

        // Camada de Domínio (Domain)
        Provider<Register>(
          create: (context) => Register(context.read<AuthRepository>()),
        ),
        Provider<Login>(
          create: (context) => Login(context.read<AuthRepository>()),
        ),

        // Camada de Apresentação (Presentation)
        ChangeNotifierProvider<RegisterChangeNotifier>(
          create: (context) => RegisterChangeNotifier(context.read<Register>()),
        ),
        ChangeNotifierProvider<LoginChangeNotifier>(
          create: (context) => LoginChangeNotifier(context.read<Login>()),
        ),
      ],
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
