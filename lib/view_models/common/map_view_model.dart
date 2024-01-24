import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ShowMapViewModel {
  Future<void> pickImage(BuildContext context) async {
    ImageSource? imageSource = ImageSource.gallery;

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: imageSource);
    if (image != null) {
      File? imageFile = File(image.path);
      uploadImageToFirebase(imageFile);
    }
  }

  final String path = 'map/image';
  Future<void> uploadImageToFirebase(File imageFile) async {
    Reference firebaseStorageRef = FirebaseStorage.instance.ref().child(path);
    try {
      await firebaseStorageRef.putFile(imageFile);
    } catch (_) {
      rethrow;
    }
  }

  Future<String?> getMapImageUrl() async {
    Reference firebaseStorageRef = FirebaseStorage.instance.ref().child(path);
    String? url;
    url = await firebaseStorageRef.getDownloadURL().then((value) async {
      return value;
    });
    if (url != null) {
      return url;
    }
    return '';
  }
}
