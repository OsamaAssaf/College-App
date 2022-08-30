import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../res/components.dart';

class ProfileForEditViewModel with ChangeNotifier {
  String? roleName;
  String? userMajorKey;

  String getLocalizationMajor(BuildContext context, String majorInEnglish) {
    List<String> localizationMajors = Components.setMajors(context);
    int i = Components.majors.indexOf(majorInEnglish);
    return localizationMajors[i];
  }

  void setUserData(int role, String userEmail) {
    int i = userEmail.indexOf('@');
    userMajorKey = '${userEmail[i - 3]}${userEmail[i - 2]}${userEmail[i - 1]}'.toUpperCase();
    if (role == 0) {
      roleName = 'students';
    } else if (role == 1) {
      roleName = 'teachers';
    } else {
      roleName = 'admins';
    }
  }

  String? userName;
  String? mobileNumber;
  double? salary;

  void setSomeData(int role, DocumentSnapshot userData) {
    userName = userData['fullName'];
    mobileNumber = userData['mobileNumber'];
    if (role == 1) {
      salary = userData['salary'];
    }
    notifyListeners();
  }

  void changeUserName(String newValue) {
    userName = newValue;
    notifyListeners();
  }

  void changeMobileNumber(String newValue) {
    mobileNumber = newValue;
    notifyListeners();
  }

  void changeSalary(double newValue) {
    salary = newValue;
    notifyListeners();
  }

  String? userPassword;

  void setUserPassword(String? newValue) {
    userPassword = newValue;
    notifyListeners();
  }

  Future<void> updateUserName(String userEmail, String newName) async {
    DocumentReference<Map<String, dynamic>> userDataPath = FirebaseFirestore.instance
        .collection(roleName!)
        .doc(userMajorKey!)
        .collection('${userMajorKey}_$roleName')
        .doc(userEmail);
    try {
      await userDataPath.update({
        'fullName': newName,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateMobileNumber(String userEmail, String newNumber) async {
    DocumentReference<Map<String, dynamic>> userDataPath = FirebaseFirestore.instance
        .collection(roleName!)
        .doc(userMajorKey!)
        .collection('${userMajorKey}_$roleName')
        .doc(userEmail);
    try {
      await userDataPath.update({
        'mobileNumber': newNumber,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateSalary(String userEmail, double newSalary) async {
    DocumentReference<Map<String, dynamic>> userDataPath = FirebaseFirestore.instance
        .collection(roleName!)
        .doc(userMajorKey!)
        .collection('${userMajorKey}_$roleName')
        .doc(userEmail);
    try {
      await userDataPath.update({
        'salary': newSalary,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteUser(String userEmail) async {
    DocumentReference<Map<String, dynamic>> userPath = FirebaseFirestore.instance
        .collection(roleName!)
        .doc(userMajorKey!)
        .collection('${userMajorKey}_$roleName')
        .doc(userEmail);

    try {
      await userPath.delete();
    } catch (_) {
      rethrow;
    }
  }
}
