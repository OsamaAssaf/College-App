import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

class StudentSubjectsViewModel with ChangeNotifier {
  bool isLoading = true;

  void setIsLoading(bool newValue) {
    isLoading = newValue;
    notifyListeners();
  }

  List<String> alreadyAddSubjects = [];

  setAlreadyAddSubjects(String subjectID) {
    alreadyAddSubjects.add(subjectID);
    notifyListeners();
  }

  Stream<QuerySnapshot> getSubjectsStream(String majorKey, int year) {
    final Query<Map<String, dynamic>> subjectsStream = FirebaseFirestore.instance
        .collection('subjects')
        .doc(majorKey)
        .collection('${majorKey}_subjects')
        .where('subjectLevel', isLessThanOrEqualTo: year)
        .orderBy('subjectLevel')
        .orderBy('subjectName');
    return subjectsStream.snapshots();
  }

  Future<void> initSubjectCheck(BuildContext context, String email, String majorKey) async {
    await FirebaseFirestore.instance
        .collection('students_subjects')
        .doc(majorKey)
        .collection(email)
        .get()
        .then((value) {
      for (var subject in value.docs) {
        Provider.of<StudentSubjectsViewModel>(context, listen: false)
            .setAlreadyAddSubjects(subject.id);
      }
    });
  }

  Future<void> addSubject({
    required String subjectID,
    required String subjectName,
    required String instructorName,
    required String instructorEmail,
    required String email,
    required String majorKey,
  }) async {
    final FirebaseFirestore db = FirebaseFirestore.instance;

    final DocumentSnapshot<Map<String, dynamic>> studentData = await db
        .collection('students')
        .doc(majorKey)
        .collection('${majorKey}_students')
        .doc(email)
        .get();

    db.collection('students_subjects').doc(majorKey).collection(email).doc(subjectID).set({
      'subjectID': subjectID,
      'subjectName': subjectName,
      'instructorName': instructorName,
      'instructorEmail': instructorEmail,
      'mid': '-',
      'final': '-',
      'result': '-',
    });
    db.collection('subjects_students').doc(majorKey).collection(subjectID).add({
      'name': studentData['fullName'],
      'email': email,
      'imageURL': studentData['imageURL'],
      'mobileNumber': studentData['mobileNumber']
    });
  }
}
