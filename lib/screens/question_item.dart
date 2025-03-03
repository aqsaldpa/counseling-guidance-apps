import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:myapp/widgets/video_player.dart';

class QuestionItem extends StatefulWidget {
  final Map<String, dynamic> question;
  final int index;
  final Color categoryColor;
  final Function(int) onToggle;
  final String currentCategory; // Added parameter to track category changes

  const QuestionItem({
    super.key,
    required this.question,
    required this.index,
    required this.categoryColor,
    required this.onToggle,
    required this.currentCategory,
  });

  @override
  State<QuestionItem> createState() => _QuestionItemState();
}

class _QuestionItemState extends State<QuestionItem>
    with AutomaticKeepAliveClientMixin {
  bool isVideoPlaying = false;
  bool isVideoLoading = false;
  final VideoControllerManager _controllerManager = VideoControllerManager();
  late String _lastCategory; // Store the last category to detect changes

  @override
  void initState() {
    super.initState();
    _lastCategory = widget.currentCategory;
  }

  @override
  void didUpdateWidget(QuestionItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If category changed, reset video state to thumbnail
    if (widget.currentCategory != _lastCategory) {
      if (isVideoPlaying) {
        _controllerManager.pauseAll();
        setState(() {
          isVideoPlaying = false;
          isVideoLoading = false;
        });
      }
      _lastCategory = widget.currentCategory;
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

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Video thumbnail or player
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
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

          // Question text and checkbox
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Checkbox on the left
                GestureDetector(
                  onTap: () => widget.onToggle(widget.index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isChecked
                            ? widget.categoryColor
                            : Colors.grey.shade400,
                        width: 2,
                      ),
                      color:
                          isChecked ? widget.categoryColor : Colors.transparent,
                      boxShadow: isChecked
                          ? [
                              BoxShadow(
                                color: widget.categoryColor.withOpacity(0.3),
                                spreadRadius: 1,
                                blurRadius: 3,
                                offset: const Offset(0, 1),
                              )
                            ]
                          : null,
                    ),
                    child: isChecked
                        ? const Icon(Icons.check, color: Colors.white, size: 20)
                        : null,
                  ),
                ),
                const Gap(16),

                // Question text
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade800,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
            widget.categoryColor.withOpacity(0.2),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated play icon
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: widget.categoryColor.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
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
            // Instruction text
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
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
                  Icon(Icons.touch_app, color: widget.categoryColor),
                  const SizedBox(width: 8),
                  Text(
                    "SENTUH UNTUK MELIHAT VIDEO",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: widget.categoryColor,
                      letterSpacing: 0.5,
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
            Future.delayed(const Duration(milliseconds: 1000), () {
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
      top: 8,
      right: 8,
      child: Material(
        color: Colors.black.withOpacity(0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: InkWell(
          customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
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
