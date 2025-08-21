import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart' as vp;

class VideoPlayer extends StatefulWidget {
  const VideoPlayer({
    super.key,
    required this.bytes,
    this.onVideoSize,
    this.onVideoDuration,
  });
  final Uint8List bytes;
  final ValueChanged<Size>? onVideoSize; // 부모에게 알림
  final ValueChanged<Duration>? onVideoDuration;

  @override
  State<VideoPlayer> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer> {
  late vp.VideoPlayerController _controller;
  File? _tempFile;

  bool _isInitialized = false;

  @override
  void initState() {
    initPlatform();
    super.initState();
  }

  Future<void> initPlatform() async {
    final tempDir = await getTemporaryDirectory();
    _tempFile = File('${tempDir.path}/temp_video.mp4');
    await _tempFile!.writeAsBytes(widget.bytes);
    _controller = vp.VideoPlayerController.file(_tempFile!);
    _controller.addListener(() {
      setState(() {});
    });
    _controller.setLooping(true);
    _controller.initialize().then(
      (_) => setState(() {
        _isInitialized = true;
        final size = _controller.value.size;
        if (widget.onVideoSize != null) {
          widget.onVideoSize!(size);
        }
        final duration = _controller.value.duration;
        if (widget.onVideoDuration != null) {
          widget.onVideoDuration!(duration);
        }
      }),
    );
    _controller.play();
  }

  @override
  void dispose() {
    _tempFile?.deleteSync();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitialized == false) {
      return SizedBox.shrink();
    }

    return _isInitialized
        ? SizedBox(
            width: _controller.value.size.width,
            height: _controller.value.size.height,
            child: vp.VideoPlayer(_controller),
          )
        : SizedBox.shrink();
  }
}
