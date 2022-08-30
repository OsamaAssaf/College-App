import 'package:cloud_firestore/cloud_firestore.dart';

class UsersListViewModel {
  Stream<QuerySnapshot> getUsersByMajor(String collId, String majorKey) {
    CollectionReference users = FirebaseFirestore.instance
        .collection(collId)
        .doc(majorKey)
        .collection('${majorKey}_$collId');
    return users.snapshots();
  }
}
