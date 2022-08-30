import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../res/components.dart';
import '../../../view_models/teacher/subjects/edit_students_marks_view_model.dart';
import '../../../view_models/teacher/subjects/students_subject_list_view_model.dart';
import 'edit_students_marks_view.dart';

class StudentsSubjectListView extends StatefulWidget {
  const StudentsSubjectListView({Key? key, required this.subjectID}) : super(key: key);
  final String subjectID;

  @override
  State<StudentsSubjectListView> createState() => _StudentsSubjectListViewState();
}

class _StudentsSubjectListViewState extends State<StudentsSubjectListView> {
  final StudentsSubjectListViewModel _viewModel = StudentsSubjectListViewModel();
  List<String> studentsEmail = [];

  List<Map<String, String>> studentsInformation = [];

  @override
  Widget build(BuildContext context) {
    AppLocalizations? localization = AppLocalizations.of(context);
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: Components.commonAppBar(
        localization!.studentsList,
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: _viewModel.getStudentsList(widget.subjectID),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return shimmerEffect(width);
          }
          if (snapshot.hasData) {
            final QuerySnapshot<Object?>? data = snapshot.data;
            final studentsData = data!.docs;
            return ListView.separated(
              itemCount: studentsData.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(studentsData[index]['imageURL']),
                  ),
                  title: Text(studentsData[index]['name']),
                  subtitle: Text(studentsData[index]['mobileNumber']),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => ChangeNotifierProvider(
                              create: (_) => EditStudentsMarksViewModel(),
                              child: EditStudentsMarksView(
                                studentName: studentsData[index]['name'],
                                studentEmail: studentsData[index]['email'],
                                subjectID: widget.subjectID,
                              ),
                            )));
                  },
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return const Divider();
              },
            );
          }
          return Center(
            child: Components.errorImage(localization),
          );
        },
      ),
    );
  }

  Padding shimmerEffect(double width) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[500]!,
        highlightColor: Colors.grey[100]!,
        child: ListView.separated(
          itemCount: 10,
          itemBuilder: (BuildContext context, int index) {
            return Row(
              children: [
                const CircleAvatar(
                  radius: 25.0,
                  backgroundColor: Colors.white,
                ),
                const SizedBox(
                  width: 16.0,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    shimmerContainer(width * 0.70, 20.0),
                    const SizedBox(
                      height: 4.0,
                    ),
                    shimmerContainer(width * 0.35, 20.0),
                  ],
                ),
              ],
            );
          },
          separatorBuilder: (BuildContext context, int index) {
            return const Divider();
          },
        ),
      ),
    );
  }

  Container shimmerContainer(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
      ),
    );
  }
}
