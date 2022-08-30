import 'package:flutter/material.dart';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../res/colors.dart';
import '../../res/components.dart';
import '../../view_models/admin/end_semester_view_model.dart';

class EndSemesterView extends StatefulWidget {
  const EndSemesterView({Key? key}) : super(key: key);

  @override
  State<EndSemesterView> createState() => _EndSemesterViewState();
}

class _EndSemesterViewState extends State<EndSemesterView> {
  final EndSemesterViewModel _viewModel = EndSemesterViewModel();
  late TextEditingController _passwordController;

  @override
  void initState() {
    _passwordController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations? localization = AppLocalizations.of(context);
    return Scaffold(
      appBar: Components.commonAppBar(
        localization!.endCurrentSemester,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: DefaultTextStyle(
          style: TextStyle(
            color: CustomColors.primaryTextColor,
            fontSize: 20.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(localization.beforeEndSemester),
                  const SizedBox(
                    height: 16.0,
                  ),
                  Text('1-${localization.ensureGradesCalculated}'),
                  const SizedBox(
                    height: 8.0,
                  ),
                  Text('2-${localization.averageWillCalculated}'),
                  const SizedBox(
                    height: 8.0,
                  ),
                  Text('3-${localization.subjectsWillDeleted}'),
                  const SizedBox(
                    height: 8.0,
                  ),
                  Text('4-${localization.eventsWillDeleted}'),
                ],
              ),
              SizedBox(
                width: double.infinity,
                height: 50.0,
                child: ElevatedButton(
                  onPressed: () async {
                    bool? isPasswordTrue = await showDialog(
                        context: context,
                        builder: (ctx) {
                          return AlertDialog(
                            backgroundColor: CustomColors.cardColor,
                            title: Text(
                              localization.enterEndSemesterPassword,
                              style: TextStyle(
                                color: CustomColors.primaryTextColor,
                              ),
                            ),
                            content: SingleChildScrollView(
                              child: Column(
                                children: [
                                  TextField(
                                    controller: _passwordController,
                                    decoration: const InputDecoration(
                                      hintText: 'End semester password',
                                    ),
                                    style: TextStyle(color: CustomColors.secondaryTextColor),
                                  ),
                                ],
                              ),
                            ),
                            actions: [
                              TextButton(
                                  onPressed: () async {
                                    String? password;
                                    final DatabaseReference ref = FirebaseDatabase.instance.ref();
                                    final DataSnapshot snapshot =
                                        await ref.child('endSemesterPassword').get();
                                    if (snapshot.exists) {
                                      password = snapshot.value.toString();
                                    }
                                    if (password == _passwordController.text) {
                                      if (!mounted) return;
                                      Navigator.of(context).pop(true);
                                    } else {
                                      if (!mounted) return;
                                      Navigator.of(context).pop(false);
                                    }
                                    _passwordController.clear();
                                  },
                                  child: Text(localization.confirm)),
                            ],
                          );
                        });
                    if (isPasswordTrue == true) {
                      try {
                        showDialog(
                            context: context,
                            builder: (ctx) {
                              return AlertDialog(
                                content: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      Text(localization.mayTakeTimeDoNotClose),
                                      const SizedBox(
                                        height: 32.0,
                                      ),
                                      const LinearProgressIndicator()
                                    ],
                                  ),
                                ),
                              );
                            });
                        if (!mounted) return;
                        await _viewModel.endCurrentSemester(context, localization);
                        if (!mounted) return;
                        Navigator.pop(context);
                        Navigator.pop(context);

                        Components.showSuccessToast(localization.success);
                      } catch (_) {
                        if (!mounted) return;
                        Navigator.pop(context);
                        Navigator.pop(context);

                        Components.showErrorToast(localization.wrongPleaseTryAgain);
                      }
                      return;
                    }
                    if (isPasswordTrue == false) {
                      Components.showToast(localization.wrongPassword);
                    }
                  },
                  child: Text(localization.understandEndSemester),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
