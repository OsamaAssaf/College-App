import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';

class FeesViewModel {
  double? subjectCost;
  double? semesterFee;

  Future<QuerySnapshot> getFees(String email, String majorKey) async {
    final CollectionReference<Map<String, dynamic>> subjects =
        FirebaseFirestore.instance.collection('students_subjects').doc(majorKey).collection(email);

    final DatabaseReference ref = FirebaseDatabase.instance.ref();
    final subjectCostSnapshot = await ref.child('subjectCost').get();
    final semesterFeeSnapshot = await ref.child('semesterFee').get();
    subjectCost = double.parse(subjectCostSnapshot.value.toString());
    semesterFee = double.parse(semesterFeeSnapshot.value.toString());

    return subjects.get();
  }
}
