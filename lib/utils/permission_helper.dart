import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionHelper {
  static Future<bool> requestStoragePermission(BuildContext context) async {
    // iOS doesn't need storage permission for file picker
    if (Platform.isIOS) {
      return true;
    }

    if (!Platform.isAndroid) return true;

    try {
      final androidVersion = await _getAndroidVersion();
      print('Android SDK Version: $androidVersion');

      if (androidVersion >= 33) {
        // Android 13+ detected - request granular media permissions
        print('Android 13+ detected - requesting media permissions');
        final images = await Permission.photos.request();
        final videos = await Permission.videos.request();
        final audio = await Permission.audio.request();
        if (images.isGranted || videos.isGranted || audio.isGranted) {
          return true;
        } else {
          _showPermissionDialog(
            context,
            'Storage permission is required to save files to shared locations. Please grant access in settings.',
          );
          return false;
        }
      } else if (androidVersion >= 30) {
        // Android 11-12: MANAGE_EXTERNAL_STORAGE
        print('Android 11-12 detected - requesting MANAGE_EXTERNAL_STORAGE');
        final manageStorage = await Permission.manageExternalStorage.request();
        if (manageStorage.isGranted) {
          return true;
        } else {
          _showPermissionDialog(
            context,
            'Storage permission is required to save files. Please grant "Manage all files" permission in settings.',
          );
          return false;
        }
      } else {
        // Android 10 and below: WRITE_EXTERNAL_STORAGE
        print('Android 10 and below detected - requesting WRITE_EXTERNAL_STORAGE');
        final storage = await Permission.storage.request();
        if (storage.isGranted) {
          return true;
        } else {
          _showPermissionDialog(context, 'Storage permission is required to save files. Please grant storage permission in settings.');
          return false;
        }
      }
    } catch (e) {
      print('Error requesting storage permission: $e');
      return false;
    }
  }

  static void _showPermissionDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Permission Required'),
          content: Text(message),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Cancel')),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: Text('Settings'),
            ),
          ],
        );
      },
    );
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
