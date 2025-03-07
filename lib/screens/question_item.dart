import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:myapp/widgets/video_player.dart';

class QuestionItem extends StatefulWidget {
  final Map<String, dynamic> question;
  final int index;
  final Color categoryColor;
  final Function(int) onToggle;
  final String currentCategory;
  final int navigationCounter; // Add this field

  const QuestionItem({
    super.key,
    required this.question,
    required this.index,
    required this.categoryColor,
    required this.onToggle,
    required this.currentCategory,
    required this.navigationCounter, // Add this parameter
  });

  @override
  State<QuestionItem> createState() => _QuestionItemState();
}

class _QuestionItemState extends State<QuestionItem>
    with AutomaticKeepAliveClientMixin {
  bool isVideoPlaying = false;
  bool isVideoLoading = false;
  final VideoControllerManager _controllerManager = VideoControllerManager();
  late String _lastCategory;
  late int _lastNavigationCounter;
  @override
  void initState() {
    super.initState();
    _lastCategory = widget.currentCategory;
    _lastNavigationCounter = widget.navigationCounter;
  }

  @override
  void didUpdateWidget(QuestionItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Reset video if category changed OR navigation counter changed
    if (widget.currentCategory != _lastCategory ||
        widget.navigationCounter != _lastNavigationCounter) {
      // Reset video state
      if (isVideoPlaying) {
        _controllerManager.pauseAll();
        setState(() {
          isVideoPlaying = false;
          isVideoLoading = false;
        });
      }
      _lastCategory = widget.currentCategory;
      _lastNavigationCounter = widget.navigationCounter;
    }
  }

  @override
  bool get wantKeepAlive => true; // Keep state when scrolling

  @override
  void dispose() {
    // Ensure we pause the video when the question item is disposed
    if (isVideoPlaying) {
      _controllerManager.pauseAll();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final bool isChecked = widget.question['isChecked'] ?? false;
    final String text = widget.question['text'];
    final String videoUrl = widget.question['videoUrl'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        elevation: 0,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => widget.onToggle(widget.index),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Video thumbnail or player
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Stack(
                    children: [
                      // Show video player or thumbnail
                      if (isVideoPlaying)
                        _buildVideoPlayer(videoUrl, text)
                      else
                        _buildVideoThumbnail(),

                      // Play button or close button
                      if (!isVideoPlaying)
                        _buildPlayButton()
                      else
                        _buildCloseButton(),

                      // Loading overlay
                      if (isVideoLoading) _buildLoadingOverlay(),
                    ],
                  ),
                ),
              ),

              // Question text and checkbox with improved styling
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Modern animation checkbox
                    GestureDetector(
                      onTap: () => widget.onToggle(widget.index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        width: 28,
                        height: 28,
                        margin: const EdgeInsets.only(top: 2),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isChecked
                                ? widget.categoryColor
                                : Colors.grey.shade300,
                            width: 2,
                          ),
                          color: isChecked
                              ? widget.categoryColor
                              : Colors.transparent,
                          boxShadow: isChecked
                              ? [
                                  BoxShadow(
                                    color:
                                        widget.categoryColor.withOpacity(0.4),
                                    spreadRadius: 1,
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  )
                                ]
                              : null,
                        ),
                        child: isChecked
                            ? const Icon(Icons.check,
                                color: Colors.white, size: 20)
                            : null,
                      ),
                    ),
                    const Gap(16),

                    // Question text with improved typography
                    Expanded(
                      child: Text(
                        text,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade800,
                          height: 1.5,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoPlayer(String videoUrl, String captionText) {
    return VideoPlayerWidget(
      videoUrl: videoUrl,
      captionText: captionText,
      onVideoComplete: () {
        // Optionally handle video completion event
        debugPrint('Video completed for question: $captionText');
      },
    );
  }

  Widget _buildVideoThumbnail() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            widget.categoryColor.withOpacity(0.1),
            widget.categoryColor.withOpacity(0.3),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated play icon with improved styling
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: widget.categoryColor.withOpacity(0.5),
                    spreadRadius: 0,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.play_arrow_rounded,
                size: 40,
                color: widget.categoryColor,
              ),
            ),
            const Gap(16),
            // Instruction text with modern styling
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 0,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.touch_app, color: widget.categoryColor, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    "LIHAT VIDEO",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: widget.categoryColor,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayButton() {
    return Positioned.fill(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              isVideoLoading = true;
              isVideoPlaying = true;
            });

            // Pause all other videos first
            _controllerManager.pauseAll();

            // Simulate loading time (remove in production)
            Future.delayed(const Duration(milliseconds: 800), () {
              if (mounted) {
                setState(() {
                  isVideoLoading = false;
                });
              }
            });
          },
          // Visual effect when pressed
          splashColor: widget.categoryColor.withOpacity(0.3),
          highlightColor: widget.categoryColor.withOpacity(0.1),
        ),
      ),
    );
  }

  Widget _buildCloseButton() {
    return Positioned(
      top: 12,
      right: 12,
      child: Material(
        color: Colors.black.withOpacity(0.6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        child: InkWell(
          customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          onTap: () {
            // Stop the video and show thumbnail
            _controllerManager.pauseAll();
            setState(() {
              isVideoPlaying = false;
            });
          },
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(
              Icons.close,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.3),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 3,
            ),
            const Gap(12),
            Text(
              'Memuat video...',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                shadows: [
                  Shadow(
                    offset: const Offset(0, 1),
                    blurRadius: 3.0,
                    color: Colors.black.withOpacity(0.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
