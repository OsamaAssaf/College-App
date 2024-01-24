import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../res/colors.dart';
import '../../res/components.dart';
import '../../view_models/admin/profile_for_edit_view_model.dart';
import '../../view_models/admin/users_list_view_model.dart';
import '../../view_models/login/login_view_model.dart';
import 'profile_for_edit_view.dart';

class UsersListView extends StatefulWidget {
  const UsersListView({
    Key? key,
    required this.heroTag,
    required this.roleChosen,
  }) : super(key: key);

  final String heroTag;
  final int roleChosen;

  @override
  State<UsersListView> createState() => _UsersListViewState();
}

class _UsersListViewState extends State<UsersListView> {
  List<String> majors = Components.majors;

  String get collId {
    if (widget.roleChosen == 0) {
      return 'students';
    }
    if (widget.roleChosen == 1) {
      return 'teachers';
    }
    return 'admins';
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations? localization = AppLocalizations.of(context);
    List<String> localizationMajors = Components.setMajors(context);

    return Scaffold(
      appBar: AppBar(
        foregroundColor: CustomColors.primaryTextColor,
        title: Hero(
          tag: widget.heroTag,
          child: Material(
            color: Colors.transparent,
            child: Text(
              widget.heroTag,
              style: TextStyle(
                color: CustomColors.primaryTextColor,
                fontSize: 18.0,
              ),
            ),
          ),
        ),
        centerTitle: true,
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
                      return GetUsers(localization, widget.roleChosen, majorKey, collId);
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

class GetUsers extends StatelessWidget {
  final int roleChosen;
  final String majorKey;
  final String collId;
  final AppLocalizations? localization;

  GetUsers(this.localization, this.roleChosen, this.majorKey, this.collId, [Key? key])
      : super(key: key);

  String get emptyMajorText {
    if (roleChosen == 0) {
      return localization!.noStudentsMajor;
    }
    if (roleChosen == 1) {
      return localization!.noTeachersMajor;
    }
    return localization!.noAdminsMajor;
  }

  final UsersListViewModel _viewModel = UsersListViewModel();

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return SizedBox(
      height: height * 0.8,
      width: width,
      child: StreamBuilder<QuerySnapshot>(
        stream: _viewModel.getUsersByMajor(collId, majorKey),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return shimmerEffect(width);
          }
          if (snapshot.hasData) {
            if (snapshot.data!.size == 0) {
              return Center(
                  child: Text(
                emptyMajorText,
                style: TextStyle(color: CustomColors.primaryTextColor),
              ));
            }
            List<QueryDocumentSnapshot<Object?>> data = snapshot.data!.docs;
            String? currentUserEmail = Provider.of<LoginViewModel>(context).user!.email;
            return ListView.separated(
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(data[index]['fullName']),
                  subtitle: Text(data[index]['mobileNumber']),
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(data[index]['imageURL']),
                  ),
                  trailing: roleChosen == 2
                      ? currentUserEmail == data[index]['email']
                          ? Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                              decoration: BoxDecoration(
                                  border: Border.all(width: 2.0, color: Colors.white),
                                  borderRadius: BorderRadius.circular(5.0),
                                  color: Colors.blue[400]),
                              child: const Text(
                                'YOU',
                              ),
                            )
                          : null
                      : null,
                  onTap: () {
                    if (roleChosen == 2) {
                      return;
                    }
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => ChangeNotifierProvider(
                        create: (_) => ProfileForEditViewModel(),
                        child: ProfileForEditView(
                          role: roleChosen,
                          userData: data[index],
                        ),
                      ),
                    ));
                  },
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
              return Row(
                children: [
                  const CircleAvatar(),
                  const SizedBox(
                    width: 8.0,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      shimmerContainer(width * 0.55, 20.0),
                      const SizedBox(
                        height: 4.0,
                      ),
                      shimmerContainer(width * 0.30, 20.0),
                    ],
                  ),
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
