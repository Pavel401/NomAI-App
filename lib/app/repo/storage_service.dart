import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String?> uploadImage(File imageFile) async {
    try {
      // Create a reference to the location you want to upload to in Firebase Storage
      Reference ref = _storage
          .ref()
          .child('uploads/${DateTime.now().millisecondsSinceEpoch}.png');

      // Upload the file
      UploadTask uploadTask = ref.putFile(imageFile);

      // Wait for the upload to complete and get the download URL
      TaskSnapshot snapshot = await uploadTask.whenComplete(() {});
      String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }
}
