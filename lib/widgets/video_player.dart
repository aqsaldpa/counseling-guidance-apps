import 'dart:async';

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
  bool showControls = true;

  // Auto-hide controls after a few seconds
  Timer? _hideControlsTimer;

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

  void _resetHideControlsTimer() {
    _hideControlsTimer?.cancel();
    setState(() {
      showControls = true;
    });
    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && controller.value.isPlaying) {
        setState(() {
          showControls = false;
        });
      }
    });
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
        _resetHideControlsTimer();

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
          showControls = true;
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
    _hideControlsTimer?.cancel();
    controller.removeListener(videoPlayerListener);
    controllerManager.unregisterController(controller);
    controller.dispose();
    super.dispose();
  }

  void togglePlayPause() {
    if (controller.value.isPlaying) {
      controller.pause();
      setState(() {
        showControls = true;
      });
      _hideControlsTimer?.cancel();
    } else {
      if (isCompleted) {
        controller.seekTo(Duration.zero);
        setState(() {
          isCompleted = false;
        });
      }
      controller.play();
      controllerManager.pauseAllExcept(controller);
      _resetHideControlsTimer();
    }
  }

  String formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    if (hasError) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
              SizedBox(height: 16),
              Text(
                'Tidak dapat memutar video',
                style: TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (!isInitialized) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        // Video player
        AspectRatio(
          aspectRatio: controller.value.aspectRatio,
          child: VideoPlayer(controller),
        ),

        // Tap area for showing/hiding controls
        Positioned.fill(
          child: GestureDetector(
            onTap: () {
              setState(() {
                showControls = !showControls;
                if (showControls) {
                  _resetHideControlsTimer();
                } else {
                  _hideControlsTimer?.cancel();
                }
              });
            },
            behavior: HitTestBehavior.translucent,
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),

        // Center play/pause button
        if (showControls || !controller.value.isPlaying)
          AnimatedOpacity(
            opacity: showControls ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: GestureDetector(
              onTap: togglePlayPause,
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black38,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                  size: 40,
                  color: Colors.white,
                ),
              ),
            ),
          ),

        // Buffering indicator
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

        // Bottom controls overlay
        if (showControls)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedOpacity(
              opacity: showControls ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
                padding: const EdgeInsets.only(top: 30, bottom: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Progress slider
                    SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 4,
                        thumbShape:
                            const RoundSliderThumbShape(enabledThumbRadius: 6),
                        overlayShape:
                            const RoundSliderOverlayShape(overlayRadius: 14),
                        thumbColor: Colors.white,
                        activeTrackColor: Colors.red.shade600,
                        inactiveTrackColor: Colors.white.withOpacity(0.3),
                        overlayColor: Colors.red.shade200.withOpacity(0.4),
                      ),
                      child: Slider(
                        value:
                            controller.value.position.inMilliseconds.toDouble(),
                        min: 0,
                        max:
                            controller.value.duration.inMilliseconds.toDouble(),
                        onChanged: (value) {
                          final newPosition =
                              Duration(milliseconds: value.toInt());
                          controller.seekTo(newPosition);
                        },
                      ),
                    ),

                    // Time and controls row
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          // Current position
                          Text(
                            formatDuration(controller.value.position),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          const Spacer(),

                          // Duration
                          Text(
                            formatDuration(controller.value.duration),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
