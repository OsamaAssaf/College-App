import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../res/colors.dart';
import '../../res/components.dart';
import '../../view_models/login/login_view_model.dart';
import '../../view_models/student/students_subjects_view_model.dart';

class StudentSubjectsView extends StatefulWidget {
  const StudentSubjectsView({Key? key}) : super(key: key);

  @override
  State<StudentSubjectsView> createState() => _StudentSubjectsViewState();
}

class _StudentSubjectsViewState extends State<StudentSubjectsView> {
  final StudentSubjectsViewModel _viewModel = StudentSubjectsViewModel();

  late String? majorKey;
  late String? email;

  @override
  void initState() {
    email = Provider.of<LoginViewModel>(context, listen: false).userEmail;
    majorKey = Provider.of<LoginViewModel>(context, listen: false).majorKey;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _viewModel.initSubjectCheck(context, email!, majorKey!);
      if (!mounted) return;
      Provider.of<StudentSubjectsViewModel>(context, listen: false).setIsLoading(false);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations? localization = AppLocalizations.of(context);
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: Components.commonAppBar(
        localization!.subjects,
      ),
      body: Consumer<StudentSubjectsViewModel>(
        builder: (BuildContext context, StudentSubjectsViewModel provider, _) {
          if (provider.isLoading) {
            return shimmerEffect(width);
          }
          int? year = Provider.of<LoginViewModel>(context).year;
          return StreamBuilder<QuerySnapshot>(
            stream: _viewModel.getSubjectsStream(majorKey!, year!),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return shimmerEffect(width);
              }
              if (snapshot.hasData) {
                List<QueryDocumentSnapshot<Object?>> data = snapshot.data!.docs;
                if (data.isEmpty) {
                  return Center(
                    child: Components.noDataImage(localization),
                  );
                }
                return ListView.separated(
                  itemCount: data.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Consumer<StudentSubjectsViewModel>(
                      builder: (BuildContext context, StudentSubjectsViewModel value, _) {
                        return ListTile(
                          title: Text(data[index]['subjectName']),
                          subtitle: Wrap(
                            direction: Axis.horizontal,
                            children: [
                              Text(data[index]['instructorName']),
                              const SizedBox(width: 8.0),
                              Text('${data[index]['startTime']}-${data[index]['endTime']}'),
                            ],
                          ),
                          trailing: TextButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                CustomColors.secondaryColor,
                              ),
                            ),
                            onPressed: value.alreadyAddSubjects.contains(data[index].id)
                                ? null
                                : () {
                                    Provider.of<StudentSubjectsViewModel>(context, listen: false)
                                        .setAlreadyAddSubjects(data[index].id);

                                    _viewModel.addSubject(
                                      subjectID: data[index].id,
                                      subjectName: data[index]['subjectName'],
                                      instructorName: data[index]['instructorName'],
                                      instructorEmail: data[index]['instructorEmail'],
                                      email: email!,
                                      majorKey: majorKey!,
                                    );
                                  },
                            child: Text(
                              localization.add,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: value.alreadyAddSubjects.contains(data[index].id)
                                    ? CustomColors.greyColor
                                    : CustomColors.secondaryTextColor,
                              ),
                            ),
                          ),
                        );
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      shimmerContainer(width * 0.20, 20.0),
                      const SizedBox(
                        height: 4.0,
                      ),
                      shimmerContainer(width * 0.35, 20.0),
                      const SizedBox(
                        height: 4.0,
                      ),
                      shimmerContainer(width * 0.40, 20.0),
                    ],
                  ),
                  shimmerContainer(50.0, 30.0),
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
