import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:path_provider/path_provider.dart';

class FileService {
  static Future<String> getSafeFilePath(String fileName) async {
    if (Platform.isAndroid) {
      return await _getAndroidFilePath(fileName);
    } else if (Platform.isIOS) {
      return await _getIOSFilePath(fileName);
    } else {
      throw UnsupportedError('Platform not supported');
    }
  }

  static Future<String> _getAndroidFilePath(String fileName) async {
    try {
      final androidVersion = await _getAndroidVersion();
      print('Android SDK Version for file path: $androidVersion');

      if (androidVersion >= 30) {
        // Android 11+: Try external storage first, then fallback to app documents
        return await _getAndroid11PlusPath(fileName);
      } else {
        // Android 10 and below: Use legacy external storage
        return await _getAndroid10BelowPath(fileName);
      }
    } catch (e) {
      print('Error in Android file path generation: $e');
      // Final fallback to app documents directory
      return await _getAppDocumentsPath(fileName);
    }
  }

  static Future<String> _getAndroid11PlusPath(String fileName) async {
    try {
      // Try external storage first (for Android 11+)
      final externalDir = await getExternalStorageDirectory();
      if (externalDir != null) {
        final downloadsDir = Directory('${externalDir.path}/Download');
        if (!await downloadsDir.exists()) {
          await downloadsDir.create(recursive: true);
        }
        return '${downloadsDir.path}/$fileName';
      }
    } catch (e) {
      print('Error accessing external storage for Android 11+: $e');
    }

    // Fallback to app documents directory
    return await _getAppDocumentsPath(fileName);
  }

  static Future<String> _getAndroid10BelowPath(String fileName) async {
    try {
      // Try external storage first (for Android 10 and below)
      final externalDir = await getExternalStorageDirectory();
      if (externalDir != null) {
        final downloadsDir = Directory('${externalDir.path}/Download');
        if (!await downloadsDir.exists()) {
          await downloadsDir.create(recursive: true);
        }
        return '${downloadsDir.path}/$fileName';
      }
    } catch (e) {
      print('Error accessing external storage for Android 10 and below: $e');
    }

    // Fallback to app documents directory
    return await _getAppDocumentsPath(fileName);
  }

  static Future<String> _getAppDocumentsPath(String fileName) async {
    try {
      final documentsDir = await getApplicationDocumentsDirectory();
      final downloadsDir = Directory('${documentsDir.path}/Download');
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }
      return '${downloadsDir.path}/$fileName';
    } catch (e) {
      print('Error accessing app documents directory: $e');
      throw Exception('Could not access any storage directory');
    }
  }

  static Future<String> _getIOSFilePath(String fileName) async {
    try {
      final documentsDir = await getApplicationDocumentsDirectory();
      final downloadsDir = Directory('${documentsDir.path}/Download');
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }
      return '${downloadsDir.path}/$fileName';
    } catch (e) {
      print('Error accessing iOS documents directory: $e');
      throw Exception('Could not access iOS documents directory');
    }
  }

  static Future<bool> ensureDirectoryExists(String filePath) async {
    try {
      final file = File(filePath);
      final directory = file.parent;
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      return true;
    } catch (e) {
      print('Error ensuring directory exists: $e');
      return false;
    }
  }

  static Future<bool> writeFile(String filePath, List<int> bytes) async {
    try {
      final file = File(filePath);
      await file.writeAsBytes(bytes);
      return true;
    } catch (e) {
      print('Error writing file: $e');
      return false;
    }
  }

  static Future<String?> getAlternativePath(String fileName) async {
    try {
      final documentsDir = await getApplicationDocumentsDirectory();
      return '${documentsDir.path}/$fileName';
    } catch (e) {
      print('Error getting alternative path: $e');
      return null;
    }
  }

  static Future<int> _getAndroidVersion() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.version.sdkInt;
    } catch (e) {
      print('Error getting Android version: $e');
      return 0;
    }
  }
}
