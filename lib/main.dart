import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:media_editor_app/crop_test_widget.dart';
import 'package:media_editor_app/view/crop/media_crop_editor.dart';
import 'package:video_player_media_kit/video_player_media_kit.dart';

final logger = Logger(printer: SimplePrinter(printTime: true));
void main() {
  VideoPlayerMediaKit.ensureInitialized(windows: true);
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: MyHomePage());
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CropTestWidget(),
        //child: MediaCropEditor(),
      ),
    );
  }
}

/*
기존
Skia/OpenGL


flutter.3.7 이후
Impeller/Vulkan
*/
