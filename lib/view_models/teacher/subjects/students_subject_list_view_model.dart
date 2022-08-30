import 'package:cloud_firestore/cloud_firestore.dart';

class StudentsSubjectListViewModel {
  Future<QuerySnapshot> getStudentsList(String subjectID) {
    CollectionReference<Map<String, dynamic>> studentsEmailFuture =
        FirebaseFirestore.instance.collection('subjects_students').doc('NET').collection(subjectID);
    return studentsEmailFuture.get();
  }
}
