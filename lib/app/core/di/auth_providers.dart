import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:social_academic/features/authentication/data/datasources/auth_remote_datasource.dart';
import 'package:social_academic/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:social_academic/features/authentication/domain/repositories/auth_repository.dart';
import 'package:social_academic/features/authentication/domain/usecases/get_current_user.dart';
import 'package:social_academic/features/authentication/domain/usecases/get_user_profile.dart';
import 'package:social_academic/features/authentication/domain/usecases/get_user_ratings.dart';
import 'package:social_academic/features/authentication/domain/usecases/login.dart';
import 'package:social_academic/features/authentication/domain/usecases/rate_user.dart';
import 'package:social_academic/features/authentication/domain/usecases/register.dart';
import 'package:social_academic/features/authentication/domain/usecases/send_password_reset_email.dart';
import 'package:social_academic/features/authentication/domain/usecases/update_user.dart';

final List<SingleChildWidget> authProviders = [
  // Data
  Provider<AuthRemoteDataSource>(
    create: (context) => AuthRemoteDataSourceImpl(
      firebaseAuth: context.read(),
      dio: context.read(),
    ),
  ),
  Provider<AuthRepository>(
    create: (context) => AuthRepositoryImpl(
      remoteDataSource: context.read<AuthRemoteDataSource>(),
    ),
  ),
  // Domain
  Provider<Register>(create: (context) => Register(context.read<AuthRepository>())),
  Provider<Login>(create: (context) => Login(context.read<AuthRepository>())),
  Provider<SendPasswordResetEmail>(create: (context) => SendPasswordResetEmail(context.read<AuthRepository>())),
  Provider<GetCurrentUser>(create: (context) => GetCurrentUser(context.read<AuthRepository>())),
  Provider<UpdateUser>(create: (context) => UpdateUser(context.read<AuthRepository>())),
  Provider<GetUserProfile>(create: (context) => GetUserProfile(context.read<AuthRepository>())),
  Provider<RateUser>(create: (context) => RateUser(context.read<AuthRepository>())),
  Provider<GetUserRatings>(create: (context) => GetUserRatings(context.read<AuthRepository>())),
];