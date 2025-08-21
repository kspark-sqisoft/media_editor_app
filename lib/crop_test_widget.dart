import 'dart:convert';
import 'dart:io';

import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_session.dart';
import 'package:ffmpeg_kit_flutter_new/log.dart';
import 'package:ffmpeg_kit_flutter_new/statistics.dart';
import 'package:flutter/material.dart';
import 'package:media_editor_app/main.dart';
import 'package:media_editor_app/service/media_edit_service_factory.dart';
import 'package:media_editor_app/view/crop/media_crop_editor.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class CropTestWidget extends StatefulWidget {
  const CropTestWidget({super.key});

  @override
  State<CropTestWidget> createState() => _CropTestWidgetState();
}

class _CropTestWidgetState extends State<CropTestWidget> {
  static final int _mediaDurationMilliseconds = 219000;
  static final MediaType _mediaType = MediaType.video;
  static final String _fileName = '4k.mp4';
  @override
  void initState() {
    //final mediaEditService = MediaEditServiceFactory.create();
    //mediaEditService.crop();

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  String getCropFileName(String fileName) {
    final name = p.basenameWithoutExtension(fileName); // video
    final ext = p.extension(fileName); // .mp4
    return '${name}_crop$ext'; // video_crop.mp4
  }

  //FFmpeg가 비디오의 시간을 가져오진 않는다.
  //30528 ms
  Future<void> windowCrop() async {
    final inputPath = 'D:\\croptest\\$_fileName';
    final outputPath = 'D:\\croptest\\${getCropFileName(_fileName)}';
    final cropFilter = 'crop=1920:1080:0:0';

    //1. 일반적 소프트웨어 cpu 안정적
    List<String> args;

    if (_mediaType == MediaType.image) {
      args = ['-i', inputPath, '-vf', cropFilter, '-y', outputPath];
    } else {
      //2. 하드웨어 nvidia
      args = [
        '-i',
        inputPath,
        '-vf',
        '$cropFilter,format=yuv420p',
        '-c:v',
        'h264_nvenc',
        '-preset',
        'fast',
        '-c:a',
        'copy',
        '-y',
        outputPath,
      ];
    }

    logger.d('FFmpeg command (Windows): ffmpeg ${args.join(" ")}');

    //Process.start 비동기 스트리밍, Process.run 비동기, Process.runSync 동기
    //실시간으로 보려면 Process.start
    final process = await Process.start('C:\\ffmpeg\\bin\\ffmpeg.exe', args);

    process.stdout.transform(utf8.decoder).listen((data) {
      logger.d('[Windows stdout] $data');
    });

    process.stderr.transform(utf8.decoder).listen((data) {
      //logger.d('[Windows stderr] $data');
      if (_mediaType == MediaType.video) {
        final match = RegExp(r'time=(\d+):(\d+):(\d+\.?\d*)').allMatches(data);
        for (final m in match) {
          final hours = int.parse(m.group(1)!);
          final minutes = int.parse(m.group(2)!);
          final seconds = double.parse(m.group(3)!);

          final currentMs = ((hours * 3600 + minutes * 60 + seconds) * 1000)
              .round();
          final progress = (currentMs / _mediaDurationMilliseconds * 100).clamp(
            0,
            100,
          );
          logger.d(
            'Progress: ${progress.toStringAsFixed(1)}%    $currentMs/$_mediaDurationMilliseconds',
          );
        }
      }
    });

    final exitCode = await process.exitCode;
    // 프로세스 종료 시 마지막 100% 강제 출력
    logger.d(
      'Progress: 100.0%    $_mediaDurationMilliseconds/$_mediaDurationMilliseconds',
    );
    logger.d('[Windows exitCode] $exitCode');
  }

  Future<void> mobileCrop() async {
    final directory = await getExternalStorageDirectory();
    if (directory == null) {
      logger.e('ExternalStorage 가 없습니다.');
      return;
    }
    final inputPath = '${directory.path}/$_fileName'; // 앱 저장소 안에 있다고 가정
    final outputPath = '${directory.path}/${getCropFileName(_fileName)}';
    final cropFilter = 'crop=960:540:0:0';

    //하드웨어 인코더는 커스텀 픽셀시 실패..
    //크롭 자체는 성공했지만, 크롭한 결과를 저장하는 과정(인코딩)이 실패했다
    String command;

    if (_mediaType == MediaType.image) {
      command = '-i $inputPath -vf $cropFilter -y $outputPath';
    } else {
      command =
          '-i $inputPath -vf "$cropFilter,format=nv12" -c:v h264_mediacodec -c:a copy -y $outputPath';
    }

    // 하드웨어 인코더 대신 libx264 사용 + 픽셀포맷 강제

    // 소프트웨어(CPU)기반 인코더 사용 (libx264)
    //final command =
    //    '-i $inputPath -vf "$cropFilter,format=yuv420p" -c:v libx264 -preset ultrafast -c:a copy -y $outputPath';

    //하드웨어(GPU)기반 인코더 사용 (h264_mediacodec)
    //final command =
    //    '-i $inputPath -vf "$cropFilter,format=nv12" -c:v h264_mediacodec -c:a copy -y $outputPath';

    logger.d('FFmpeg command (Mobile): ffmpeg $command');

    await FFmpegKit.executeAsync(
      command,
      (FFmpegSession session) async {
        final output = await session.getOutput();
        final returnCode = await session.getReturnCode();
        final duration = await session.getDuration();

        // 프로세스 종료 시 마지막 100% 강제 출력
        logger.d(
          'Progress: 100.0%    $_mediaDurationMilliseconds/$_mediaDurationMilliseconds',
        );

        logger.d('✅ Processing completed!');
        logger.d('Return code: $returnCode');
        logger.d('Duration: ${duration}ms');
        logger.d('Output: $output');
        logger.d('session: $output');
      },
      (Log log) {
        logger.d('log:${log.getMessage()}');
      },
      (Statistics statistics) {
        if (_mediaType == MediaType.video) {
          final currentMs = statistics.getTime();
          if (_mediaType == MediaType.video) {
            final progress = (currentMs / _mediaDurationMilliseconds * 100)
                .clamp(0, 100);
            logger.d(
              'Progress: ${progress.toStringAsFixed(1)}%    $currentMs/$_mediaDurationMilliseconds',
            );
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                if (Platform.isAndroid) {
                  mobileCrop();
                } else if (Platform.isWindows) {
                  windowCrop();
                }
              },
              child: Text('CROP'),
            ),
          ],
        ),
      ),
    );
  }
}
