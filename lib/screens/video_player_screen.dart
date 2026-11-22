import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String videoTitle;

  const VideoPlayerScreen({
    super.key,
    required this.videoUrl,
    required this.videoTitle,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _hasError = false;

  static const Color peach = Color(0xFFFDBA9B);
  static const Color dark = Color(0xFF08090D);

  bool get isDarkMode =>
      Theme.of(context).brightness == Brightness.dark;

  Color get backgroundColor =>
      isDarkMode ? dark : Colors.white;

  Color get primaryTextColor =>
      isDarkMode ? Colors.white : const Color(0xFF20232A);

  Color get secondaryTextColor =>
      isDarkMode ? Colors.white70 : const Color(0xFF666666);

  Color get iconColor =>
      isDarkMode ? Colors.white : const Color(0xFF20232A);

  Color get inactiveSliderColor =>
      isDarkMode ? Colors.white24 : Colors.black26;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
      );

      await _controller.initialize();

      if (!mounted) return;

      setState(() {
        _isInitialized = true;
      });

      await _controller.play();

      _controller.addListener(() {
        if (mounted) {
          setState(() {});
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _hasError = true;
      });
    }
  }

  Future<void> _seekForward() async {
    if (!_isInitialized) return;

    final position = await _controller.position;
    final duration = _controller.value.duration;

    if (position == null) return;

    final newPosition = position + const Duration(seconds: 10);

    await _controller.seekTo(
      newPosition < duration ? newPosition : duration,
    );
  }

  Future<void> _seekBackward() async {
    if (!_isInitialized) return;

    final position = await _controller.position;

    if (position == null) return;

    final newPosition = position - const Duration(seconds: 10);

    await _controller.seekTo(
      newPosition > Duration.zero ? newPosition : Duration.zero,
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int value) => value.toString().padLeft(2, '0');

    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${twoDigits(minutes)}:${twoDigits(seconds)}';
    }

    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }

  @override
  void dispose() {
    if (_isInitialized) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        foregroundColor: primaryTextColor,
        title: Text(
          widget.videoTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Center(
        child: _hasError
            ? _buildError()
            : !_isInitialized
                ? const CircularProgressIndicator(color: peach)
                : _buildPlayer(),
      ),
    );
  }

  Widget _buildError() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: peach,
            size: 55,
          ),
          const SizedBox(height: 16),
          Text(
            'Unable to play this video',
            style: TextStyle(
              color: primaryTextColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please check the video URL and try again.',
            textAlign: TextAlign.center,
            style: TextStyle(color: secondaryTextColor),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _hasError = false;
                _isInitialized = false;
              });
              _initializePlayer();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayer() {
    final value = _controller.value;
    final duration = value.duration;
    final position = value.position;

    final progress = duration.inMilliseconds > 0
        ? position.inMilliseconds
            .clamp(0, duration.inMilliseconds)
            .toDouble()
        : 0.0;

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          AspectRatio(
            aspectRatio: value.aspectRatio > 0
                ? value.aspectRatio
                : 16 / 9,
            child: VideoPlayer(_controller),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: _seekBackward,
                icon: Icon(
                  Icons.replay_10,
                  color: iconColor,
                  size: 38,
                ),
              ),
              const SizedBox(width: 20),
              IconButton(
                onPressed: () {
                  setState(() {
                    value.isPlaying
                        ? _controller.pause()
                        : _controller.play();
                  });
                },
                icon: Icon(
                  value.isPlaying
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_fill,
                  color: peach,
                  size: 60,
                ),
              ),
              const SizedBox(width: 20),
              IconButton(
                onPressed: _seekForward,
                icon: Icon(
                  Icons.forward_10,
                  color: iconColor,
                  size: 38,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  _formatDuration(position),
                  style: TextStyle(color: secondaryTextColor),
                ),
                Expanded(
                  child: Slider(
                    value: progress,
                    min: 0,
                    max: duration.inMilliseconds > 0
                        ? duration.inMilliseconds.toDouble()
                        : 1,
                    activeColor: peach,
                    inactiveColor: inactiveSliderColor,
                    onChanged: (newValue) {
                      _controller.seekTo(
                        Duration(milliseconds: newValue.toInt()),
                      );
                    },
                  ),
                ),
                Text(
                  _formatDuration(duration),
                  style: TextStyle(color: secondaryTextColor),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}