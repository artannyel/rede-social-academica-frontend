import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import 'package:social_academic/features/mini_courses/domain/usecases/get_mini_courses.dart';
import 'package:social_academic/features/mini_courses/presentation/providers/mini_course_list_change_notifier.dart';
import 'package:social_academic/features/mini_courses/presentation/widgets/mini_course_card.dart';
import 'package:social_academic/features/mini_courses/presentation/widgets/mini_course_card_skeleton.dart';

class MiniCourseListPage extends StatelessWidget {
  const MiniCourseListPage({super.key}); 

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MiniCourseListChangeNotifier(context.read<GetMiniCourses>()), 
      child: const _MiniCourseListView(),
    );
  }
}

class _MiniCourseListView extends StatefulWidget {
  const _MiniCourseListView();

  @override
  State<_MiniCourseListView> createState() => _MiniCourseListViewState();
}

class _MiniCourseListViewState extends State<_MiniCourseListView> with AutomaticKeepAliveClientMixin {
  final _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Garante que o contexto ainda é válido
      if (mounted) {
        // Só busca se a lista estiver vazia, para não recarregar ao trocar de aba
        final notifier = context.read<MiniCourseListChangeNotifier>();
        if (notifier.miniCourses.isEmpty) {
          notifier.fetchInitialMiniCourses();
        }
        // Adiciona o listener para o scroll infinito
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
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      // Garante que o contexto ainda é válido antes de ler o provider
      if (mounted) context.read<MiniCourseListChangeNotifier>().fetchMoreMiniCourses();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Necessário para o AutomaticKeepAliveClientMixin
    return Consumer<MiniCourseListChangeNotifier>(
      builder: (context, notifier, child) {
        if (notifier.state == MiniCourseListState.loadingInitial) {
          return ListView.builder(
            itemCount: 5,
            itemBuilder: (context, index) => const MiniCourseCardSkeleton(),
          );
        }
        if (notifier.state == MiniCourseListState.error &&
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
          return const Center(child: Text('Nenhum mini curso encontrado.'));
        }
        return RefreshIndicator(
          onRefresh: () => notifier.fetchInitialMiniCourses(),
          child: AnimationLimiter(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: notifier.miniCourses.length +
                  (notifier.hasMorePages ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == notifier.miniCourses.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final miniCourse = notifier.miniCourses[index];
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(
                          child: MiniCourseCard(miniCourse: miniCourse))),
                );
              },
            ),
          ),
        );
      },
    );
  }
}