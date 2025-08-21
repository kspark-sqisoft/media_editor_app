import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class VideoPlayer extends StatefulWidget {
  const VideoPlayer({super.key, required this.bytes, this.onVideoSize});
  final Uint8List bytes;
  final ValueChanged<Size>? onVideoSize; // 부모에게 알림

  @override
  State<VideoPlayer> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
