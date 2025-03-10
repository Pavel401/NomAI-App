import 'dart:io';

import 'package:before_after/before_after.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
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
  double _sliderPosition = 0.5;
  bool _isProcessing = false;

  Future<void> _downscaleImage() async {
    setState(() {
      _isProcessing = true;
    });

    try {
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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error downscaling image: $e')),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  String _formatFileSize(int bytes) {
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    var i = 0;
    double size = bytes.toDouble();
    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }
    return '${size.toStringAsFixed(1)} ${suffixes[i]}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Downscale Demo'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildScaleSelector(),
            _buildActionButtons(),
            if (_resizedImage != null) _buildImageComparison(),
          ],
        ),
      ),
    );
  }

  Widget _buildScaleSelector() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Output Resolution',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ImageScale.values.map((scale) {
                final isSelected = scale == _selectedScale;
                final label = scale
                    .toString()
                    .split('.')
                    .last
                    .replaceAll('_', ' ')
                    .toUpperCase();

                return FilterChip(
                  label: Text(label),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() {
                      _selectedScale = scale;
                    });
                  },
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  selectedColor: Theme.of(context).colorScheme.primaryContainer,
                  checkmarkColor:
                      Theme.of(context).colorScheme.onPrimaryContainer,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? Theme.of(context).colorScheme.onPrimaryContainer
                        : Theme.of(context).colorScheme.onSurface,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ElevatedButton(
        onPressed: _isProcessing ? null : _downscaleImage,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: _isProcessing
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 12),
                  Text(_resizedImage == null
                      ? 'Processing...'
                      : 'Reprocessing...'),
                ],
              )
            : Text(_resizedImage == null ? 'Process Image' : 'Reprocess Image'),
      ),
    );
  }

  Widget _buildImageComparison() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),
        _buildStatsCard(),
        const SizedBox(height: 16),
        Container(
          height: 400,
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.shade300,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
            color: Colors.grey.shade100,
          ),
          child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: BeforeAfter(
                value: _sliderPosition,
                before: PhotoView(
                  imageProvider: FileImage(File(widget.imagePath)),
                  backgroundDecoration: BoxDecoration(
                    color: Colors.transparent,
                  ),
                ),
                after: PhotoView(
                  imageProvider: FileImage(_resizedImage!),
                  backgroundDecoration: BoxDecoration(
                    color: Colors.transparent,
                  ),
                ),
                onValueChanged: (value) {
                  setState(() {
                    _sliderPosition = value;
                  });
                },
              )),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ElevatedButton.icon(
            onPressed: () {
              if (_base64 != null) {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Base64 String'),
                    content: Container(
                      width: double.maxFinite,
                      child: SingleChildScrollView(
                        child: SelectableText(
                          _base64!,
                          style: const TextStyle(
                              fontFamily: 'monospace', fontSize: 12),
                        ),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                );
              }
            },
            icon: const Icon(Icons.content_copy),
            label: const Text('Show Base64 Data'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildStatsCard() {
    final originalSizeFormatted = _formatFileSize(_originalSize!);
    final resizedSizeFormatted = _formatFileSize(_resizedSize!);
    final compressionRatio = _originalSize! / _resizedSize!;
    final percentReduction =
        ((1 - (1 / compressionRatio)) * 100).toStringAsFixed(1);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Image Comparison',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    "Original",
                    originalSizeFormatted,
                    Icons.photo,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    "Processed",
                    resizedSizeFormatted,
                    Icons.compress,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    "Reduction",
                    "$percentReduction%",
                    Icons.trending_down,
                    Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
