import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../../app/theme.dart';
import '../../app/providers.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({
    super.key,
    required this.titleId,
    required this.videoPath,
    this.episodeId,
    this.episodeName,
    this.titleName,
    this.isSeries = false,
    this.startPositionSeconds = 0,
  });

  final String titleId;
  final String videoPath;
  final String? episodeId;
  final String? episodeName;
  final String? titleName;
  final bool isSeries;
  final int startPositionSeconds;

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  VideoPlayerController? _controller;
  String? _error;
  bool _showControls = true;
  Timer? _progressTimer;
  Timer? _hideControlsTimer;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    final contentRepo = context.read<ContentProvider>().contentRepo;
    final videoUrl = contentRepo.videoUrl(widget.videoPath);
    if (videoUrl.isEmpty) {
      setState(() => _error = 'Invalid video URL');
      return;
    }

    _controller = VideoPlayerController.networkUrl(
      Uri.parse(videoUrl),
      videoPlayerOptions: VideoPlayerOptions(
        mixWithOthers: false,
        allowBackgroundPlayback: false,
      ),
    );

    try {
      await _controller!.initialize();
      if (widget.startPositionSeconds > 0) {
        await _controller!.seekTo(Duration(seconds: widget.startPositionSeconds));
      }
      _controller!.addListener(_onPlayerUpdate);
      _startProgressSaver();
      if (mounted) setState(() {});
    } catch (e) {
      final msg = e.toString();
      final isSourceError = msg.contains('Source error') ||
          msg.contains('ExoPlaybackException') ||
          msg.contains('VideoError');
      if (mounted) {
        setState(() => _error = isSourceError
            ? 'Video could not be loaded. Please check your connection and try again.'
            : msg);
      }
    }
  }

  void _onPlayerUpdate() {
    if (_controller == null || !mounted) return;
    setState(() {});
  }

  void _startProgressSaver() {
    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      _saveProgress();
    });
  }

  Future<void> _saveProgress() async {
    if (_controller == null || !mounted) return;
    final auth = context.read<AuthProvider>();
    if (!auth.isLoggedIn) return;
    final pos = _controller!.value.position.inSeconds;
    final dur = _controller!.value.duration.inSeconds;
    if (dur <= 0) return;
    await context.read<PlaybackProvider>().saveProgress(
          titleId: widget.titleId,
          episodeId: widget.episodeId,
          progressSeconds: pos,
          durationSeconds: dur,
        );
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
      if (_showControls) {
        _hideControlsTimer?.cancel();
        _hideControlsTimer = Timer(const Duration(seconds: 3), () {
          if (mounted) setState(() => _showControls = false);
        });
      }
    });
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _hideControlsTimer?.cancel();
    _controller?.removeListener(_onPlayerUpdate);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(_error!, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_controller == null || !_controller!.value.isInitialized) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: netflixRed),
              const SizedBox(height: 16),
              Text(
                widget.titleName ?? 'Loading...',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            onTap: _toggleControls,
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller!.value.size.width,
                height: _controller!.value.size.height,
                child: VideoPlayer(_controller!),
              ),
            ),
          ),
          if (_showControls) _buildControls(),
        ],
      ),
    );
  }

  Widget _buildControls() {
    final position = _controller!.value.position;
    final duration = _controller!.value.duration;
    final progress = duration.inSeconds > 0 ? position.inSeconds / duration.inSeconds : 0.0;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black54,
            Colors.transparent,
            Colors.transparent,
            Colors.black87,
          ],
        ),
      ),
      child: Column(
        children: [
          AppBar(
            backgroundColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () async {
                await _saveProgress();
                if (mounted) Navigator.of(context).pop();
              },
            ),
            title: Text(
              widget.episodeName ?? widget.titleName ?? 'Playback',
              style: const TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: netflixRed,
                    inactiveTrackColor: Colors.white24,
                    thumbColor: netflixRed,
                  ),
                  child: Slider(
                    value: progress.clamp(0.0, 1.0),
                    onChanged: (v) {
                      final sec = (v * duration.inSeconds).round();
                      _controller!.seekTo(Duration(seconds: sec));
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(position.inSeconds),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                            size: 32,
                          ),
                          onPressed: () {
                            setState(() {
                              if (_controller!.value.isPlaying) {
                                _controller!.pause();
                              } else {
                                _controller!.play();
                              }
                            });
                          },
                        ),
                        Text(
                          _formatDuration(duration.inSeconds),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m}:${s.toString().padLeft(2, '0')}';
  }
}
