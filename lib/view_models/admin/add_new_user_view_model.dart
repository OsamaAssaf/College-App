import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../models/student_model.dart';
import '../../models/admin_model.dart';
import '../../models/teacher_model.dart';
import '../../res/components.dart';

class AddNewUserViewModel {
  List<String> genders = [
    'Male',
    'Female',
  ];

  Map<String, Object>? userData;

  void setUserData(int whoToAdd) {
    if (whoToAdd == 0) {
      userData = {
        'firstName': '',
        'middleName': '',
        'lastName': '',
        'gender': '',
        'address': '',
        'mobileNumber': '',
        'major': '',
        'year': 'first year',
        'result': 0.0,
        'numberOfSubjects': 0,
      };
    } else if (whoToAdd == 1) {
      userData = {
        'firstName': '',
        'middleName': '',
        'lastName': '',
        'gender': '',
        'address': '',
        'mobileNumber': '',
        'section': '',
        'yearsOfExperience': 0,
        'salary': 0.0,
      };
    } else {
      userData = {
        'firstName': '',
        'middleName': '',
        'lastName': '',
        'gender': '',
        'address': '',
        'mobileNumber': '',
        'section': '',
      };
    }
  }

  Future<void> submit(
      GlobalKey<FormState> formKey, BuildContext context, int whoToAdd, bool mounted) async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(
          child: CircularProgressIndicator.adaptive(),
        ),
      );
      try {
        await addNewUser(userData!, whoToAdd);
        if (!mounted) return;
        Components.successSnackBar(context, AppLocalizations.of(context)!.success);
      } catch (e) {
        Components.errorDialog(context, e.toString());
      } finally {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      }
    }
  }

  String nameFormatter(String name) {
    return name.toString().replaceFirst(name.toString()[0], name.toString()[0].toUpperCase());
  }

  String getFullName(String first, middle, last) {
    return '${nameFormatter(first)} ${nameFormatter(middle)} ${nameFormatter(last)}';
  }

  String getMajor(String major) {
    return '${major.toString()[0]}${major.toString().split(' ')[1][0]}';
  }

  Future<void> addNewUser(Map<String, Object> userData, int whoToAdd) async {
    Object? uniqueID;
    String email = '';
    String password = '';
    String fullName =
        getFullName(userData['firstName'].toString(), userData['middleName'], userData['lastName']);

    String imageURL = userData['gender'] == 'Male'
        ? 'https://firebasestorage.googleapis.com/v0/b/college-app-proj.appspot.com/o/placeholder%2Fmale_placeholder.jpg?alt=media&token=791f91cb-3562-4a86-888c-f04b33e23066'
        : 'https://firebasestorage.googleapis.com/v0/b/college-app-proj.appspot.com/o/placeholder%2Ffemale_placeholder.jpg?alt=media&token=5d79226d-c21c-4c26-b497-2929b6edb49d';

    String uniqueIDKey = '';
    String emailKey = '';
    String majorKey = '';

    String currentYear = DateTime.now().year.toString();

    if (whoToAdd == 0) {
      uniqueIDKey = 'studentUniqueID';
      majorKey = Components.majorsCode[userData['major'].toString()];
      emailKey = '${majorKey.toLowerCase()}@std.jo';
    } else if (whoToAdd == 1) {
      uniqueIDKey = 'teacherUniqueID';
      majorKey = Components.majorsCode[userData['section'].toString()];
      emailKey = '${majorKey.toLowerCase()}@thr.jo';
    } else {
      uniqueIDKey = 'adminUniqueID';
      majorKey = Components.majorsCode[userData['major'].toString()];
      emailKey = '${majorKey.toLowerCase()}@adm.jo';
    }

    try {
      final DatabaseReference ref = FirebaseDatabase.instance.ref();
      final snapshot = await ref.child(uniqueIDKey).get();
      uniqueID = snapshot.value;

      Map<String, Object?> updates = {};
      updates[uniqueIDKey] = true;
      updates[uniqueIDKey] = ServerValue.increment(1);
      await FirebaseDatabase.instance.ref().update(updates);

      email = '$currentYear$uniqueID$emailKey';
      password = '$currentYear$uniqueID';
      if (password.length < 6) {
        for (int i = password.length - 1; i < 6; i++) {
          password = '${password}x';
        }
      }
    } catch (e) {
      rethrow;
    }

    try {
      if (whoToAdd == 0) {
        StudentModel studentModel = StudentModel(
          idNumber: int.parse('$currentYear$uniqueID'),
          email: email,
          password: password,
          fullName: fullName,
          gender: userData['gender'].toString(),
          address: userData['address'].toString(),
          mobileNumber: userData['mobileNumber'].toString(),
          major: userData['major'].toString(),
          result: double.parse(userData['result'].toString()),
          numberOfSubjects: int.parse(userData['numberOfSubjects'].toString()),
          imageURL: imageURL,
        );

        await FirebaseFirestore.instance
            .collection('students')
            .doc(majorKey.toUpperCase())
            .collection('${majorKey}_students')
            .doc(email)
            .set(studentModel.toJSON());
      } else if (whoToAdd == 1) {
        TeacherModel teacherModel = TeacherModel(
          idNumber: int.parse('$currentYear$uniqueID'),
          email: email,
          password: password,
          fullName: fullName,
          gender: userData['gender'].toString(),
          address: userData['address'].toString(),
          mobileNumber: userData['mobileNumber'].toString(),
          yearsOfExperience: int.parse(userData['yearsOfExperience'].toString()),
          salary: double.parse(userData['salary'].toString()),
          section: userData['section'].toString(),
          imageURL: imageURL,
        );
        await FirebaseFirestore.instance
            .collection('teachers')
            .doc(majorKey.toUpperCase())
            .collection('${majorKey}_teachers')
            .doc(email)
            .set(teacherModel.toJSON());
      } else {
        AdminModel adminModel = AdminModel(
          idNumber: int.parse('$currentYear$uniqueID'),
          email: email,
          password: password,
          fullName: fullName,
          gender: userData['gender'].toString(),
          address: userData['address'].toString(),
          mobileNumber: userData['mobileNumber'].toString(),
          section: userData['section'].toString(),
          imageURL: imageURL,
        );
        await FirebaseFirestore.instance
            .collection('admins')
            .doc(majorKey.toUpperCase())
            .collection('${majorKey}_admins')
            .doc(email)
            .set(adminModel.toJSON());
      }
    } catch (e) {
      rethrow;
    }

    try {
      await registerNewUser(email, password);
    } catch (e) {
      if (whoToAdd == 0) {
        await FirebaseFirestore.instance
            .collection('students')
            .doc(userData['major'].toString())
            .collection(userData['year'].toString())
            .doc(email)
            .delete();
      } else if (whoToAdd == 1) {
        await FirebaseFirestore.instance
            .collection('teachers')
            .doc(userData['section'].toString())
            .collection(email)
            .doc(fullName)
            .delete();
      } else {
        await FirebaseFirestore.instance
            .collection('admins')
            .doc(userData['section'].toString())
            .collection(email)
            .doc(fullName)
            .delete();
      }
      rethrow;
    }
  }

  Future<void> registerNewUser(String email, String password) async {
    FirebaseApp tempApp =
        await Firebase.initializeApp(name: 'temporary_register', options: Firebase.app().options);
    try {
      await FirebaseAuth.instanceFor(app: tempApp)
          .createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (_) {
      rethrow;
    } finally {
      await tempApp.delete();
    }
  }
}
