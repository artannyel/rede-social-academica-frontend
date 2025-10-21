import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:social_academic/features/mini_courses/domain/entities/lesson.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart' as mobile_player;
import 'package:youtube_player_iframe/youtube_player_iframe.dart' as web_player;

class LessonPlayerPage extends StatefulWidget {
  final Lesson lesson;
  const LessonPlayerPage({super.key, required this.lesson});

  @override
  State<LessonPlayerPage> createState() => _LessonPlayerPageState();
}

class _LessonPlayerPageState extends State<LessonPlayerPage> {
  // Controlador para mobile
  mobile_player.YoutubePlayerController? _mobileController;
  // Controlador para web
  web_player.YoutubePlayerController? _webController;

  @override
  void initState() {
    super.initState();
    final videoId = mobile_player.YoutubePlayer.convertUrlToId(widget.lesson.youtubeUrl ?? '');

    if (kIsWeb) {
      _webController = web_player.YoutubePlayerController.fromVideoId(
        videoId: videoId ?? '',
        autoPlay: true,
        params: const web_player.YoutubePlayerParams(
          showControls: true,
          showFullscreenButton: true,
          enableCaption: false,
        ),
      );
    } else {
      _mobileController = mobile_player.YoutubePlayerController(
        initialVideoId: videoId ?? '',
        flags: const mobile_player.YoutubePlayerFlags(
          autoPlay: true,
          mute: false,
          forceHD: true,
        ),
      );
    }
  }

  @override
  void dispose() {
    if (!kIsWeb) {
      // Garante que o player saia do modo de tela cheia ao fechar a página.
      SystemChrome.setPreferredOrientations(DeviceOrientation.values);
      _mobileController?.dispose();
    } else {
      _webController?.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final playerWidget = kIsWeb ? _buildWebPlayer() : _buildMobilePlayer();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lesson.title),
      ),
      body: ListView(
        children: [
          playerWidget, // O widget do player de vídeo
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(widget.lesson.description, style: textTheme.bodyLarge),
          ),
        ],
      ),
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