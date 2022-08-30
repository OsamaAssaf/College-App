import 'package:college_app/res/colors.dart';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../res/components.dart';

class EndSemesterViewModel {
  Future<void> endCurrentSemester(BuildContext context, AppLocalizations? localization) async {
    try {
      await calculateAverage(context, localization);
    } catch (e) {
      rethrow;
    }
    try {
      await deleteAllSubjects();
      await deleteAllEvents();
    } catch (_) {
      rethrow;
    }
  }

  Future<void> calculateAverage(BuildContext context, AppLocalizations? localization) async {
    CollectionReference<Map<String, dynamic>> studentsSubjects =
        FirebaseFirestore.instance.collection('students_subjects');
    CollectionReference<Map<String, dynamic>> students =
        FirebaseFirestore.instance.collection('students');
    Map majorsCode = Components.majorsCode;
    for (var value in majorsCode.values) {
      /// get student emails
      CollectionReference<Map<String, dynamic>> student =
          students.doc(value).collection('${value}_students');
      QuerySnapshot<Map<String, dynamic>> studentsEmails = await student.get();
      final res1 = studentsEmails.docs;
      if (res1.isNotEmpty) {
        for (var element in res1) {
          String email = element.data()['email'];
          double avg = double.parse(element.data()['result'].toString());
          int numberOfSubjects = element.data()['numberOfSubjects'];

          /// get student subjects
          final subjectsForStudents = await studentsSubjects.doc(value).collection(email).get();
          final res2 = subjectsForStudents.docs;
          if (res2.isNotEmpty) {
            List<double> studentResults = [];
            for (var subject in res2) {
              if (subject.data()['result'] == '-') {
                showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                          backgroundColor: CustomColors.cardColor,
                          content: Text(
                            localization!.ensureGradesCalculated,
                            style: TextStyle(
                              color: CustomColors.primaryTextColor,
                            ),
                          ),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text(localization.ok)),
                          ],
                        ));
                throw 'error';
              }
              studentResults.add(double.parse(subject.data()['result']));
            }
            double studentAvg = 0.0;
            for (var element in studentResults) {
              studentAvg += element;
            }
            int newNumberOfSubjects = numberOfSubjects + studentResults.length;
            double newAvg = ((avg * studentResults.length) + (studentAvg)) / (newNumberOfSubjects);
            await student.doc(email).update({
              'result': newAvg,
              'numberOfSubjects': newNumberOfSubjects,
            });
          }
        }
      }
    }
  }

  Future<void> deleteAllSubjects() async {
    Map majorsCode = Components.majorsCode;
    try {
      for (var value in majorsCode.values) {
        await FirebaseFirestore.instance
            .collection('subjects')
            .doc(value)
            .collection('${value}_subjects')
            .get()
            .then((value) async {
          for (var element in value.docs) {
            await element.reference.delete();
          }
        });
      }

      CollectionReference<Map<String, dynamic>> students =
          FirebaseFirestore.instance.collection('students');
      for (var value in majorsCode.values) {
        CollectionReference<Map<String, dynamic>> student =
            students.doc(value).collection('${value}_students');
        QuerySnapshot<Map<String, dynamic>> studentsEmails = await student.get();
        final List<QueryDocumentSnapshot<Map<String, dynamic>>> res1 = studentsEmails.docs;
        if (res1.isNotEmpty) {
          for (var element in res1) {
            String email = element.data()['email'];
            await FirebaseFirestore.instance
                .collection('students_subjects')
                .doc(value)
                .collection(email)
                .get()
                .then((value) async {
              for (var element in value.docs) {
                await element.reference.delete();
              }
            });
          }
        }
      }

      int totalNumberOfSubjects = 0;
      final ref = FirebaseDatabase.instance.ref();
      final snapshot = await ref.child('subjectUniqueID').get();
      if (snapshot.exists) {
        totalNumberOfSubjects = int.parse(snapshot.value.toString());
      }

      for (int i = 1; i <= totalNumberOfSubjects; i++) {
        for (var value in majorsCode.values) {
          await FirebaseFirestore.instance
              .collection('subjects_students')
              .doc(value)
              .collection(i.toString())
              .get()
              .then((value) async {
            for (var element in value.docs) {
              await element.reference.delete();
            }
          });
        }
      }
    } catch (_) {
      rethrow;
    }
  }

  Future<void> deleteAllEvents() async {
    try {
      await FirebaseFirestore.instance.collection('calendar_events').get().then((value) async {
        for (var element in value.docs) {
          await element.reference.delete();
        }
      });
      await FirebaseStorage.instance.ref().child('events').listAll().then((value) async {
        for (var element in value.items) {
          await FirebaseStorage.instance.ref(element.fullPath).delete();
        }
      });
    } catch (_) {
      rethrow;
    }
  }
}
