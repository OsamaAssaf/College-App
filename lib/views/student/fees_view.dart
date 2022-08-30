import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shimmer/shimmer.dart';

import '../../res/colors.dart';
import '../../res/components.dart';
import '../../view_models/login/login_view_model.dart';
import '../../view_models/student/fees_view_model.dart';

class FeesView extends StatelessWidget {
  FeesView({Key? key}) : super(key: key);

  final FeesViewModel _viewModel = FeesViewModel();

  @override
  Widget build(BuildContext context) {
    AppLocalizations? localization = AppLocalizations.of(context);
    double width = MediaQuery.of(context).size.width;
    final String? email = Provider.of<LoginViewModel>(context).userEmail;
    final String? majorKey = Provider.of<LoginViewModel>(context).majorKey;
    return Scaffold(
      appBar: Components.commonAppBar(
        localization!.fees,
      ),
      body: Center(
        child: FutureBuilder<QuerySnapshot>(
          future: _viewModel.getFees(email!, majorKey!),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return shimmerEffect(width);
            }
            if (snapshot.hasData) {
              List data = [];
              for (var element in snapshot.data!.docs) {
                data.add(element);
              }
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Table(
                    border: TableBorder.all(
                        borderRadius: BorderRadius.circular(5.0),
                        color: CustomColors.secondaryColor),
                    children: <TableRow>[
                      buildTableRow('Subject count', '${data.length} Subjects'),
                      buildTableRow('Subject cost', '${_viewModel.subjectCost} JOD'),
                      buildTableRow('Semester fee', '${_viewModel.semesterFee} JOD'),
                      buildTableRow(
                          'Total',
                          data.isEmpty
                              ? '0 JOD'
                              : '${(data.length * _viewModel.subjectCost!) + _viewModel.semesterFee!} JOD'),
                    ],
                  ),
                ),
              );
            }
            return Center(
              child: Components.errorImage(localization),
            );
          },
        ),
      ),
    );
  }

  TableRow buildTableRow(String title, String value) {
    return TableRow(children: [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          title,
          style: TextStyle(color: CustomColors.primaryTextColor),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          value,
          style: TextStyle(color: CustomColors.secondaryTextColor),
        ),
      ),
    ]);
  }

  Shimmer shimmerEffect(double width) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[500]!,
      highlightColor: Colors.grey[100]!,
      child: SizedBox(
        width: width,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Table(
              border: TableBorder.all(borderRadius: BorderRadius.circular(5.0)),
              children: <TableRow>[
                buildTableRow('Subject count', '0 Subjects'),
                buildTableRow('Subject cost', '0.0 JOD'),
                buildTableRow('Semester fee', '0.0 JOD'),
                buildTableRow('Total', '0.0 JOD'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Container shimmerContainer(double width, double height) {
    return Container(
      width: width,
      height: height,
      margin: const EdgeInsets.all(8.0),
    );
  }
}
