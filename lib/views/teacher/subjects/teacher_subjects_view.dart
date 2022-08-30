import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../res/colors.dart';
import '../../../res/components.dart';
import '../../../view_models/login/login_view_model.dart';
import '../../../view_models/teacher/subjects/teacher_subjects_view_model.dart';
import 'students_subject_list_view.dart';

class TeacherSubjectsView extends StatefulWidget {
  const TeacherSubjectsView({Key? key}) : super(key: key);

  @override
  State<TeacherSubjectsView> createState() => _TeacherSubjectsViewState();
}

class _TeacherSubjectsViewState extends State<TeacherSubjectsView> {
  final TeacherSubjectsViewModel _viewModel = TeacherSubjectsViewModel();

  @override
  Widget build(BuildContext context) {
    AppLocalizations? localization = AppLocalizations.of(context);
    String? email = Provider.of<LoginViewModel>(context).userEmail;
    String? majorKey = Provider.of<LoginViewModel>(context).majorKey;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: Components.commonAppBar(
        localization!.subjects,
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: _viewModel.getTeacherSubjects(email!, majorKey!),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return shimmerEffect(width);
          }
          if (snapshot.hasData) {
            List<QueryDocumentSnapshot<Object?>> data = snapshot.data!.docs;
            if (data.isEmpty) {
              return Center(child: Components.noDataImage(localization));
            }
            return ListView.separated(
              itemCount: data.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(data[index]['subjectName']),
                  subtitle: Wrap(
                    direction: Axis.horizontal,
                    children: [
                      Text(data[index]['classDays']),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: CircleAvatar(
                          radius: 2,
                          backgroundColor: CustomColors.greyColor,
                        ),
                      ),
                      Text('${data[index]['startTime']}-${data[index]['endTime']}'),
                    ],
                  ),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => StudentsSubjectListView(subjectID: data[index].id)));
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
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  shimmerContainer(width * 0.20, 20.0),
                  const SizedBox(
                    height: 4.0,
                  ),
                  shimmerContainer(width * 0.70, 20.0),
                ],
              );
            },
            separatorBuilder: (BuildContext context, int index) {
              return const Divider();
            },
          )),
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
