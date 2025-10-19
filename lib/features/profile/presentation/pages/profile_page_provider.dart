import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_academic/features/profile/domain/usecases/get_made_ratings.dart';
import 'package:social_academic/features/profile/domain/usecases/get_received_ratings.dart';
import 'package:social_academic/features/profile/presentation/pages/profile_page.dart';
import 'package:social_academic/features/profile/presentation/providers/archived_posts_change_notifier.dart';
import 'package:social_academic/features/profile/presentation/providers/made_ratings_change_notifier.dart';
import 'package:social_academic/features/profile/presentation/providers/my_posts_change_notifier.dart';
import 'package:social_academic/features/profile/presentation/providers/received_ratings_change_notifier.dart';

class ProfilePageProvider extends StatelessWidget {
  const ProfilePageProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => MyPostsChangeNotifier(
              context.read(), context.read(), context.read()),
        ),
        ChangeNotifierProvider(
          create: (context) => ArchivedPostsChangeNotifier(
              context.read(), context.read(), context.read()),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              MadeRatingsChangeNotifier(GetMadeRatings(context.read())),
        ),
        ChangeNotifierProvider(
            create: (context) =>
                ReceivedRatingsChangeNotifier(GetReceivedRatings(context.read()))),
      ],
      child: const ProfilePage(),
    );
  }
}