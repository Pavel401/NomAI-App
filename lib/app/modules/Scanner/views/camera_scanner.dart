// import 'dart:io';

// import 'package:camerawesome/camerawesome_plugin.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:material_symbols_icons/symbols.dart';
// import 'package:sizer/sizer.dart';
// import 'package:turfit/app/constants/colors.dart';

// enum ScanMode { food, barcode, gallery }

// class AICameraScanner extends StatefulWidget {
//   AICameraScanner({super.key});

//   @override
//   State<AICameraScanner> createState() => _AICameraScannerState();
// }

// class _AICameraScannerState extends State<AICameraScanner> {
//   ScanMode _selectedscanMode = ScanMode.food;
//   final ImagePicker _picker = ImagePicker();

//   void _openGallery() async {
//     final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
//     if (image != null) {
//       // Process the selected image
//       File imageFile = File(image.path);
//       // Example: Navigate to results screen with image
//       // Navigator.push(context, MaterialPageRoute(builder: (context) => ResultsScreen(imageFile: imageFile)));
//       print('Selected image: ${imageFile.path}');
//     }
//   }

//   void _captureImage(CameraState state) {
//     state.when(
//       onPhotoMode: (photoState) {
//         photoState.takePhoto().then((mediaCapture) {
//           // Process the captured photo
//           // Navigator.push(context, MaterialPageRoute(builder: (context) => ResultsScreen(photo: mediaCapture)));
//         });
//       },
//       onVideoMode: (_) {
//         // Not handling video mode in this example
//       },
//       onPreparingCamera: (s) {
//         // Camera is still preparing
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: CameraAwesomeBuilder.awesome(
//         saveConfig: SaveConfig.photo(),
//         sensorConfig: SensorConfig.single(
//           aspectRatio: CameraAspectRatios.ratio_4_3,
//           flashMode: FlashMode.auto,
//           sensor: Sensor.position(SensorPosition.back),
//           zoom: 0.0,
//         ),
//         previewFit: CameraPreviewFit.cover,
//         onMediaTap: (mediaCapture) {},
//         theme: AwesomeTheme(
//           buttonTheme: AwesomeButtonTheme(
//             backgroundColor: Colors.transparent,
//             foregroundColor: Colors.white,
//             iconSize: 24,
//             padding: const EdgeInsets.all(18),
//             buttonBuilder: (child, onTap) {
//               return ClipOval(
//                 child: Material(
//                   color: Colors.transparent,
//                   shape: const CircleBorder(),
//                   child: InkWell(
//                     splashColor: Colors.grey.withOpacity(0.3),
//                     highlightColor: Colors.grey.withOpacity(0.1),
//                     onTap: onTap,
//                     child: child,
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//         topActionsBuilder: (state) {
//           return Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             child: Column(
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   children: [
//                     // Back button
//                     Container(
//                       decoration: BoxDecoration(
//                         color: Colors.black.withOpacity(0.4),
//                         shape: BoxShape.circle,
//                       ),
//                       child: IconButton(
//                         icon: const Icon(Icons.close,
//                             color: Colors.white, size: 22),
//                         onPressed: () => Navigator.pop(context),
//                       ),
//                     ),
//                     Expanded(child: SizedBox()),
//                     // Title
//                     Text(
//                       'Scan',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 18,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     Expanded(child: SizedBox()),

//                     // Right side options (stack of options)
//                   ],
//                 ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         GestureDetector(
//                           onTap: () {
//                             setState(() {
//                               _selectedscanMode = ScanMode.food;
//                             });
//                           },
//                           child: Container(
//                             padding: const EdgeInsets.all(10),
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               color: _selectedscanMode == ScanMode.food
//                                   ? MealAIColors.switchWhiteColor
//                                   : MealAIColors.greyLight.withOpacity(0.5),
//                             ),
//                             child: Icon(Icons.fastfood_outlined,
//                                 color: MealAIColors.switchBlackColor, size: 28),
//                           ),
//                         ),
//                         SizedBox(height: 2.h),
//                         GestureDetector(
//                           onTap: () {
//                             setState(() {
//                               _selectedscanMode = ScanMode.barcode;
//                             });
//                           },
//                           child: Container(
//                             padding: const EdgeInsets.all(10),
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               color: _selectedscanMode == ScanMode.barcode
//                                   ? MealAIColors.switchWhiteColor
//                                   : MealAIColors.greyLight.withOpacity(0.5),
//                             ),
//                             child: Icon(Symbols.barcode,
//                                 color: MealAIColors.switchBlackColor, size: 28),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 )
//               ],
//             ),
//           );
//         },
//         bottomActionsBuilder: (state) => Padding(
//           padding: const EdgeInsets.only(bottom: 20),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               // Capture button
//               GestureDetector(
//                 onTap: () => _captureImage(state),
//                 child: Container(
//                   width: 70,
//                   height: 70,
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     shape: BoxShape.circle,
//                     border: Border.all(color: Colors.grey[300]!, width: 3),
//                   ),
//                 ),
//               ),

//               // Gallery button to the right
//               Padding(
//                 padding: const EdgeInsets.only(left: 40),
//                 child: GestureDetector(
//                   onTap: _openGallery,
//                   child: Container(
//                     width: 40,
//                     height: 40,
//                     decoration: BoxDecoration(
//                       color: Colors.black.withOpacity(0.5),
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(
//                           color: Colors.white.withOpacity(0.5), width: 1),
//                     ),
//                     child: const Icon(
//                       Icons.photo_library,
//                       color: Colors.white,
//                       size: 20,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         middleContentBuilder: (state) {
//           // We're not using the mode selector buttons that were in the original
//           // as they don't match the reference UI
//           return const SizedBox.shrink();
//         },
//       ),
//     );
//   }
// }
