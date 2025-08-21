import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class Utils {
  static String? detectMimeTypeFromBytes(Uint8List bytes) {
    if (bytes.length < 12) return null;

    // 이미지
    if (bytes[0] == 0xFF && bytes[1] == 0xD8) return "image/jpeg";
    if (bytes[0] == 0x89 && bytes[1] == 0x50) return "image/png";
    if (bytes[0] == 0x47 && bytes[1] == 0x49) return "image/gif";
    if (bytes[0] == 0x42 && bytes[1] == 0x4D) return "image/bmp"; // BM
    if (bytes[0] == 0x49 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x2A &&
        bytes[3] == 0x00)
      return "image/tiff";
    if (bytes[0] == 0x4D &&
        bytes[1] == 0x4D &&
        bytes[2] == 0x00 &&
        bytes[3] == 0x2A)
      return "image/tiff";
    if (bytes.sublist(0, 4).toString() == "[82, 73, 70, 70]" &&
        String.fromCharCodes(bytes.sublist(8, 12)) == "WEBP")
      return "image/webp";

    // 비디오
    if (String.fromCharCodes(bytes.sublist(4, 8)) == "ftyp") return "video/mp4";
    if (String.fromCharCodes(bytes.sublist(4, 10)) == "ftypqt")
      return "video/quicktime";
    if (bytes[0] == 0x1A &&
        bytes[1] == 0x45 &&
        bytes[2] == 0xDF &&
        bytes[3] == 0xA3) {
      // MKV or WEBM
      final header = String.fromCharCodes(
        bytes.sublist(0, bytes.length > 16 ? 16 : bytes.length),
      );
      return header.contains("webm") ? "video/webm" : "video/x-matroska";
    }
    if (bytes[0] == 0x52 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x46) {
      final riffType = String.fromCharCodes(bytes.sublist(8, 12));
      if (riffType == "AVI ") return "video/x-msvideo";
      if (riffType == "WEBP") return "image/webp"; // RIFF 기반
    }
    if (bytes[0] == 0x46 && bytes[1] == 0x4C && bytes[2] == 0x56)
      return "video/x-flv";

    return null;
  }

  static Future<Size> getImageSizeFromBytes(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return Size(frame.image.width.toDouble(), frame.image.height.toDouble());
  }

  static Color generateRandomColor() {
    final random = Random();
    return Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
  }

  static String formatDuration(int milliseconds) {
    int totalSeconds = (milliseconds / 1000).round();
    int hours = totalSeconds ~/ 3600;
    int minutes = (totalSeconds % 3600) ~/ 60;
    int seconds = totalSeconds % 60;

    if (hours > 0) {
      // 1시간 이상: HH:MM:SS
      return '${hours.toString().padLeft(2, '0')}h ${minutes.toString().padLeft(2, '0')}m ${seconds.toString().padLeft(2, '0')}s';
    } else if (minutes > 0) {
      // 1분 이상 1시간 미만: MM:SS
      return '${minutes.toString().padLeft(2, '0')}m ${seconds.toString().padLeft(2, '0')}s';
    } else {
      // 1분 미만: SS
      return '${seconds.toString().padLeft(2, '0')}s';
    }
  }
}
