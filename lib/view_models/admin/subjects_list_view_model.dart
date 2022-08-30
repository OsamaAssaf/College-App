import 'package:cloud_firestore/cloud_firestore.dart';

class SubjectsListViewModel {
  Future<QuerySnapshot> getSubjectsByMajor(String majorKey) {
    final CollectionReference<Map<String, dynamic>> subjects = FirebaseFirestore.instance
        .collection('subjects')
        .doc(majorKey)
        .collection('${majorKey}_subjects');

    return subjects.get();
  }
}
