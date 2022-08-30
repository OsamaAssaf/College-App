import 'dart:io';

import 'package:college_app/res/components.dart';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/calender_event_model.dart';

class AddEventViewModel with ChangeNotifier {
  File? imageFile;

  Future<void> pickImage(BuildContext context) async {
    ImageSource? imageSource;
    imageSource = await Components.pickImageAlert(context, imageSource);
    if (imageSource != null) {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: imageSource);
      if (image != null) {
        imageFile = File(image.path);
        notifyListeners();
      }
    }
  }

  Future<int> getEventID() async {
    final DatabaseReference ref = FirebaseDatabase.instance.ref();
    final snapshot = await ref.child('eventID').get();
    int eventID = int.parse(snapshot.value.toString());

    Map<String, Object?> updates = {};
    updates['eventID'] = true;
    updates['eventID'] = ServerValue.increment(1);
    await FirebaseDatabase.instance.ref().update(updates);
    return eventID;
  }

  Future<String?> uploadImageToFirebase(int eventID, File imageFile) async {
    Reference firebaseStorageRef = FirebaseStorage.instance.ref().child('events/$eventID');
    String? url;
    try {
      await firebaseStorageRef.putFile(imageFile);
      url = await firebaseStorageRef.getDownloadURL().then((value) async {
        return value;
      });
      return url;
    } catch (_) {
      return url;
    }
  }

  Future<void> uploadEvent(CalenderEventModel eventModel, DateTime selectedDay) async {
    String date = selectedDay.toIso8601String().split('T')[0];
    final DocumentReference<Map<String, dynamic>> eventPath =
        FirebaseFirestore.instance.collection('calendar_events').doc(date);
    await eventPath
        .set({eventModel.eventID.toString(): eventModel.toJSON()}, SetOptions(merge: true));
  }

  bool isLoading = false;

  void setIsLoading(bool newValue) {
    isLoading = newValue;
    notifyListeners();
  }
}
