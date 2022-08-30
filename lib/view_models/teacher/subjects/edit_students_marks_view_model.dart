import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EditStudentsMarksViewModel with ChangeNotifier {
  List<String> tableTitle = [];

  setTableTitle(BuildContext context) {
    AppLocalizations? localization = AppLocalizations.of(context);
    tableTitle = [
      localization!.subject,
      localization.midtermExam,
      localization.finalExam,
      localization.result
    ];
  }

  Future<DocumentSnapshot> getStudentMarks(
      String majorKey, String studentEmail, String subjectID) async {
    DocumentReference<Map<String, dynamic>> studentMarks = FirebaseFirestore.instance
        .collection('students_subjects')
        .doc(majorKey)
        .collection(studentEmail)
        .doc(subjectID);

    DocumentSnapshot response = await studentMarks.get();
    return response;
  }

  Future<void> updateStudentMarks(
      {required String majorKey,
      required String studentEmail,
      required String subjectID,
      required String midMark,
      required String finalMark,
      required String result}) async {
    DocumentReference<Map<String, dynamic>> studentMarksPath = FirebaseFirestore.instance
        .collection('students_subjects')
        .doc(majorKey)
        .collection(studentEmail)
        .doc(subjectID);

    try {
      await studentMarksPath.update({
        'mid': midMark.isEmpty ? '-' : midMark,
        'final': finalMark.isEmpty ? '-' : finalMark,
        'result': result.isEmpty ? '-' : result,
      });
    } catch (_) {
      rethrow;
    }
  }

  bool isLoading = true;

  void setIsLoading(bool newValue) {
    isLoading = newValue;
    notifyListeners();
  }

  bool isSaveLoading = false;

  void setIsSaveLoading(bool newValue) {
    isSaveLoading = newValue;
  }
}
