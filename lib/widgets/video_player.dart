import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoControllerManager {
  static final VideoControllerManager instance =
      VideoControllerManager.internal();

  factory VideoControllerManager() {
    return instance;
  }

  VideoControllerManager.internal();

  final List<VideoPlayerController> activeControllers = [];

  void registerController(VideoPlayerController controller) {
    activeControllers.add(controller);
  }

  void unregisterController(VideoPlayerController controller) {
    activeControllers.remove(controller);
  }

  void pauseAllExcept(VideoPlayerController currentController) {
    for (var controller in activeControllers) {
      if (controller != currentController && controller.value.isPlaying) {
        controller.pause();
      }
    }
  }

  void pauseAll() {
    for (var controller in activeControllers) {
      if (controller.value.isPlaying) {
        controller.pause();
      }
    }
  }

  void disposeAll() {
    for (var controller in List.from(activeControllers)) {
      controller.dispose();
      activeControllers.remove(controller);
    }
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final String captionText;
  final VoidCallback? onVideoComplete;

  const VideoPlayerWidget({
    Key? key,
    required this.videoUrl,
    required this.captionText,
    this.onVideoComplete,
  }) : super(key: key);

  @override
  State<VideoPlayerWidget> createState() => VideoPlayerWidgetState();
}

class VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController controller;
  final VideoControllerManager controllerManager = VideoControllerManager();
  bool isInitialized = false;
  bool isBuffering = false;
  bool hasError = false;
  double loadingProgress = 0.0;
  bool isCompleted = false;

  @override
  void initState() {
    super.initState();
    initializeVideoPlayer();
  }

  @override
  void didUpdateWidget(VideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.videoUrl != oldWidget.videoUrl) {
      controller.removeListener(videoPlayerListener);
      controllerManager.unregisterController(controller);
      controller.dispose();

      isInitialized = false;
      isBuffering = false;
      hasError = false;
      loadingProgress = 0.0;
      isCompleted = false;

      initializeVideoPlayer();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future<void> initializeVideoPlayer() async {
    try {
      debugPrint('Initializing player with URL: ${widget.videoUrl}');

      controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: false,
          allowBackgroundPlayback: false,
        ),
      );

      controllerManager.registerController(controller);
      controller.addListener(videoPlayerListener);
      await controller.initialize();

      if (mounted) {
        await controller.play();
        controllerManager.pauseAllExcept(controller);

        setState(() {
          isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Error initializing video player: $e');
      if (mounted) {
        setState(() {
          hasError = true;
        });
      }
    }
  }

  void videoPlayerListener() {
    if (!mounted) return;

    final currentIsBuffering = controller.value.isBuffering;
    final position = controller.value.position;
    final duration = controller.value.duration;

    if (duration.inMilliseconds > 0) {
      final currentLoadingProgress = controller.value.buffered.isNotEmpty
          ? controller.value.buffered.last.end.inMilliseconds /
              duration.inMilliseconds
          : 0.0;

      if (currentLoadingProgress != loadingProgress && mounted) {
        setState(() {
          loadingProgress = currentLoadingProgress;
        });
      }
    }

    if (currentIsBuffering != isBuffering && mounted) {
      setState(() {
        isBuffering = currentIsBuffering;
      });

      if (currentIsBuffering) {
        debugPrint('Video is buffering at position: ${position.inSeconds}s');
        debugPrint('Buffered regions: ${controller.value.buffered}');
      }
    }

    if (position >= duration - const Duration(milliseconds: 300)) {
      if (!isCompleted) {
        setState(() {
          isCompleted = true;
        });

        controller.seekTo(Duration.zero);
        controller.pause();

        if (widget.onVideoComplete != null) {
          widget.onVideoComplete!();
        }
      }
    } else {
      if (isCompleted) {
        setState(() {
          isCompleted = false;
        });
      }
    }

    if (mounted && isInitialized) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    debugPrint('Disposing video player for URL: ${widget.videoUrl}');
    controller.removeListener(videoPlayerListener);
    controllerManager.unregisterController(controller);
    controller.dispose();
    super.dispose();
  }

  void togglePlayPause() {
    setState(() {
      if (controller.value.isPlaying) {
        controller.pause();
      } else {
        if (isCompleted) {
          controller.seekTo(Duration.zero);
          setState(() {
            isCompleted = false;
          });
        }
        controller.play();
        controllerManager.pauseAllExcept(controller);
      }
    });
  }

  String formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    if (hasError) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 48),
            SizedBox(height: 16),
            Text(
              'Tidak dapat memutar video',
              style: TextStyle(color: Colors.black),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (!isInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.blue),
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        AspectRatio(
          aspectRatio: controller.value.aspectRatio,
          child: VideoPlayer(controller),
        ),
        Positioned.fill(
          child: GestureDetector(
            onTap: togglePlayPause,
            child: Container(
              color: Colors.transparent,
              child: !controller.value.isPlaying
                  ? Center(
                      child: Icon(
                        Icons.play_circle_fill,
                        size: 60,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    )
                  : Container(),
            ),
          ),
        ),
        if (isBuffering)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: Colors.white),
                  const SizedBox(height: 8),
                  Text(
                    '${(loadingProgress * 100).toInt()}% Loaded',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 40,
            color: Colors.black.withOpacity(0.4),
            child: Row(
              children: [
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                  ),
                  onPressed: togglePlayPause,
                ),
                Text(
                  formatDuration(controller.value.position),
                  style: const TextStyle(color: Colors.white),
                ),
                Expanded(
                  child: SliderTheme(
                    data: const SliderThemeData(
                      trackHeight: 2,
                      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
                    ),
                    child: Slider(
                      value:
                          controller.value.position.inMilliseconds.toDouble(),
                      min: 0,
                      max: controller.value.duration.inMilliseconds.toDouble(),
                      onChanged: (value) {
                        final newPosition =
                            Duration(milliseconds: value.toInt());
                        controller.seekTo(newPosition);
                      },
                      activeColor: Colors.blue,
                      inactiveColor: Colors.grey.shade400,
                    ),
                  ),
                ),
                Text(
                  formatDuration(controller.value.duration),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
