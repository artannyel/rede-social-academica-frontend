import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import 'package:social_academic/features/mini_courses/presentation/providers/my_mini_course_list_change_notifier.dart';
import 'package:social_academic/features/mini_courses/presentation/widgets/mini_course_card.dart';
import 'package:social_academic/features/mini_courses/presentation/widgets/mini_course_card_skeleton.dart';

class MyMiniCourseListPage extends StatefulWidget {
  const MyMiniCourseListPage({super.key});

  @override
  State<MyMiniCourseListPage> createState() => _MyMiniCourseListPageState();
}

class _MyMiniCourseListPageState extends State<MyMiniCourseListPage>
    with AutomaticKeepAliveClientMixin {
  final _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final notifier = context.read<MyMiniCourseListChangeNotifier>();
        if (notifier.miniCourses.isEmpty) {
          notifier.fetchInitialMiniCourses();
        }
        _scrollController.addListener(_onScroll);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (mounted) {
        context.read<MyMiniCourseListChangeNotifier>().fetchMoreMiniCourses();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer<MyMiniCourseListChangeNotifier>(
      builder: (context, notifier, child) {
        if (notifier.state == MyMiniCourseListState.loadingInitial) {
          return ListView.builder(
            itemCount: 5,
            itemBuilder: (context, index) => const MiniCourseCardSkeleton(),
          );
        }
        if (notifier.state == MyMiniCourseListState.error &&
            notifier.miniCourses.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(notifier.errorMessage ?? 'Ocorreu um erro.'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => notifier.fetchInitialMiniCourses(),
                  child: const Text('Tentar Novamente'),
                ),
              ],
            ),
          );
        }
        if (notifier.miniCourses.isEmpty) {
          return const Center(child: Text('Você ainda não criou nenhum mini curso.'));
        }
        return RefreshIndicator(
          onRefresh: () => notifier.fetchInitialMiniCourses(),
          child: AnimationLimiter(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: notifier.miniCourses.length + (notifier.hasMorePages ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == notifier.miniCourses.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final miniCourse = notifier.miniCourses[index];
                return AnimationConfiguration.staggeredList(position: index, duration: const Duration(milliseconds: 375), child: SlideAnimation(verticalOffset: 50.0, child: FadeInAnimation(child: MiniCourseCard(miniCourse: miniCourse))));
              },
            ),
          ),
        );
      },
    );
  }
}