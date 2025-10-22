import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:social_academic/features/mini_courses/domain/entities/lesson.dart';
import 'package:social_academic/features/mini_courses/domain/usecases/get_lesson_detail.dart';
import 'package:social_academic/features/mini_courses/presentation/providers/lesson_player_change_notifier.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart' as mobile_player;
import 'package:youtube_player_iframe/youtube_player_iframe.dart' as web_player;
import 'package:provider/provider.dart';

class LessonPlayerPage extends StatelessWidget {
  final String lessonId;
  const LessonPlayerPage({super.key, required this.lessonId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LessonPlayerChangeNotifier(
        context.read<GetLessonDetail>(),
        lessonId,
      ),
      child: const _LessonPlayerView(),
    );
  }
}

class _LessonPlayerView extends StatefulWidget {
  const _LessonPlayerView();

  @override
  State<_LessonPlayerView> createState() => _LessonPlayerViewState();
}

class _LessonPlayerViewState extends State<_LessonPlayerView> {
  // Controlador para mobile
  mobile_player.YoutubePlayerController? _mobileController;
  // Controlador para web
  web_player.YoutubePlayerController? _webController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LessonPlayerChangeNotifier>().fetchLessonDetail();
    });
  }

  void _initializePlayerControllers(Lesson lesson) {
    final videoId = mobile_player.YoutubePlayer.convertUrlToId(lesson.youtubeUrl ?? '');

    if (videoId == null || videoId.isEmpty) {
      // Handle case where videoId is not valid
      return;
    }

    if (_mobileController == null && !kIsWeb) {
      _mobileController = mobile_player.YoutubePlayerController(
        initialVideoId: videoId,
        flags: const mobile_player.YoutubePlayerFlags(
          autoPlay: true,
          mute: false,
          forceHD: true,
        ),
      );
    }

    if (_webController == null && kIsWeb) {
      _webController = web_player.YoutubePlayerController.fromVideoId(
        videoId: videoId,
        autoPlay: true,
        params: const web_player.YoutubePlayerParams(
          showControls: true,
          showFullscreenButton: true,
          enableCaption: false,
        ),
      );
    }
  }

  void _disposePlayerControllers() {
    _mobileController?.dispose();
    _webController?.close();
  }

  @override
  void dispose() {
    if (!kIsWeb) {
      // Garante que o player saia do modo de tela cheia ao fechar a página.
      SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    }
    _disposePlayerControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LessonPlayerChangeNotifier>(
      builder: (context, notifier, child) {
        final textTheme = Theme.of(context).textTheme;

        if (notifier.state == LessonPlayerState.loading) {
          return Scaffold(
            appBar: AppBar(title: const Text('Carregando Aula...')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (notifier.state == LessonPlayerState.error) {
          return Scaffold(
            appBar: AppBar(title: const Text('Erro')),
            body: Center(
              child: Text(notifier.errorMessage ?? 'Erro ao carregar a aula.'),
            ),
          );
        }

        if (notifier.lesson == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Aula Não Encontrada')),
            body: const Center(child: Text('Aula não encontrada.')),
          );
        }

        _initializePlayerControllers(notifier.lesson!); // Initialize controllers once lesson is loaded

        final playerWidget = kIsWeb ? _buildWebPlayer() : _buildMobilePlayer();

        return Scaffold(
          appBar: AppBar(
            title: Text(notifier.lesson!.title),
          ),
          body: ListView(
            children: [
              playerWidget, // O widget do player de vídeo
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(notifier.lesson!.description, style: textTheme.bodyLarge),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMobilePlayer() {
    if (_mobileController == null) return const SizedBox.shrink();

    return mobile_player.YoutubePlayer(
      controller: _mobileController!,
      showVideoProgressIndicator: true,
      progressIndicatorColor: Theme.of(context).colorScheme.primary,
      onReady: () => _mobileController!.addListener(() {}),
    );
  }

  Widget _buildWebPlayer() {
    if (_webController == null) return const SizedBox.shrink();

    return web_player.YoutubePlayer(
      controller: _webController!,
      aspectRatio: 16 / 9,
    );
  }
}