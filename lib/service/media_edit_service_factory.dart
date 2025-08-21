import 'dart:io';

import 'package:media_editor_app/service/media_edit_mobile_service.dart';
import 'package:media_editor_app/service/media_edit_service.dart';
import 'package:media_editor_app/service/media_edit_stub_service.dart';
import 'package:media_editor_app/service/media_edit_windows_service.dart';

class MediaEditServiceFactory {
  static MediaEditService create() {
    if (Platform.isWindows) {
      return MediaEditWindowsService();
    } else if (Platform.isAndroid) {
      return MediaEditMobileService();
    } else if (Platform.isIOS) {
      return MediaEditMobileService();
    } else {
      return MediaEditStubService();
    }
  }
}
