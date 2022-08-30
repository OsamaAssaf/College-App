import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../res/components.dart';
import '../../res/widgets/grid_card.dart';
import '../../view_models/admin/add_subject_view_model.dart';
import '../../view_models/admin/admin_view_model.dart';
import '../../view_models/common/calendar_view_model.dart';
import '../../view_models/login/login_view_model.dart';
import '../common/calendar_view.dart';
import 'add_subject_view.dart';
import 'admin_configurations_view.dart';
import 'end_semester_view.dart';
import 'subjects_list_view.dart';

class AdminView extends StatelessWidget {
  AdminView({Key? key}) : super(key: key);
  final AdminViewModel _viewModel = AdminViewModel();

  @override
  Widget build(BuildContext context) {
    AppLocalizations? localization = AppLocalizations.of(context);
    return Consumer<LoginViewModel>(
      builder: (BuildContext context, LoginViewModel provider, _) {
        return Scaffold(
          appBar: Components.commonAppBar(
            localization!.admin,
          ),
          body: provider.role == 2
              ? Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 2,
                    mainAxisSpacing: 16.0,
                    crossAxisSpacing: 16.0,
                    children: [
                      GridCard(
                        title: localization.student,
                        image: _viewModel.cardImage[0],
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const AdminConfigurationsView(
                                roleChosen: 0,
                              ),
                            ),
                          );
                        },
                      ),
                      GridCard(
                        title: localization.teacher,
                        image: _viewModel.cardImage[1],
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => const AdminConfigurationsView(
                              roleChosen: 1,
                            ),
                          ));
                        },
                      ),
                      GridCard(
                        title: localization.admin,
                        image: _viewModel.cardImage[2],
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => const AdminConfigurationsView(
                              roleChosen: 2,
                            ),
                          ));
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
                      GridCard(
                        title: localization.addSubject,
                        image: _viewModel.cardImage[4],
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => ChangeNotifierProvider(
                                create: (_) => AddSubjectViewModel(),
                                child: const AddSubjectView()),
                          ));
                        },
                      ),
                      GridCard(
                        title: localization.subjectsList,
                        image: _viewModel.cardImage[5],
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => SubjectsListView(),
                          ));
                        },
                      ),
                      GridCard(
                        title: localization.endCurrentSemester,
                        image: _viewModel.cardImage[6],
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const EndSemesterView()),
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
