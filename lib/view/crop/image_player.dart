import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:media_editor_app/urtil/utils.dart';

class ImagePlayer extends StatefulWidget {
  const ImagePlayer({super.key, required this.bytes, this.onImageSize});
  final Uint8List bytes;
  final ValueChanged<Size>? onImageSize; // 부모에게 알림

  @override
  State<ImagePlayer> createState() => _ImagePlayerState();
}

class _ImagePlayerState extends State<ImagePlayer> {
  @override
  void initState() {
    initPlatform();
    super.initState();
  }

  Future<void> initPlatform() async {
    final size = await Utils.getImageSizeFromBytes(widget.bytes);
    if (widget.onImageSize != null) {
      widget.onImageSize!(size);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Image.memory(widget.bytes);
  }
}
