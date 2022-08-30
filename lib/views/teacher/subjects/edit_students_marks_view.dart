import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../res/colors.dart';
import '../../../res/components.dart';
import '../../../view_models/login/login_view_model.dart';
import '../../../view_models/teacher/subjects/edit_students_marks_view_model.dart';

class EditStudentsMarksView extends StatefulWidget {
  const EditStudentsMarksView(
      {Key? key, required this.studentEmail, required this.studentName, required this.subjectID})
      : super(key: key);

  final String studentEmail;
  final String studentName;
  final String subjectID;

  @override
  State<EditStudentsMarksView> createState() => _EditStudentsMarksViewState();
}

class _EditStudentsMarksViewState extends State<EditStudentsMarksView> {
  final EditStudentsMarksViewModel _viewModel = EditStudentsMarksViewModel();
  String? majorKey;
  DocumentSnapshot? studentsMarks;

  late TextEditingController _midController;
  late TextEditingController _finalController;
  late TextEditingController _resultController;
  late FocusNode _midFocusNode;
  late FocusNode _finalFocusNode;
  late FocusNode _resultFocusNode;

  @override
  void initState() {
    super.initState();
    majorKey = Provider.of<LoginViewModel>(context, listen: false).majorKey;
    _midController = TextEditingController();
    _finalController = TextEditingController();
    _resultController = TextEditingController();
    _midFocusNode = FocusNode();
    _finalFocusNode = FocusNode();
    _resultFocusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      studentsMarks =
          await _viewModel.getStudentMarks(majorKey!, widget.studentEmail, widget.subjectID);
      if (!mounted) return;
      Provider.of<EditStudentsMarksViewModel>(context, listen: false).setIsLoading(false);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _viewModel.setTableTitle(context);
  }

  @override
  void dispose() {
    super.dispose();
    _midController.dispose();
    _finalController.dispose();
    _resultController.dispose();
    _midFocusNode.dispose();
    _finalFocusNode.dispose();
    _resultFocusNode.dispose();
  }

  setInitialControllersValue(DocumentSnapshot data) {
    if (data['mid'] != '-') {
      _midController = TextEditingController(text: data['mid']);
    }
    if (data['final'] != '-') {
      _finalController = TextEditingController(text: data['final']);
    }
    if (data['result'] != '-') {
      _resultController = TextEditingController(text: data['result']);
    }
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations? localization = AppLocalizations.of(context);
    return Scaffold(
      appBar:
          Components.commonAppBar(localization!.studentMarks, actions: [saveButton(localization)]),
      body: Consumer<EditStudentsMarksViewModel>(
        builder: (BuildContext context, EditStudentsMarksViewModel provider, _) {
          if (provider.isLoading) {
            return shimmerEffect();
          }
          if (studentsMarks != null) {
            setInitialControllersValue(studentsMarks!);
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text(
                          widget.studentName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24.0,
                            color: CustomColors.primaryTextColor,
                          ),
                        ),
                        const SizedBox(
                          height: 4.0,
                        ),
                        Text(
                          widget.studentEmail,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22.0,
                            color: CustomColors.primaryTextColor,
                          ),
                        ),
                        const SizedBox(
                          height: 8.0,
                        ),
                        Text(
                          studentsMarks!['subjectName'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0,
                            color: CustomColors.primaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Table(
                      columnWidths: const {0: FractionColumnWidth(0.30)},
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
                        TableRow(
                          children: [
                            buildTableCell(studentsMarks!['subjectName'].toString()),
                            buildMarksTableCell(_midController, '/30', _midFocusNode),
                            buildMarksTableCell(_finalController, '/50', _finalFocusNode),
                            buildMarksTableCell(_resultController, '/100', _resultFocusNode),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
          return Center(
            child: Components.errorImage(localization),
          );
        },
      ),
    );
  }

  TableCell buildMarksTableCell(
      TextEditingController controller, String text, FocusNode focusNode) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                style: TextStyle(color: CustomColors.secondaryTextColor),
                controller: controller,
                focusNode: focusNode,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    border:
                        UnderlineInputBorder(borderSide: BorderSide(color: CustomColors.greyColor)),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: CustomColors.secondaryColor)),
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: CustomColors.secondaryColor))),
              ),
            ),
            Text(
              text,
              style: TextStyle(color: CustomColors.secondaryTextColor),
            ),
          ],
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
          style: TextStyle(color: CustomColors.secondaryTextColor),
        ),
      ),
    );
  }

  Consumer saveButton(AppLocalizations? localization) {
    _midFocusNode.unfocus();
    _finalFocusNode.unfocus();
    _resultFocusNode.unfocus();
    return Consumer<EditStudentsMarksViewModel>(
      builder: (BuildContext context, EditStudentsMarksViewModel provider, _) {
        return TextButton.icon(
          onPressed: provider.isSaveLoading
              ? null
              : () async {
                  if (_midController.text.isNotEmpty &&
                      double.tryParse(_midController.text) == null) {
                    Components.showToast('Please enter a valid marks');
                    return;
                  }
                  if (_finalController.text.isNotEmpty &&
                      double.tryParse(_finalController.text) == null) {
                    Components.showToast('Please enter a valid marks');
                    return;
                  }
                  if (_resultController.text.isNotEmpty &&
                      double.tryParse(_resultController.text) == null) {
                    Components.showToast('Please enter a valid marks');
                    return;
                  }
                  if (double.tryParse(_midController.text) != null &&
                          double.parse(_midController.text) < 0 ||
                      double.tryParse(_finalController.text) != null &&
                          double.parse(_finalController.text) < 0 ||
                      double.tryParse(_resultController.text) != null &&
                          double.parse(_resultController.text) < 0) {
                    Components.showToast('Marks can not be negative.');
                    return;
                  }
                  if (double.tryParse(_midController.text) != null &&
                          double.parse(_midController.text) > 30 ||
                      double.tryParse(_finalController.text) != null &&
                          double.parse(_finalController.text) > 50 ||
                      double.tryParse(_resultController.text) != null &&
                          double.parse(_resultController.text) > 100) {
                    Components.showToast('Marks can not go over the limits.');
                    return;
                  }
                  try {
                    provider.setIsSaveLoading(true);
                    await _viewModel.updateStudentMarks(
                      majorKey: majorKey!,
                      studentEmail: widget.studentEmail,
                      subjectID: widget.subjectID,
                      midMark: _midController.text,
                      finalMark: _finalController.text,
                      result: _resultController.text,
                    );
                    provider.setIsSaveLoading(false);
                  } catch (e) {
                    provider.setIsSaveLoading(false);
                    Components.errorDialog(context, e.toString());
                  }
                },
          icon: provider.isSaveLoading
              ? const CircularProgressIndicator()
              : const Icon(
                  Icons.save_outlined,
                ),
          label: Text(
            localization!.save,
          ),
        );
      },
    );
  }

  Shimmer shimmerEffect() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[500]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                shimmerContainer(0.70, 25.0),
                const SizedBox(
                  height: 8.0,
                ),
                shimmerContainer(0.50, 20.0),
                const SizedBox(
                  height: 8.0,
                ),
                shimmerContainer(0.15, 20.0),
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Table(
              columnWidths: const {0: FractionColumnWidth(0.30)},
              border: TableBorder.all(borderRadius: BorderRadius.circular(5.0)),
              children: [
                TableRow(
                  children: _viewModel.tableTitle
                      .map(
                        (title) => TableCell(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(title),
                          ),
                        ),
                      )
                      .toList(),
                ),
                TableRow(
                  children: [
                    buildTableCell('Subject name'),
                    for (int i = 0; i < 3; i++)
                      const TableCell(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: TextField(
                            readOnly: true,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  FractionallySizedBox shimmerContainer(double widthFactor, double height) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.0),
        ),
      ),
    );
  }
}
