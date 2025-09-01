import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import 'package:image/image.dart' as img;

enum ImageScale {
  small_512,
  medium_1024,
  large_2048,
}

class ImageUtility {
  static Future<String> convertImageToBase64(String path) async {
    final bytes = await File(path).readAsBytes();

    final base64String = base64Encode(bytes);

    return base64String;
  }

  static int _getMaxSize(ImageScale scale) {
    switch (scale) {
      case ImageScale.small_512:
        return 512;
      case ImageScale.medium_1024:
        return 1024;
      case ImageScale.large_2048:
        return 2048;
    }
  }

  static Future<String> _getNewFileName(
      String originalPath, ImageScale scale) async {
    final tempDir = await getTemporaryDirectory();
    final fileName = path.basenameWithoutExtension(originalPath);
    final extension = path.extension(originalPath);

    String scaleName = scale.toString().split('.').last;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return path.join(
        tempDir.path, '${fileName}_${scaleName}_$timestamp$extension');
  }

  static Future<File> downscaleImage(
    String filePath, {
    required ImageScale scale,
  }) async {
    final bytes = await File(filePath).readAsBytes();
    final image = img.decodeImage(bytes);

    if (image == null) {
      throw Exception("Failed to decode image");
    }

    int maxSize = _getMaxSize(scale);

    int width = image.width;
    int height = image.height;

    if (width > height) {
      if (width > maxSize) {
        height = (height * (maxSize / width)).toInt();
        width = maxSize;
      }
    } else {
      if (height > maxSize) {
        width = (width * (maxSize / height)).toInt();
        height = maxSize;
      }
    }

    final resizedImage = img.copyResize(
      image,
      width: width,
      height: height,
      maintainAspect: true,
    );

    final resizedBytes = img.encodeJpg(resizedImage, quality: 85);

    final newPath = await _getNewFileName(filePath, scale);
    final newFile = File(newPath);

    await newFile.parent.create(recursive: true);

    await newFile.writeAsBytes(resizedBytes);

    return newFile;
  }
}
