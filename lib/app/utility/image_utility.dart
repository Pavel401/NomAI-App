import 'dart:convert';
import 'dart:io';

import 'package:image/image.dart' as img;

enum ImageScale {
  small_512,
  medium_1024,
  large_2048,
}

class ImageUtility {
  static Future<String> convertImageToBase64(String path) async {
    // Read the image file as bytes
    final bytes = await File(path).readAsBytes();

    // Convert the bytes to a Base64 string
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

  static String _getNewFileName(String path, ImageScale scale) {
    final file = File(path);
    final directory = file.parent.path;
    final fileName = file.uri.pathSegments.last.split('.').first;
    final extension = file.uri.pathSegments.last.split('.').last;

    String scaleName = scale.toString().split('.').last;
    return '$directory/${fileName}_$scaleName.$extension';
  }

  static Future<File> downscaleImage(
    String path, {
    required ImageScale scale,
  }) async {
    // Read the image from the file
    final bytes = await File(path).readAsBytes();
    final image = img.decodeImage(bytes);

    if (image == null) {
      throw Exception("Failed to decode image");
    }

    // Get max size based on scale
    int maxSize = _getMaxSize(scale);

    // Calculate the new dimensions while maintaining aspect ratio
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

    // Resize the image
    final resizedImage = img.copyResize(
      image,
      width: width,
      height: height,
      maintainAspect: true,
    );

    // Encode the image back to file
    final resizedBytes = img.encodeJpg(resizedImage, quality: 85);

    // Generate a new file path based on scale
    final newPath = _getNewFileName(path, scale);
    final newFile = File(newPath)..writeAsBytesSync(resizedBytes);

    return newFile;
  }
}
