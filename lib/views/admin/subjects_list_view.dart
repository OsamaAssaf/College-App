import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../res/colors.dart';
import '../../res/components.dart';
import '../../view_models/admin/subjects_list_view_model.dart';

class SubjectsListView extends StatelessWidget {
  SubjectsListView({Key? key}) : super(key: key);
  final List<String> majors = Components.majors;

  @override
  Widget build(BuildContext context) {
    AppLocalizations? localization = AppLocalizations.of(context);
    List<String> localizationMajors = Components.setMajors(context);
    return Scaffold(
      appBar: Components.commonAppBar(
        localization!.subjectsList,
      ),
      body: ListView.builder(
        itemCount: localizationMajors.length,
        itemBuilder: (BuildContext context, int index) {
          return Column(
            children: [
              ListTile(
                title: Text(localizationMajors[index]),
                trailing: const Icon(Icons.arrow_forward_ios_outlined),
                onTap: () {
                  String majorKey = Components.majorsCode[majors[index]];

                  showModalBottomSheet(
                    context: context,
                    builder: (ctx) {
                      return GetSubjects(localization, majorKey);
                    },
                  );
                },
              ),
              const Divider(),
            ],
          );
        },
      ),
    );
  }
}

class GetSubjects extends StatelessWidget {
  final String majorKey;
  final AppLocalizations? localization;

  GetSubjects(this.localization, this.majorKey, [Key? key]) : super(key: key);

  String get emptyMajorText {
    return localization!.noSubjectsMajor;
  }

  final SubjectsListViewModel _viewModel = SubjectsListViewModel();

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return SizedBox(
      height: height * 0.8,
      width: width,
      child: FutureBuilder<QuerySnapshot>(
        future: _viewModel.getSubjectsByMajor(majorKey),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return shimmerEffect(width);
          }
          if (snapshot.hasData) {
            if (snapshot.data!.size == 0) {
              return Center(
                child: FittedBox(
                  child: Text(
                    emptyMajorText,
                    style: TextStyle(color: CustomColors.primaryTextColor, fontSize: 20.0),
                  ),
                ),
              );
            }
            List<QueryDocumentSnapshot<Object?>> data = snapshot.data!.docs;
            return ListView.separated(
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: FittedBox(
                    child: Row(
                      children: [
                        Text('ID:${data[index]['subjectID']}'),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.0),
                          child: Text('|'),
                        ),
                        Text(
                            "${data[index]['subjectName'].toString()[0].toUpperCase()}${data[index]['subjectName'].toString().substring(1).toLowerCase()}"),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.0),
                          child: Text('|'),
                        ),
                        Text(
                          data[index]['instructorName'],
                        ),
                      ],
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data[index]['classDays']),
                      Text('${data[index]['startTime']} - ${data[index]['endTime']}'),
                    ],
                  ),
                  trailing: InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) {
                          return AlertDialog(
                            title: Text(localization!.areYouSure),
                            content: Text(data[index]['subjectName'].toString()),
                            actions: [
                              OutlinedButton(
                                onPressed: () {
                                  Navigator.pop(ctx);
                                },
                                child: Text(localization!.cancel),
                              ),
                              ElevatedButton(
                                  onPressed: () async {
                                    bool deleteResult = await _viewModel.deleteSubject(
                                        data[index]['subjectID'].toString(), majorKey);
                                    if (deleteResult == true) {
                                      Components.showSuccessToast(localization!.subjectDeleted);
                                      if (ctx.mounted) {
                                        Navigator.pop(ctx);
                                      }

                                      return;
                                    }
                                    if (deleteResult == false) {
                                      Components.showSuccessToast(localization!.subjectDeleted);
                                      if (ctx.mounted) {
                                        Navigator.pop(ctx);
                                      }
                                      return;
                                    }
                                  },
                                  child: Text(localization!.delete)),
                            ],
                          );
                        },
                      );
                    },
                    child: Icon(
                      Icons.delete_forever,
                      color: CustomColors.redColor,
                    ),
                  ),
                );
              },
              separatorBuilder: (BuildContext context, _) {
                return const Divider();
              },
              itemCount: data.length,
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
                Row(
                  children: [
                    shimmerContainer(width * 0.10, 15),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.0),
                      child: Text('|'),
                    ),
                    shimmerContainer(width * 0.20, 15),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.0),
                      child: Text('|'),
                    ),
                    shimmerContainer(width * 0.50, 15),
                  ],
                ),
                const SizedBox(
                  height: 4.0,
                ),
                shimmerContainer(width * 0.40, 15),
                const SizedBox(
                  height: 4.0,
                ),
                shimmerContainer(width * 0.35, 15),
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
