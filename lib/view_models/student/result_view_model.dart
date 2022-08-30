import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ResultViewModel {
  List<String> tableTitle = [];

  setTableTitle(AppLocalizations? localization) {
    tableTitle = [
      '#',
      localization!.subject,
      localization.instructor,
      localization.midtermExam,
      localization.finalExam,
      localization.result
    ];
  }

  Future<QuerySnapshot> getResults(String email, String majorKey) {
    final CollectionReference<Map<String, dynamic>> currentSubjects =
        FirebaseFirestore.instance.collection('students_subjects').doc(majorKey).collection(email);
    return currentSubjects.get();
  }
}
