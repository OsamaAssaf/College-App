import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../res/components.dart';
import '../../res/widgets/list_card.dart';
import 'add_new_user_view.dart';
import 'users_list_view.dart';

class AdminConfigurationsView extends StatelessWidget {
  const AdminConfigurationsView({Key? key, required this.roleChosen}) : super(key: key);

  final int roleChosen;

  @override
  Widget build(BuildContext context) {
    AppLocalizations? localization = AppLocalizations.of(context);
    return Scaffold(
      appBar: Components.commonAppBar(
        roleChosen == 0
            ? localization!.studentsConfiguration
            : roleChosen == 0
                ? localization!.teachersConfiguration
                : localization!.adminsConfiguration,
        // backgroundColor: mainColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListCard(
              title: roleChosen == 0
                  ? localization.registerNewStudent
                  : roleChosen == 1
                      ? localization.registerNewTeacher
                      : localization.registerNewAdmin,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AddNewUserView(
                      heroTag: roleChosen == 0
                          ? localization.registerNewStudent
                          : roleChosen == 1
                              ? localization.registerNewTeacher
                              : localization.registerNewAdmin,
                      whoToAdd: roleChosen,
                    ),
                  ),
                );
              },
            ),
            ListCard(
              title: roleChosen == 0
                  ? localization.studentsList
                  : roleChosen == 1
                      ? localization.teachersList
                      : localization.adminsList,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => UsersListView(
                      heroTag: roleChosen == 0
                          ? localization.studentsList
                          : roleChosen == 1
                              ? localization.teachersList
                              : localization.adminsList,
                      roleChosen: roleChosen,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
