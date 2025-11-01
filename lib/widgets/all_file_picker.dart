import 'dart:io';
import 'dart:ui' as ui;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';

import '../utils/permission_helper.dart';

class UniversalFilePicker {
  static Future<Map<String, String>?> pickFile({
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    int maxSizeMB = 5,
    bool onlyImage = false,
    int? requiredWidth,
    int? requiredHeight,
    required BuildContext context
  }) async {
    try {
      // iOS doesn't need storage permission, but Android does
      if (Platform.isAndroid) {
        final hasPermission = await PermissionHelper.requestStoragePermission(context);
        if (!hasPermission) {
          return {"error": "Storage permission denied"};
        }
      }

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: onlyImage ? FileType.image : type,
        allowedExtensions: onlyImage ? null : allowedExtensions,
        // iOS-specific options
        allowMultiple: false,
        withData: false,
        withReadStream: false,
      );

      if (result != null && result.files.single.path != null) {
        File file = File(result.files.single.path!);

        // Check if file exists and is readable
        if (!await file.exists()) {
          return {"error": "Selected file does not exist"};
        }

        if (file.lengthSync() > maxSizeMB * 1024 * 1024) {
          return {"error": "File size should be less than $maxSizeMB MB"};
        }

        if (onlyImage && (requiredWidth != null || requiredHeight != null)) {
          try {
            final bytes = await file.readAsBytes();
            final codec = await ui.instantiateImageCodec(bytes);
            final frame = await codec.getNextFrame();
            final image = frame.image;

            if ((requiredWidth != null && requiredHeight != null)) {
              double aspectRatio = image.width / image.height;

              if (aspectRatio < 3.0 || aspectRatio > 4.0) {
                return {"error": "Image must have an aspect ratio between 3:1 and 4:1 (e.g. 300x100 or 400x100)."};
              }
            }
          } catch (e) {
            return {"error": "Invalid image file format"};
          }
        }

        return {"fileName": result.files.single.name, "filePath": result.files.single.path!};
      }

      return null;
    } catch (e) {
      // Handle iOS-specific errors
      if (Platform.isIOS) {
        return {"error": "File selection failed. Please try again."};
      }
      return {"error": "File selection failed: ${e.toString()}"};
    }
  }

  static Future<Map<String, dynamic>?> pickMultipleFiles({
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    int maxSizeMB = 5,
    bool onlyImage = false,
    int maxFiles = 10,
    required BuildContext context
  }) async {
    try {
      // iOS doesn't need storage permission, but Android does
      if (Platform.isAndroid) {
        final hasPermission = await PermissionHelper.requestStoragePermission(context);
        if (!hasPermission) {
          return {"error": "Storage permission denied"};
        }
      }

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: onlyImage ? FileType.image : type,
        allowedExtensions: onlyImage ? null : allowedExtensions,
        allowMultiple: true,
        withData: false,
        withReadStream: false,
      );

      if (result != null && result.files.isNotEmpty) {
        List<String> validFilePaths = [];
        List<String> fileNames = [];

        for (final file in result.files) {
          if (file.path != null) {
            File fileObj = File(file.path!);

            // Check if file exists and is readable
            if (!await fileObj.exists()) {
              continue;
            }

            if (fileObj.lengthSync() > maxSizeMB * 1024 * 1024) {
              continue; // Skip files that are too large
            }

            validFilePaths.add(file.path!);
            fileNames.add(file.name);
          }
        }

        if (validFilePaths.isEmpty) {
          return {"error": "No valid files selected"};
        }

        if (validFilePaths.length > maxFiles) {
          return {"error": "Maximum $maxFiles files allowed"};
        }

        return {
          "filePaths": validFilePaths,
          "fileNames": fileNames,
          "count": validFilePaths.length
        };
      }

      return null;
    } catch (e) {
      // Handle iOS-specific errors
      if (Platform.isIOS) {
        return {"error": "File selection failed. Please try again."};
      }
      return {"error": "File selection failed: ${e.toString()}"};
    }
  }
}
