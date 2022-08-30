import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart' as database;

import '../../models/subject_model.dart';
import '../../res/components.dart';

class AddSubjectViewModel with ChangeNotifier {
  List<String> majors = Components.majors;

  final int stepCount = 5;
  int stepperIndex = 0;

  void setStepperIndex(int index) {
    stepperIndex = index;
    notifyListeners();
  }

  String majorRadioListTileValue = Components.majors[0];

  void setMajorRadioListTileValue(String newValue) {
    majorRadioListTileValue = newValue;
    notifyListeners();
  }

  String teacherRadioListTileValue = '';

  void setTeacherRadioListTileValue(String newValue) {
    teacherRadioListTileValue = newValue;
    notifyListeners();
  }

  String startTime = '';

  void setStartTime(String time) {
    startTime = time;
    notifyListeners();
  }

  String endTime = '';

  void setEndTime(String time) {
    endTime = time;
    notifyListeners();
  }

  ClassDays classDays = ClassDays.stt;

  void setClassDays(ClassDays days) {
    classDays = days;
    notifyListeners();
  }

  SubjectLevel subjectLevel = SubjectLevel.firstYear;

  void setSubjectLevel(SubjectLevel level) {
    subjectLevel = level;
    notifyListeners();
  }

  bool isLoading = false;

  void setIsLoading(bool newValue) {
    isLoading = newValue;
    notifyListeners();
  }

  Future<String> getSubjectID() async {
    final ref = database.FirebaseDatabase.instance.ref();
    final snapshot = await ref.child('subjectUniqueID').get();
    int uniqueID = snapshot.value as int;
    Map<String, Object?> updates = {};
    updates['subjectUniqueID'] = true;
    updates['subjectUniqueID'] = database.ServerValue.increment(1);
    await database.FirebaseDatabase.instance.ref().update(updates);
    return uniqueID.toString();
  }

  Future<QuerySnapshot> getTeachersByMajor(String majorKey) {
    final Query<Map<String, dynamic>> teachersList = FirebaseFirestore.instance
        .collection('teachers')
        .doc(majorKey)
        .collection('${majorKey}_teachers')
        .orderBy('fullName');
    return teachersList.get();
  }

  Future<void> addSubjectToDatabase(SubjectModel subjectModel, String majorKey) async {
    try {
      await FirebaseFirestore.instance
          .collection('subjects')
          .doc(majorKey)
          .collection('${majorKey}_subjects')
          .doc(subjectModel.subjectID)
          .set(subjectModel.toJSON());
    } catch (_) {
      rethrow;
    }
  }
}

enum ClassDays { stt, mw }

enum SubjectLevel { firstYear, secondYear, thirdYear, fourthYear, fifthYear }
