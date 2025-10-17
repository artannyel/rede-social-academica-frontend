import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:social_academic/features/posts/domain/usecases/edit_post.dart';
import 'package:social_academic/features/posts/domain/usecases/like_comment.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:social_academic/features/authentication/data/datasources/auth_remote_datasource.dart';
import 'package:social_academic/app/core/auth/auth_notifier.dart';
import 'package:social_academic/app/core/navigation/app_router.dart';
import 'package:social_academic/app/core/theme/app_theme.dart';
import 'package:social_academic/features/posts/domain/usecases/force_delete_post.dart';
import 'package:social_academic/features/posts/domain/usecases/delete_post.dart';
import 'package:social_academic/app/core/theme/theme_notifier.dart';
import 'package:social_academic/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:social_academic/features/authentication/domain/usecases/get_user_profile.dart';
import 'package:social_academic/features/authentication/domain/repositories/auth_repository.dart';
import 'package:social_academic/features/authentication/domain/usecases/login.dart';
import 'package:social_academic/features/authentication/domain/usecases/register.dart';
import 'package:social_academic/features/authentication/domain/usecases/send_password_reset_email.dart';
import 'package:social_academic/features/authentication/domain/usecases/get_current_user.dart';
import 'package:social_academic/features/authentication/domain/usecases/update_user.dart';
import 'package:social_academic/features/authentication/presentation/provider/login_change_notifier.dart';
import 'package:social_academic/features/authentication/presentation/provider/user_notifier.dart';
import 'package:social_academic/features/courses/data/datasources/course_remote_datasource.dart';
import 'package:social_academic/features/courses/data/repositories/course_repository_impl.dart';
import 'package:social_academic/features/courses/domain/repositories/course_repository.dart';
import 'package:social_academic/features/courses/domain/usecases/get_courses.dart';
import 'package:social_academic/features/courses/presentation/provider/course_change_notifier.dart';
import 'package:social_academic/features/posts/data/datasources/post_remote_datasource.dart';
import 'package:social_academic/features/profile/presentation/providers/archived_posts_change_notifier.dart';
import 'package:social_academic/features/profile/presentation/providers/my_posts_change_notifier.dart';
import 'package:social_academic/features/profile/presentation/providers/edit_profile_change_notifier.dart';
import 'package:social_academic/features/posts/data/repositories/post_repository_impl.dart';
import 'package:social_academic/features/posts/domain/repositories/post_repository.dart';
import 'package:social_academic/features/posts/domain/usecases/create_post.dart';
import 'package:social_academic/features/posts/domain/usecases/create_comment.dart';
import 'package:social_academic/features/posts/domain/usecases/get_comments.dart';
import 'package:social_academic/features/posts/presentation/providers/post_change_notifier.dart';
import 'package:social_academic/features/posts/domain/usecases/like_post.dart';
import 'package:social_academic/features/posts/domain/usecases/restore_post.dart';
import 'package:social_academic/features/posts/domain/usecases/get_my_posts.dart';
import 'package:social_academic/features/posts/domain/usecases/get_posts.dart';
import 'package:social_academic/features/posts/presentation/providers/tag_change_notifier.dart';
import 'package:social_academic/features/posts/data/datasources/tag_remote_datasource.dart';
import 'package:social_academic/features/posts/data/repositories/tag_repository_impl.dart';
import 'package:social_academic/features/posts/domain/repositories/tag_repository.dart';
import 'package:social_academic/features/posts/domain/usecases/get_tags.dart';
import 'package:social_academic/features/posts/domain/usecases/get_archived_posts.dart';
import 'package:social_academic/firebase_options.dart';

late final FirebaseApp app;
late final FirebaseAuth auth;
late final Dio dio;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Carrega as variáveis de ambiente do arquivo .env
  await dotenv.load(fileName: ".env");

  // Remove o # (hash) da URL na web
  setPathUrlStrategy();

  // We store the app and auth to make testing with a named instance easier.
  app = await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  auth = FirebaseAuth.instanceFor(app: app);
  dio = Dio(
    BaseOptions(
      baseUrl: dotenv.env['BASE_URL']!,
      headers: {'Content-Type': 'application/json', 'accept': 'application/json'},
      contentType: 'application/json',
    ),
  );
  await Future.delayed(Duration(seconds: 1));

  GoRouter.optionURLReflectsImperativeAPIs = true;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Dependências Externas
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
        Provider<CourseRemoteDataSource>(
          create: (context) =>
              CourseRemoteDataSourceImpl(dio: context.read<Dio>()),
        ),
        Provider<CourseRepository>(
          create: (context) => CourseRepositoryImpl(
            remoteDataSource: context.read<CourseRemoteDataSource>(),
          ),
        ),
        Provider<PostRemoteDataSource>(
          create: (context) => PostRemoteDataSourceImpl(
            dio: context.read<Dio>(),
            firebaseAuth: context.read<FirebaseAuth>(),
          ),
        ),
        Provider<PostRepository>(
          create: (context) => PostRepositoryImpl(
            remoteDataSource: context.read<PostRemoteDataSource>(),
          ),
        ),
        Provider<TagRemoteDataSource>(
          create: (context) => TagRemoteDataSourceImpl(
            dio: context.read<Dio>(),
            firebaseAuth: context.read<FirebaseAuth>(),
          ),
        ),
        Provider<TagRepository>(
          create: (context) => TagRepositoryImpl(
            remoteDataSource: context.read<TagRemoteDataSource>(),
          ),
        ),

        // Camada de Domínio (Domain)
        Provider<Register>(
          create: (context) => Register(context.read<AuthRepository>()),
        ),
        Provider<Login>(
          create: (context) => Login(context.read<AuthRepository>()),
        ),
        Provider<SendPasswordResetEmail>(
          create: (context) =>
              SendPasswordResetEmail(context.read<AuthRepository>()),
        ),
        Provider<GetCourses>(
          create: (context) => GetCourses(context.read<CourseRepository>()),
        ),
        Provider<CreatePost>(
          create: (context) => CreatePost(context.read<PostRepository>()),
        ),
        Provider<GetPosts>(
          create: (context) => GetPosts(context.read<PostRepository>()),
        ),
        Provider<LikePost>(
          create: (context) => LikePost(context.read<PostRepository>()),
        ),
        Provider<CreateComment>(
          create: (context) => CreateComment(context.read<PostRepository>()),
        ),
        Provider<LikeComment>(
          create: (context) => LikeComment(context.read<PostRepository>()),
        ),
        Provider<GetComments>(
          create: (context) => GetComments(context.read<PostRepository>()),
        ),
        Provider<EditPost>(create: (context) => EditPost(context.read())),
        Provider<GetTags>(
          create: (context) => GetTags(context.read<TagRepository>()),
        ),
        Provider<DeletePost>(
          create: (context) => DeletePost(context.read<PostRepository>()),
        ),
        Provider<GetArchivedPosts>(
          create: (context) => GetArchivedPosts(context.read<PostRepository>()),
        ),
        Provider<RestorePost>(
          create: (context) => RestorePost(context.read<PostRepository>()),
        ),
        Provider<ForceDeletePost>(
          create: (context) => ForceDeletePost(context.read<PostRepository>()),
        ),
        Provider<GetCurrentUser>(
          create: (context) => GetCurrentUser(context.read<AuthRepository>()),
        ),
        Provider<UpdateUser>(
          create: (context) => UpdateUser(context.read<AuthRepository>()),
        ),
        Provider<GetMyPosts>(
          create: (context) => GetMyPosts(context.read<PostRepository>()),
        ),
        Provider<GetUserProfile>(
          create: (context) => GetUserProfile(context.read<AuthRepository>()),
        ),

        // Camada de Apresentação (Presentation) - Notifiers de Estado Global
        ChangeNotifierProvider<UserNotifier>(
          create: (context) => UserNotifier(context.read<GetCurrentUser>()),
        ),
        ChangeNotifierProvider<AuthNotifier>(
          create: (context) => AuthNotifier(
            auth,
            context.read<UserNotifier>(), // AuthNotifier agora depende do UserNotifier
          ),
        ),
        ChangeNotifierProvider<ThemeNotifier>(
          create: (context) => ThemeNotifier(),
        ),

        // Notifiers de Página/Funcionalidade Específica
        ChangeNotifierProvider<CourseChangeNotifier>(
          create: (context) => CourseChangeNotifier(context.read<GetCourses>()),
        ),
        ChangeNotifierProvider<TagChangeNotifier>(
          create: (context) => TagChangeNotifier(context.read<GetTags>()),
        ),
        ChangeNotifierProvider<LoginChangeNotifier>(
          create: (context) => LoginChangeNotifier(
            context.read<Login>(),
            context.read<SendPasswordResetEmail>(),
            context.read<UserNotifier>(), // Login agora atualiza o UserNotifier
          ),
        ),
        ChangeNotifierProvider<PostChangeNotifier>(
          create: (context) => PostChangeNotifier(
            context.read<GetPosts>(),
            context.read<LikePost>(),
          ),
        ),
        ChangeNotifierProvider<EditProfileChangeNotifier>(
          create: (context) => EditProfileChangeNotifier(
            context.read<UpdateUser>(),
            context.read<UserNotifier>(),
          ),
        ),
        ChangeNotifierProvider<MyPostsChangeNotifier>(
          create: (context) => MyPostsChangeNotifier(
            context.read<GetMyPosts>(),
            context.read<LikePost>(),
            context.read<DeletePost>(),
          ),
        ),
        ChangeNotifierProvider<ArchivedPostsChangeNotifier>(
          create: (context) => ArchivedPostsChangeNotifier(
            context.read<GetArchivedPosts>(),
            context.read<RestorePost>(),
            context.read<ForceDeletePost>(),
          ),
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
