import 'dart:io';

import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../res/components.dart';

class ProfileViewModel {
  String roleName = '';

  File? _imageFile;

  String getLocalizationMajor(BuildContext context, String majorInEnglish) {
    List<String> localizationMajors = Components.setMajors(context);
    int i = Components.majors.indexOf(majorInEnglish);
    return localizationMajors[i];
  }

  void setUserData(int role) {
    if (role == 0) {
      roleName = 'students';
    } else if (role == 1) {
      roleName = 'teachers';
    } else {
      roleName = 'admins';
    }
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getProfileData(String email, String majorKey) {
    final userProfile = FirebaseFirestore.instance
        .collection(roleName)
        .doc(majorKey)
        .collection('${majorKey}_$roleName')
        .doc(email);
    return userProfile.snapshots();
  }

  void pickAndUploadImage(BuildContext context, String email, String majorKey) async {
    ImageSource? imageSource;
    imageSource = await Components.pickImageAlert(context, imageSource);
    if (imageSource != null) {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: imageSource);
      if (image != null) {
        _imageFile = File(image.path);
        await _uploadImageToFirebase(email, majorKey);
      }
    }
  }

  Future<void> _uploadImageToFirebase(String email, String majorKey) async {
    Reference firebaseStorageRef = FirebaseStorage.instance.ref().child('profile/$email');
    await firebaseStorageRef.putFile(_imageFile!);
    await firebaseStorageRef.getDownloadURL().then((value) async {
      CollectionReference student = FirebaseFirestore.instance
          .collection(roleName)
          .doc(majorKey)
          .collection('${majorKey}_$roleName');
      await student.doc(email).update({'imageURL': value});
    });
  }

  Future<void> changePassword(String newPassword, String oldPassword, BuildContext context,
      String email, String majorKey, mounted) async {
    CollectionReference ref = FirebaseFirestore.instance
        .collection(roleName)
        .doc(majorKey)
        .collection('${majorKey}_$roleName');
    try {
      await FirebaseAuth.instance.currentUser!.updatePassword(newPassword);
      try {
        await ref.doc(email).update({'password': newPassword});
        if (!mounted) return;
        Components.successSnackBar(context, AppLocalizations.of(context)!.passwordChanged);
      } catch (e) {
        if (!mounted) return;
        Components.errorDialog(context, e.toString().split('. ')[1]);
      }
    } catch (e) {
      if (context.mounted) {
        Components.errorDialog(context, e.toString().split('. ')[1]);
      }
    }
  }
}
