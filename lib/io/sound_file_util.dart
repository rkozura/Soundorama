import 'dart:io';

import 'package:path_provider/path_provider.dart';

class SoundFileUtil {
  static Future<String> createSoundFile() async {
      Directory directory = await _getApplicationDirectory();
      return '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.mp4';
  }

  static void deleteSoundFile(String pathToSound) {
    if (doesFileExist(pathToSound)) {
      File file = File(pathToSound);
      file.deleteSync();
    }
  }

  static bool doesFileExist(String pathToSound) {
    if (pathToSound != null) {
      File file = File(pathToSound);
      return file.existsSync();
    }
    return false;
  }

  static Future<Directory> _getApplicationDirectory() async {
    return await getApplicationDocumentsDirectory();
  }
}
