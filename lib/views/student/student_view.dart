import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../res/components.dart';
import '../../res/widgets/grid_card.dart';
import '../../view_models/login/login_view_model.dart';
import '../../view_models/common/calendar_view_model.dart';
import '../../view_models/student/student_view_model.dart';
import '../../view_models/student/students_subjects_view_model.dart';
import '../common/profile_view.dart';
import '../common/calendar_view.dart';
import 'fees_view.dart';
import 'result_view.dart';
import 'student_subjects_view.dart';

class StudentView extends StatelessWidget {
  StudentView({Key? key}) : super(key: key);

  final StudentViewModel _viewModel = StudentViewModel();

  @override
  Widget build(BuildContext context) {
    AppLocalizations? localization = AppLocalizations.of(context);
    return Consumer<LoginViewModel>(
      builder: (BuildContext context, LoginViewModel provider, _) {
        return Scaffold(
          appBar: Components.commonAppBar(
            localization!.student,
          ),
          body: provider.role == 0
              ? Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 2,
                    mainAxisSpacing: 16.0,
                    crossAxisSpacing: 16.0,
                    children: [
                      GridCard(
                        title: localization.calendar,
                        image: _viewModel.cardImage[0],
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ChangeNotifierProvider(
                                create: (_) => CalendarViewModel(),
                                child: const CalendarView(),
                              ),
                            ),
                          );
                        },
                      ),
                      GridCard(
                        title: localization.subjects,
                        image: _viewModel.cardImage[1],
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ChangeNotifierProvider(
                                create: (_) => StudentSubjectsViewModel(),
                                child: const StudentSubjectsView(),
                              ),
                            ),
                          );
                        },
                      ),
                      GridCard(
                        title: localization.results,
                        image: _viewModel.cardImage[2],
                        onTap: () {
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (_) => ResultView()));
                        },
                      ),
                      GridCard(
                        title: localization.fees,
                        image: _viewModel.cardImage[3],
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(builder: (_) => FeesView()));
                        },
                      ),
                      GridCard(
                        title: localization.profile,
                        image: _viewModel.cardImage[4],
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => const ProfileView(
                              role: 0,
                            ),
                          ));
                        },
                      ),
                    ],
                  ),
                )
              : Container(),
        );
      },
    );
  }
}
