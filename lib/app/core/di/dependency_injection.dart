import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:social_academic/app/core/auth/auth_notifier.dart';
import 'package:social_academic/app/core/di/course_providers.dart';
import 'package:social_academic/app/core/di/mini_course_providers.dart';
import 'package:social_academic/app/core/di/auth_providers.dart';
import 'package:social_academic/app/core/di/post_providers.dart';
import 'package:social_academic/app/core/theme/theme_notifier.dart';
import 'package:social_academic/features/authentication/domain/usecases/login.dart';
import 'package:social_academic/features/authentication/domain/usecases/send_password_reset_email.dart';
import 'package:social_academic/features/authentication/domain/usecases/update_user.dart';
import 'package:social_academic/features/authentication/presentation/provider/user_notifier.dart';
import 'package:social_academic/features/authentication/presentation/provider/login_change_notifier.dart';
import 'package:social_academic/features/profile/presentation/providers/edit_profile_change_notifier.dart';
import 'package:social_academic/main.dart';

List<SingleChildWidget> get allProviders => [
      // Dependências Externas e Globais
      Provider<FirebaseAuth>.value(value: auth),
      Provider<Dio>.value(value: dio),

      // Providers por Feature
      ...authProviders,
      ...postProviders,
      ...courseProviders,
      ...miniCourseProviders,
      
      // Notifiers Globais (que dependem dos providers acima)
      ChangeNotifierProvider<ThemeNotifier>(create: (context) => ThemeNotifier()),
      ChangeNotifierProvider<UserNotifier>(create: (context) => UserNotifier(context.read())),
      ChangeNotifierProvider<AuthNotifier>(
        create: (context) => AuthNotifier(auth, context.read<UserNotifier>()),
      ),

      // Notifiers de Página/Feature (que podem depender dos notifiers globais)
      ChangeNotifierProvider<LoginChangeNotifier>(
        create: (context) => LoginChangeNotifier(
          context.read<Login>(),
          context.read<SendPasswordResetEmail>(),
          context.read<UserNotifier>(),
        ),
      ),
      ChangeNotifierProvider<EditProfileChangeNotifier>(
        create: (context) => EditProfileChangeNotifier(context.read<UpdateUser>(), context.read<UserNotifier>()),
      ),
    ];
