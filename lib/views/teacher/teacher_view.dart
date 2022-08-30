import 'package:college_app/view_models/common/calendar_view_model.dart';
import 'package:college_app/views/common/calendar_view.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../res/components.dart';
import '../../res/widgets/grid_card.dart';
import '../../view_models/login/login_view_model.dart';
import '../../view_models/teacher/teacher_view_model.dart';
import '../common/profile_view.dart';
import 'subjects/teacher_subjects_view.dart';

class TeacherView extends StatelessWidget {
  TeacherView({Key? key}) : super(key: key);
  final TeacherViewModel _viewModel = TeacherViewModel();

  @override
  Widget build(BuildContext context) {
    AppLocalizations? localization = AppLocalizations.of(context);
    return Consumer<LoginViewModel>(
      builder: (BuildContext context, LoginViewModel provider, _) {
        return Scaffold(
          appBar: Components.commonAppBar(
            localization!.teacher,
          ),
          body: provider.role == 1
              ? Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 2,
                    mainAxisSpacing: 16.0,
                    crossAxisSpacing: 16.0,
                    children: [
                      GridCard(
                        title: localization.profile,
                        image: _viewModel.cardImage[0],
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => const ProfileView(
                                    role: 1,
                                  )));
                        },
                      ),
                      GridCard(
                        title: localization.subjects,
                        image: _viewModel.cardImage[1],
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const TeacherSubjectsView(),
                            ),
                          );
                        },
                      ),
                      GridCard(
                        title: localization.calendar,
                        image: _viewModel.cardImage[3],
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
                    ],
                  ),
                )
              : Container(),
        );
      },
    );
  }
}
