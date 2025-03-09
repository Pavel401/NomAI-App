import 'dart:io';

import 'package:flutter/material.dart';
import 'package:turfit/app/utility/image_utility.dart';

class ImageDownscaleDemo extends StatefulWidget {
  final String imagePath;

  const ImageDownscaleDemo({super.key, required this.imagePath});

  @override
  State<ImageDownscaleDemo> createState() => _ImageDownscaleDemoState();
}

class _ImageDownscaleDemoState extends State<ImageDownscaleDemo> {
  ImageScale _selectedScale = ImageScale.small_512;
  File? _resizedImage;
  String? _base64;
  int? _originalSize;
  int? _resizedSize;

  Future<void> _downscaleImage() async {
    final resizedFile = await ImageUtility.downscaleImage(
      widget.imagePath,
      scale: _selectedScale,
    );

    final base64String =
        await ImageUtility.convertImageToBase64(resizedFile.path);

    setState(() {
      _resizedImage = resizedFile;
      _base64 = base64String;
      _originalSize = File(widget.imagePath).lengthSync();
      _resizedSize = resizedFile.lengthSync();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Image Downscale Demo')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Image Scale:', style: TextStyle(fontSize: 18)),
            ...ImageScale.values.map((scale) {
              return RadioListTile<ImageScale>(
                title: Text(scale
                    .toString()
                    .split('.')
                    .last
                    .replaceAll('_', ' ')
                    .toUpperCase()),
                value: scale,
                groupValue: _selectedScale,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedScale = value;
                    });
                  }
                },
              );
            }).toList(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _downscaleImage,
              child: const Text('Downscale Image'),
            ),
            const SizedBox(height: 20),
            if (_resizedImage != null) ...[
              const Text('Original Image:', style: TextStyle(fontSize: 16)),
              Image.file(File(widget.imagePath), height: 150),
              Text('Original Size: ${(_originalSize! ~/ 1024)} KB'),
              const SizedBox(height: 10),
              const Text('Resized Image:', style: TextStyle(fontSize: 16)),
              Image.file(_resizedImage!, height: 150),
              Text('Resized Size: ${(_resizedSize! ~/ 1024)} KB'),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  if (_base64 != null) {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Base64 String'),
                        content: SingleChildScrollView(
                          child: Text(_base64!),
                        ),
                      ),
                    );
                  }
                },
                child: const Text('Show Base64 Data'),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
