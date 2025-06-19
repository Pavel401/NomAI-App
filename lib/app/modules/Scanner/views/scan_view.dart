import 'dart:io';

import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:sizer/sizer.dart';
import 'package:NomAi/app/components/scanner_overlays.dart';
import 'package:NomAi/app/constants/colors.dart';
import 'package:NomAi/app/modules/Auth/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:NomAi/app/modules/Scanner/controller/scanner_controller.dart';

enum ScanMode { food, barcode, gallery }

class MealAiCamera extends StatefulWidget {
  MealAiCamera({super.key});

  @override
  State<MealAiCamera> createState() => _MealAiCameraState();
}

class _MealAiCameraState extends State<MealAiCamera> {
  ScanMode _selectedscanMode = ScanMode.food;
  FlashMode _currentFlashMode = FlashMode.auto;
  final ImagePicker _picker = ImagePicker();

  void _toggleFlashMode() {
    setState(() {
      if (_currentFlashMode == FlashMode.auto) {
        _currentFlashMode = FlashMode.on;
      } else if (_currentFlashMode == FlashMode.on) {
        _currentFlashMode = FlashMode.none;
      } else {
        _currentFlashMode = FlashMode.auto;
      }
    });
  }

  Future<void> _openGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      // Process the selected image
      // You could navigate to a new screen passing the image file
      File imageFile = File(image.path);

      ScannerController scannerController = Get.put(ScannerController());
      final authBloc = context.read<AuthenticationBloc>();

      scannerController.processNutritionQueryRequest(
          authBloc.state.user!.uid.toString(), imageFile, _selectedscanMode);
      Navigator.pop(context);
      // Example: Navigate to results screen with image
      // Navigator.push(context, MaterialPageRoute(builder: (context) => ResultsScreen(imageFile: imageFile)));
    }
  }

  void _captureImage(CameraState state) {
    state.when(
      onPhotoMode: (photoState) {
        photoState.takePhoto().then((mediaCapture) async {
          print(mediaCapture.path);

          // Navigator.push(
          //     context,
          //     MaterialPageRoute(
          //         builder: (context) => ImageDownscaleDemo(
          //               imagePath: mediaCapture.path!,
          //             )));

          ScannerController scannerController = Get.put(ScannerController());
          final authBloc = context.read<AuthenticationBloc>();

          scannerController.processNutritionQueryRequest(
              authBloc.state.user!.uid.toString(),
              File(mediaCapture.path!),
              _selectedscanMode);
          Navigator.pop(context);

          // Process the captured photo
          // Example: Navigate to results screen with the photo
          // Navigator.push(context, MaterialPageRoute(builder: (context) => ResultsScreen(photo: mediaCapture)));
        });
      },
      onVideoMode: (_) {
        // Not handling video mode in this example
      },
      onPreparingCamera: (s) {
        // Camera is still preparing
      },
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Camera Usage Guide'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
                '• Food Scan: Take a photo of your meal to analyze nutritional content.'),
            SizedBox(height: 8),
            Text(
                '• Barcode: Scan a barcode on packaged food for detailed information.'),
            SizedBox(height: 8),
            Text('• Gallery: Select an existing food image from your gallery.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CameraAwesomeBuilder.awesome(
        saveConfig: SaveConfig.photo(),
        sensorConfig: SensorConfig.single(
          aspectRatio: CameraAspectRatios.ratio_4_3,
          flashMode: _currentFlashMode,
          sensor: Sensor.position(SensorPosition.back),
          zoom: 0.0,
        ),
        // previewFit: CameraPreviewFit.cover,
        // onMediaTap: (mediaCapture) {},

        bottomActionsBuilder: (state) {
          return AwesomeBottomActions(
            state: state,
            captureButton: AwesomeBouncingWidget(
              onTap: () {
                _captureImage(state);
              },
              disabledOpacity: 0.3,
              duration: const Duration(milliseconds: 100),
              vibrationEnabled: true,
              child: SizedBox(
                key: const ValueKey('staticCameraButton'),
                height: 80,
                width: 80,
                child: CustomPaint(
                  painter: state.when(
                    onPhotoMode: (_) => CameraButtonPainter(),
                    // onPreparingCamera: (_) => CameraButtonPainter(),
                    // onVideoMode: (_) => VideoButtonPainter(),
                    // onVideoRecordingMode: (_) =>
                    //     VideoButtonPainter(isRecording: true),
                  ),
                ),
              ),
            ),
            left: AwesomeFlashButton(
              state: state,
            ),
            right: SizedBox(),
          );
        },
        theme: AwesomeTheme(
          bottomActionsBackgroundColor: Colors.transparent,
          buttonTheme: AwesomeButtonTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            iconSize: 24,
            padding: const EdgeInsets.all(18),
            buttonBuilder: (child, onTap) {
              return ClipOval(
                child: Material(
                  color: Colors.transparent,
                  shape: const CircleBorder(),
                  child: InkWell(
                    splashColor: Colors.deepPurple,
                    highlightColor: Colors.deepPurpleAccent.withOpacity(0.5),
                    onTap: onTap,
                    child: child,
                  ),
                ),
              );
            },
          ),
        ),
        previewDecoratorBuilder: (state, preview) {
          return Container(
            decoration: _selectedscanMode == ScanMode.food
                ? ShapeDecoration(
                    shape: FoodScannerOverlayShape(
                      borderColor: MealAIColors.whiteText,
                      overlayColor: Colors.black.withOpacity(0.3),
                      borderRadius: 20,
                      borderLength: 40,
                      borderWidth: 10,
                      cutOutSize: 80.w,
                    ),
                  )
                : ShapeDecoration(
                    shape: BarcodeScannerOverlayShape(
                      borderColor: MealAIColors.whiteText,
                      overlayColor: Colors.black.withOpacity(0.3),
                      borderRadius: 10,
                      borderLength: 15,
                      borderWidth: 5,
                    ),
                  ),
          );
        },
        topActionsBuilder: (state) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.black.withOpacity(0.5),
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                CircleAvatar(
                  backgroundColor: Colors.black.withOpacity(0.5),
                  child: IconButton(
                    icon: const Icon(Icons.info_outline, color: Colors.white),
                    onPressed: _showInfoDialog,
                  ),
                ),
              ],
            ),
          );
        },
        // bottomActionsBuilder: (state) => Padding(
        //   padding: const EdgeInsets.only(bottom: 20),
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.center,
        //     children: [
        //       Row(
        //         children: [
        //           // GestureDetector(
        //           //   onTap: _toggleFlashMode,
        //           //   child: CircleAvatar(
        //           //     backgroundColor: Colors.white,
        //           //     radius: 25,
        //           //     child: Icon(
        //           //       _currentFlashMode == FlashMode.auto
        //           //           ? Icons.flash_auto
        //           //           : _currentFlashMode == FlashMode.on
        //           //               ? Icons.flash_on
        //           //               : Icons.flash_off,
        //           //       color: Colors.black,
        //           //     ),
        //           //   ),
        //           // ),
        //           // const SizedBox(width: 40),
        //           GestureDetector(
        //             onTap: () => _captureImage(state),
        //             child: Container(
        //               width: 70,
        //               height: 70,
        //               decoration: BoxDecoration(
        //                 color: Colors.white,
        //                 shape: BoxShape.circle,
        //                 border: Border.all(color: Colors.black, width: 4),
        //               ),
        //             ),
        //           ),
        //         ],
        //       ),
        //     ],
        //   ),
        // ),
        middleContentBuilder: (state) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 80),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedscanMode = ScanMode.food;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _selectedscanMode == ScanMode.food
                              ? MealAIColors.switchWhiteColor
                              : MealAIColors.greyLight.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.fastfood_outlined,
                                color: MealAIColors.switchBlackColor, size: 28),
                            Text(
                              'Scan Food',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(
                                      color: MealAIColors.switchBlackColor),
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedscanMode = ScanMode.barcode;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _selectedscanMode == ScanMode.barcode
                              ? MealAIColors.switchWhiteColor
                              : MealAIColors.greyLight.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Icon(Symbols.barcode,
                                color: MealAIColors.switchBlackColor, size: 28),
                            Text(
                              'Barcode',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(
                                      color: MealAIColors.switchBlackColor),
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedscanMode = ScanMode.gallery;
                        });
                        // Directly open gallery when gallery mode is selected
                        _openGallery();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _selectedscanMode == ScanMode.gallery
                              ? MealAIColors.switchWhiteColor
                              : MealAIColors.greyLight.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Icon(Symbols.image_rounded,
                                color: MealAIColors.switchBlackColor, size: 28),
                            Text(
                              'Gallery',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(
                                      color: MealAIColors.switchBlackColor),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
