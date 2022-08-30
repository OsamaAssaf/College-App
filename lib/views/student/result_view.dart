import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shimmer/shimmer.dart';

import '../../res/colors.dart';
import '../../res/components.dart';
import '../../view_models/login/login_view_model.dart';
import '../../view_models/student/result_view_model.dart';

class ResultView extends StatelessWidget {
  ResultView({Key? key}) : super(key: key);

  final ResultViewModel _viewModel = ResultViewModel();

  @override
  Widget build(BuildContext context) {
    AppLocalizations? localization = AppLocalizations.of(context);
    double width = MediaQuery.of(context).size.width;
    _viewModel.setTableTitle(localization);
    final String? email = Provider.of<LoginViewModel>(context).userEmail;
    final String? majorKey = Provider.of<LoginViewModel>(context).majorKey;
    return Scaffold(
      appBar: Components.commonAppBar(
        localization!.result,
      ),
      body: InteractiveViewer(
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    localization.currentSemester,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24.0,
                        color: CustomColors.primaryTextColor),
                  ),
                  const SizedBox(
                    height: 16.0,
                  ),
                  FutureBuilder<QuerySnapshot>(
                    future: _viewModel.getResults(email!, majorKey!),
                    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return shimmerEffect(width);
                      }
                      if (snapshot.hasData) {
                        List data = [];
                        for (var element in snapshot.data!.docs) {
                          data.add(element);
                        }
                        return Table(
                          columnWidths: const {0: FractionColumnWidth(0.05)},
                          border: TableBorder.all(
                              color: CustomColors.secondaryColor,
                              borderRadius: BorderRadius.circular(5.0)),
                          children: [
                            TableRow(
                              children: _viewModel.tableTitle
                                  .map((title) => TableCell(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            title,
                                            style: TextStyle(color: CustomColors.primaryTextColor),
                                          ),
                                        ),
                                      ))
                                  .toList(),
                            ),
                            for (int i = 0; i < data.length; i++)
                              TableRow(
                                children: [
                                  buildTableCell('${i + 1}'),
                                  buildTableCell(data[i]['subjectName'].toString()),
                                  TableCell(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Tooltip(
                                        message: data[i]['instructorName'].toString(),
                                        child: Text(
                                          data[i]['instructorName'].toString(),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(color: CustomColors.primaryTextColor),
                                        ),
                                      ),
                                    ),
                                  ),
                                  buildTableCell("${data[i]['mid'].toString()}/30"),
                                  buildTableCell("${data[i]['final'].toString()}/50"),
                                  buildTableCell("${data[i]['result'].toString()}/100"),
                                ],
                              ),
                          ],
                        );
                      }
                      return Center(
                        child: Components.errorImage(localization),
                      );
                    },
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Divider(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  TableCell buildTableCell(String title) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          title,
          style: TextStyle(color: CustomColors.primaryTextColor),
        ),
      ),
    );
  }

  Shimmer shimmerEffect(double width) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[500]!,
      highlightColor: Colors.grey[100]!,
      child: SizedBox(
        width: width,
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Table(
                columnWidths: const {0: FractionColumnWidth(0.05)},
                border: TableBorder.all(borderRadius: BorderRadius.circular(5.0)),
                children: [
                  TableRow(
                    children: _viewModel.tableTitle
                        .map((title) => TableCell(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(title),
                              ),
                            ))
                        .toList(),
                  ),
                  for (int i = 0; i < 3; i++)
                    TableRow(
                      children: [
                        buildTableCell('${i + 1}'),
                        shimmerContainer(40, 20),
                        shimmerContainer(40, 20),
                        shimmerContainer(40, 20),
                        shimmerContainer(40, 20),
                        shimmerContainer(40, 20),
                      ],
                    ),
                ],
              ),
            ),
          ],
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
