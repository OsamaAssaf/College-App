import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../models/subject_model.dart';
import '../../res/colors.dart';
import '../../res/components.dart';
import '../../view_models/admin/add_subject_view_model.dart';

class AddSubjectView extends StatefulWidget {
  const AddSubjectView({Key? key}) : super(key: key);

  @override
  State<AddSubjectView> createState() => _AddSubjectViewState();
}

class _AddSubjectViewState extends State<AddSubjectView> {
  final AddSubjectViewModel _viewModel = AddSubjectViewModel();
  late TextEditingController _subjectNameController;

  String? _instructorName;
  String? _instructorEmail;
  late List<String> localizationMajor;

  @override
  void initState() {
    _subjectNameController = TextEditingController();
    super.initState();
  }

  _submit(AddSubjectViewModel provider, AppLocalizations? localization) async {
    if (_subjectNameController.text.isEmpty) {
      Components.showToast(localization!.enterSubjectName);
      return;
    }
    if (_instructorName == null || _instructorName == '') {
      Components.showToast(localization!.mustChooseInstructor);
      return;
    }
    if (provider.startTime.isEmpty) {
      Components.showToast(localization!.mustChooseStartTime);
      return;
    }
    if (provider.endTime.isEmpty) {
      Components.showToast(localization!.mustChooseEndTime);
      return;
    }
    String classDays = '';
    if (provider.classDays == ClassDays.stt) {
      classDays = 'Sunday, Tuesday, Thursday';
    } else {
      classDays = 'Monday, Wednesday';
    }
    String subjectID = await provider.getSubjectID();
    int subjectLevel = 1;
    switch (provider.subjectLevel) {
      case SubjectLevel.firstYear:
        subjectLevel = 1;
        break;
      case SubjectLevel.secondYear:
        subjectLevel = 2;
        break;
      case SubjectLevel.thirdYear:
        subjectLevel = 3;
        break;
      case SubjectLevel.fourthYear:
        subjectLevel = 4;
        break;
      case SubjectLevel.fifthYear:
        subjectLevel = 5;
        break;
    }
    SubjectModel subjectModel = SubjectModel(
      subjectID: subjectID,
      subjectName: _subjectNameController.text,
      instructorName: _instructorName,
      instructorEmail: _instructorEmail,
      classDays: classDays,
      startTime: provider.startTime,
      endTime: provider.endTime,
      subjectLevel: subjectLevel,
    );
    provider.setIsLoading(true);
    try {
      String majorKey = Components.majorsCode[provider.majorRadioListTileValue];
      await _viewModel.addSubjectToDatabase(subjectModel, majorKey);
      if (!mounted) return;
      Components.showSuccessToast(AppLocalizations.of(context)!.success);
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      Components.errorDialog(context, e.toString());
    }
    provider.setIsLoading(true);
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    AppLocalizations? localization = AppLocalizations.of(context);
    List<String> localizationMajor = Components.setMajors(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: Components.commonAppBar(
        localization!.addSubject,
      ),
      body: Consumer<AddSubjectViewModel>(
        builder: (BuildContext context, AddSubjectViewModel provider, _) {
          return SingleChildScrollView(
            child: Column(
              children: [
                Theme(
                  data: ThemeData(
                    elevatedButtonTheme: ElevatedButtonThemeData(
                      style: ButtonStyle(
                        textStyle: MaterialStateProperty.all<TextStyle>(
                            const TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0)),
                        foregroundColor:
                            MaterialStateProperty.all<Color>(CustomColors.primaryTextColor),
                        backgroundColor:
                            MaterialStateProperty.all<Color>(CustomColors.secondaryColor),
                      ),
                    ),
                    textButtonTheme: TextButtonThemeData(
                      style: ButtonStyle(
                          foregroundColor:
                              MaterialStateProperty.all<Color>(CustomColors.secondaryTextColor),
                          textStyle: MaterialStateProperty.all<TextStyle>(
                              const TextStyle(fontWeight: FontWeight.bold))),
                    ),
                    outlinedButtonTheme: OutlinedButtonThemeData(
                        style: ButtonStyle(
                            foregroundColor:
                                MaterialStateProperty.all<Color>(CustomColors.primaryTextColor),
                            textStyle: MaterialStateProperty.all<TextStyle>(
                              const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            side: MaterialStateProperty.all<BorderSide>(
                                BorderSide(color: CustomColors.secondaryColor)))),
                    inputDecorationTheme: InputDecorationTheme(
                        fillColor: const Color.fromRGBO(113, 93, 109, 1.0).withOpacity(0.5),
                        filled: true,
                        hintStyle:
                            TextStyle(color: CustomColors.secondaryTextColor.withOpacity(0.6)),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: CustomColors.secondaryColor),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: CustomColors.greyColor),
                        )),
                    radioTheme: RadioThemeData(
                      fillColor: MaterialStateProperty.all<Color>(CustomColors.secondaryColor),
                    ),
                    colorScheme:
                        Theme.of(context).colorScheme.copyWith(brightness: Brightness.dark),
                  ),
                  child: Stepper(
                    physics: const ClampingScrollPhysics(),
                    controlsBuilder: (BuildContext context, ControlsDetails details) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            if (provider.stepperIndex != 0)
                              TextButton(
                                onPressed: details.onStepCancel,
                                child: Text(
                                  localization.previous,
                                ),
                              ),
                            const SizedBox(
                              width: 4.0,
                            ),
                            if (provider.stepperIndex != provider.stepCount - 1)
                              OutlinedButton(
                                onPressed: details.onStepContinue,
                                child: Text(
                                  localization.next,
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                    currentStep: provider.stepperIndex,
                    onStepContinue: () {
                      provider.setStepperIndex(provider.stepperIndex + 1);
                    },
                    onStepCancel: () {
                      provider.setStepperIndex(provider.stepperIndex - 1);
                    },
                    onStepTapped: (int index) {
                      provider.setStepperIndex(index);
                    },
                    steps: [
                      subjectNameStep(provider, localization),
                      selectMajorStep(localizationMajor, provider, localization),
                      selectTeacherStep(provider, context, localization),
                      selectTimeStep(provider, context, localization),
                      selectSubjectLevelStep(provider, context, localization),
                    ],
                  ),
                ),
                SizedBox(
                  width: 120.0,
                  child: ElevatedButton(
                    onPressed: provider.isLoading
                        ? null
                        : () async {
                            await _submit(provider, localization);
                          },
                    child: !provider.isLoading
                        ? Text(localization.add)
                        : const CircularProgressIndicator(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Step subjectNameStep(AddSubjectViewModel provider, AppLocalizations? localization) {
    return Step(
      title: Text(
        localization!.subjectName,
        style: TextStyle(color: CustomColors.primaryTextColor),
      ),
      content: Container(
        alignment: Alignment.centerLeft,
        child: TextField(
          style: TextStyle(color: CustomColors.secondaryTextColor),
          controller: _subjectNameController,
          cursorColor: CustomColors.secondaryColor,
        ),
      ),
    );
  }

  Step selectMajorStep(List<String> localizationMajor, AddSubjectViewModel provider,
      AppLocalizations? localization) {
    return Step(
      title: Text(
        localization!.section,
        style: TextStyle(color: CustomColors.primaryTextColor),
      ),
      content: Container(
        alignment: Alignment.centerLeft,
        child: SingleChildScrollView(
          child: Column(
            children: [
              for (int i = 0; i < localizationMajor.length; i++)
                RadioListTile(
                  title: Text(
                    localizationMajor[i],
                    style: TextStyle(color: CustomColors.primaryTextColor),
                  ),
                  value: _viewModel.majors[i],
                  groupValue: provider.majorRadioListTileValue,
                  onChanged: (String? newValue) {
                    _instructorName = '';
                    Provider.of<AddSubjectViewModel>(context, listen: false)
                        .setTeacherRadioListTileValue('');
                    Provider.of<AddSubjectViewModel>(context, listen: false)
                        .setMajorRadioListTileValue(newValue!);
                  },
                )
            ],
          ),
        ),
      ),
    );
  }

  Step selectTeacherStep(
      AddSubjectViewModel provider, BuildContext context, AppLocalizations? localization) {
    return Step(
      title: Text(
        localization!.instructorName,
        style: TextStyle(color: CustomColors.primaryTextColor),
      ),
      content: Container(
        alignment: AlignmentDirectional.centerStart,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              child: Text(localization.chooseInstructor),
              onPressed: () {
                final width = MediaQuery.of(context).size.width;
                final String majorKey = Components.majorsCode[provider.majorRadioListTileValue];
                _instructorName = '';
                Provider.of<AddSubjectViewModel>(context, listen: false)
                    .setTeacherRadioListTileValue('');
                showBottomSheet(
                  context: context,
                  backgroundColor: CustomColors.cardColor,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15.0),
                      topRight: Radius.circular(15.0),
                    ),
                  ),
                  builder: (_) {
                    return SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.75,
                      child: Column(
                        children: [
                          Align(
                            alignment: AlignmentDirectional.topEnd,
                            child: IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ),
                          FutureBuilder<QuerySnapshot>(
                            future: _viewModel.getTeachersByMajor(majorKey),
                            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Expanded(child: shimmerEffect(width));
                              }
                              if (snapshot.hasData) {
                                List data = snapshot.data!.docs;

                                /// if data = 0
                                List teachersName =
                                    data.map((element) => element['fullName']).toList();
                                List teachersEmail =
                                    data.map((element) => element['email']).toList();
                                return Expanded(
                                  child: ListView.builder(
                                      itemCount: teachersName.length,
                                      itemBuilder: (BuildContext context, int index) {
                                        return RadioListTile<String>(
                                          title: Text(teachersName[index]),
                                          value: teachersName[index],
                                          groupValue: Provider.of<AddSubjectViewModel>(context)
                                              .teacherRadioListTileValue,
                                          onChanged: (String? newValue) {
                                            _instructorName = newValue;
                                            _instructorEmail = teachersEmail[index];
                                            Provider.of<AddSubjectViewModel>(context, listen: false)
                                                .setTeacherRadioListTileValue(newValue!.toString());
                                          },
                                        );
                                      }),
                                );
                              }
                              return Center(
                                child: Components.errorImage(localization),
                              );
                            },
                          ),
                          Align(
                            alignment: AlignmentDirectional.bottomCenter,
                            child: SizedBox(
                              width: 120.0,
                              child: ElevatedButton(
                                child: Text(localization.done),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
            if (_instructorName != null && _instructorName!.isNotEmpty)
              Text(
                '${localization.instructorName}:',
                style: TextStyle(color: CustomColors.primaryTextColor, fontSize: 20.0),
              ),
            if (_instructorName != null && _instructorName!.isNotEmpty)
              Text(
                '   ${_instructorName!}',
                style: TextStyle(color: CustomColors.secondaryTextColor, fontSize: 20.0),
              )
          ],
        ),
      ),
    );
  }

  Step selectTimeStep(
      AddSubjectViewModel provider, BuildContext context, AppLocalizations? localization) {
    return Step(
      title: Text(
        localization!.classTime,
        style: TextStyle(color: CustomColors.primaryTextColor),
      ),
      content: Container(
        alignment: AlignmentDirectional.centerStart,
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: [
            RadioListTile(
              title: Text(
                localization.sundayTuesdayThursday,
                style: TextStyle(color: CustomColors.primaryTextColor),
              ),
              value: ClassDays.stt,
              groupValue: provider.classDays,
              onChanged: (ClassDays? days) {
                provider.setClassDays(days!);
              },
            ),
            RadioListTile(
              title: Text(
                localization.mondayWednesday,
                style: TextStyle(color: CustomColors.primaryTextColor),
              ),
              value: ClassDays.mw,
              groupValue: provider.classDays,
              onChanged: (ClassDays? days) {
                provider.setClassDays(days!);
              },
            ),
            Row(
              children: [
                OutlinedButton(
                  onPressed: () async {
                    await showTimePicker(
                      context: context,
                      initialTime: const TimeOfDay(hour: 8, minute: 0),
                    ).then((time) {
                      if (time != null) {
                        provider.setStartTime(
                            time.format(context).replaceFirst('ص', 'AM').replaceFirst('م', 'PM'));
                      }
                    });
                  },
                  child: Text(
                    localization.chooseStartTime,
                  ),
                ),
                const SizedBox(
                  width: 16.0,
                ),
                Text(
                  provider.startTime,
                  textDirection: TextDirection.ltr,
                  style: TextStyle(color: CustomColors.primaryTextColor),
                ),
              ],
            ),
            Row(
              children: [
                OutlinedButton(
                  onPressed: () async {
                    await showTimePicker(
                            context: context, initialTime: const TimeOfDay(hour: 8, minute: 0))
                        .then((time) {
                      if (time != null) {
                        provider.setEndTime(
                            time.format(context).replaceFirst('ص', 'AM').replaceFirst('م', 'PM'));
                      }
                    });
                  },
                  child: Text(
                    localization.chooseEndTime,
                  ),
                ),
                const SizedBox(
                  width: 16.0,
                ),
                Text(
                  provider.endTime,
                  textDirection: TextDirection.ltr,
                  style: TextStyle(color: CustomColors.primaryTextColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Step selectSubjectLevelStep(
      AddSubjectViewModel provider, BuildContext context, AppLocalizations? localization) {
    return Step(
      title: Text(
        localization!.subjectLevel,
        style: TextStyle(color: CustomColors.primaryTextColor),
      ),
      content: Container(
        alignment: AlignmentDirectional.centerStart,
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: [
            RadioListTile(
              title: Text(
                localization.firstYear,
                style: TextStyle(color: CustomColors.primaryTextColor),
              ),
              value: SubjectLevel.firstYear,
              groupValue: provider.subjectLevel,
              onChanged: (SubjectLevel? level) {
                provider.setSubjectLevel(level!);
              },
            ),
            RadioListTile(
              title: Text(
                localization.secondYear,
                style: TextStyle(color: CustomColors.primaryTextColor),
              ),
              value: SubjectLevel.secondYear,
              groupValue: provider.subjectLevel,
              onChanged: (SubjectLevel? level) {
                provider.setSubjectLevel(level!);
              },
            ),
            RadioListTile(
              title: Text(
                localization.thirdYear,
                style: TextStyle(color: CustomColors.primaryTextColor),
              ),
              value: SubjectLevel.thirdYear,
              groupValue: provider.subjectLevel,
              onChanged: (SubjectLevel? level) {
                provider.setSubjectLevel(level!);
              },
            ),
            RadioListTile(
              title: Text(
                localization.fourthYear,
                style: TextStyle(color: CustomColors.primaryTextColor),
              ),
              value: SubjectLevel.fourthYear,
              groupValue: provider.subjectLevel,
              onChanged: (SubjectLevel? level) {
                provider.setSubjectLevel(level!);
              },
            ),
            RadioListTile(
              title: Text(
                localization.fifthYear,
                style: TextStyle(color: CustomColors.primaryTextColor),
              ),
              value: SubjectLevel.fifthYear,
              groupValue: provider.subjectLevel,
              onChanged: (SubjectLevel? level) {
                provider.setSubjectLevel(level!);
              },
            ),
          ],
        ),
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
            itemCount: 7,
            itemBuilder: (BuildContext context, int index) {
              return Row(
                children: [
                  Radio(value: false, groupValue: 1, onChanged: (_) {}),
                  shimmerContainer(width * 0.60, 20.0),
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
