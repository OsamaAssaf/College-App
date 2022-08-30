import 'package:cloud_firestore/cloud_firestore.dart';

class TeacherSubjectsViewModel {
  Future<QuerySnapshot> getTeacherSubjects(String email, String majorKey) {
    final Query<Map<String, dynamic>> teacherSubjects = FirebaseFirestore.instance
        .collection('subjects')
        .doc(majorKey)
        .collection('${majorKey}_subjects')
        .where('instructorEmail', isEqualTo: email);

    return teacherSubjects.get();
  }
}
