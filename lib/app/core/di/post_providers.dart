import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:social_academic/features/posts/data/datasources/post_remote_datasource.dart';
import 'package:social_academic/features/posts/data/datasources/tag_remote_datasource.dart';
import 'package:social_academic/features/posts/data/repositories/post_repository_impl.dart';
import 'package:social_academic/features/posts/data/repositories/tag_repository_impl.dart';
import 'package:social_academic/features/posts/domain/repositories/post_repository.dart';
import 'package:social_academic/features/posts/domain/repositories/tag_repository.dart';
import 'package:social_academic/features/posts/domain/usecases/create_comment.dart';
import 'package:social_academic/features/posts/domain/usecases/create_post.dart';
import 'package:social_academic/features/posts/domain/usecases/delete_post.dart';
import 'package:social_academic/features/posts/domain/usecases/edit_post.dart';
import 'package:social_academic/features/posts/domain/usecases/force_delete_post.dart';
import 'package:social_academic/features/posts/domain/usecases/get_archived_posts.dart';
import 'package:social_academic/features/posts/domain/usecases/get_comments.dart';
import 'package:social_academic/features/posts/domain/usecases/get_my_posts.dart';
import 'package:social_academic/features/posts/domain/usecases/get_post_by_id.dart';
import 'package:social_academic/features/posts/domain/usecases/get_posts.dart';
import 'package:social_academic/features/posts/domain/usecases/get_tags.dart';
import 'package:social_academic/features/posts/domain/usecases/like_comment.dart';
import 'package:social_academic/features/posts/domain/usecases/like_post.dart';
import 'package:social_academic/features/posts/domain/usecases/restore_post.dart';
import 'package:social_academic/features/posts/presentation/providers/post_change_notifier.dart';
import 'package:social_academic/features/posts/presentation/providers/tag_change_notifier.dart';

final List<SingleChildWidget> postProviders = [
  // Data
  Provider<PostRemoteDataSource>(
    create: (context) => PostRemoteDataSourceImpl(dio: context.read(), firebaseAuth: context.read()),
  ),
  Provider<PostRepository>(
    create: (context) => PostRepositoryImpl(remoteDataSource: context.read<PostRemoteDataSource>()),
  ),
  Provider<TagRemoteDataSource>(
    create: (context) => TagRemoteDataSourceImpl(dio: context.read(), firebaseAuth: context.read()),
  ),
  Provider<TagRepository>(
    create: (context) => TagRepositoryImpl(remoteDataSource: context.read<TagRemoteDataSource>()),
  ),
  // Domain
  Provider<CreatePost>(create: (context) => CreatePost(context.read<PostRepository>())),
  Provider<GetPosts>(create: (context) => GetPosts(context.read<PostRepository>())),
  Provider<LikePost>(create: (context) => LikePost(context.read<PostRepository>())),
  Provider<CreateComment>(create: (context) => CreateComment(context.read<PostRepository>())),
  Provider<LikeComment>(create: (context) => LikeComment(context.read<PostRepository>())),
  Provider<GetComments>(create: (context) => GetComments(context.read<PostRepository>())),
  Provider<GetPostById>(create: (context) => GetPostById(context.read<PostRepository>())),
  Provider<EditPost>(create: (context) => EditPost(context.read())),
  Provider<GetTags>(create: (context) => GetTags(context.read<TagRepository>())),
  Provider<DeletePost>(create: (context) => DeletePost(context.read<PostRepository>())),
  Provider<GetArchivedPosts>(create: (context) => GetArchivedPosts(context.read<PostRepository>())),
  Provider<RestorePost>(create: (context) => RestorePost(context.read<PostRepository>())),
  Provider<ForceDeletePost>(create: (context) => ForceDeletePost(context.read<PostRepository>())),
  Provider<GetMyPosts>(create: (context) => GetMyPosts(context.read<PostRepository>())),
  // Presentation
  ChangeNotifierProvider<PostChangeNotifier>(
    create: (context) => PostChangeNotifier(context.read<GetPosts>(), context.read<LikePost>()),
  ),
  ChangeNotifierProvider<TagChangeNotifier>(
    create: (context) => TagChangeNotifier(context.read<GetTags>()),
  ),
];