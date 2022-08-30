import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../res/colors.dart';
import '../../res/components.dart';
import '../../view_models/common/profile_view_model.dart';
import '../../view_models/login/login_view_model.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({Key? key, required this.role}) : super(key: key);

  final int role;

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final ProfileViewModel _viewModel = ProfileViewModel();

  late String? email;
  late String? majorKey;

  @override
  void initState() {
    email = Provider.of<LoginViewModel>(context, listen: false).userEmail;
    majorKey = Provider.of<LoginViewModel>(context, listen: false).majorKey;
    _viewModel.setUserData(widget.role);
    super.initState();
  }

  void _changePassword(GlobalKey<ScaffoldState> scaffoldKey, String oldPassword) {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    AppLocalizations? localization = AppLocalizations.of(context);
    String? newPassword;
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25.0),
            topRight: Radius.circular(25.0),
          ),
        ),
        builder: (_) {
          return Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.60,
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        localization!.changePassword,
                        style: TextStyle(
                            fontSize: 22.0,
                            fontWeight: FontWeight.bold,
                            color: CustomColors.primaryTextColor),
                      ),
                    ),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          TextFormField(
                            decoration: InputDecoration(
                              hintText: localization.oldPassword,
                            ),
                            style: TextStyle(color: CustomColors.secondaryTextColor),
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return localization.pleaseEnterYourPassword;
                              }
                              if (value != oldPassword) {
                                return localization.wrongPassword;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(
                            height: 8.0,
                          ),
                          TextFormField(
                            decoration: InputDecoration(
                              hintText: localization.newPassword,
                            ),
                            style: TextStyle(color: CustomColors.secondaryTextColor),
                            onChanged: (String? value) {
                              newPassword = value;
                            },
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return '${localization.pleaseEnter} ${localization.password}';
                              }
                              if (value == oldPassword) {
                                return localization.enterDifferentFromOld;
                              }
                              if (value.length < 6) {
                                return localization.pleaseEnterValidPassword;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(
                            height: 8.0,
                          ),
                          TextFormField(
                            decoration: InputDecoration(
                              hintText: localization.confirmNewPassword,
                            ),
                            style: TextStyle(color: CustomColors.secondaryTextColor),
                            validator: (String? value) {
                              if (newPassword != null) {
                                if (value != newPassword) {
                                  return localization.passwordsDoesNotMatch;
                                }
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextButton(
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            _viewModel.changePassword(
                                newPassword!, oldPassword, context, email!, majorKey!, mounted);
                            Navigator.of(context).pop();
                          }
                        },
                        child: Text(
                          AppLocalizations.of(context)!.changePassword,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    AppLocalizations? localization = AppLocalizations.of(context);
    int role = widget.role;

    return Scaffold(
      key: scaffoldKey,
      body: StreamBuilder<DocumentSnapshot>(
        stream: _viewModel.getProfileData(email!, majorKey!),
        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return shimmerEffect(width, height);
          }
          if (snapshot.hasData) {
            Map<String, dynamic>? data = snapshot.data!.data() as Map<String, dynamic>;
            int? year = Provider.of<LoginViewModel>(context).year;
            String localizationMajor = _viewModel.getLocalizationMajor(context, data['section']);
            return CustomScrollView(
              slivers: <Widget>[
                SliverAppBar(
                  elevation: 0.0,
                  expandedHeight: height * 0.20,
                  foregroundColor: CustomColors.primaryTextColor,
                  flexibleSpace: Stack(
                    children: [
                      FlexibleSpaceBar(
                        centerTitle: true,
                        background: CachedNetworkImage(
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                          errorWidget: (context, url, error) => const Icon(Icons.error),
                          imageUrl: data['imageURL'],
                          fit: BoxFit.contain,
                        ),
                        title: FittedBox(
                          child: Row(
                            children: [
                              Icon(
                                data['gender'].toString() == 'Male' ? Icons.male : Icons.female,
                                color:
                                    data['gender'].toString() == 'Male' ? Colors.blue : Colors.pink,
                                size: 16.0,
                              ),
                              Text(
                                data['fullName'],
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: CustomColors.secondaryTextColor,
                                  backgroundColor: Colors.black.withOpacity(0.5),
                                ),
                              ),
                              InkWell(
                                child: const Icon(
                                  Icons.add_photo_alternate_outlined,
                                  size: 16.0,
                                ),
                                onTap: () {
                                  _viewModel.pickAndUploadImage(context, email!, majorKey!);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      return Column(
                        children: [
                          buildListTile(
                              role == 0
                                  ? localization!.studentNumber
                                  : role == 1
                                      ? localization!.teacherNumber
                                      : localization!.adminNumber,
                              data['idNumber'].toString()),
                          const Divider(),
                          buildListTile(localization.section, localizationMajor),
                          const Divider(),
                          if (role == 0)
                            buildListTile(localization.average, data['result'].toString()),
                          if (role == 0) const Divider(),
                          if (role == 0) buildListTile(localization.year, year.toString()),
                          if (role == 0) const Divider(),
                          buildListTile(localization.mobileNumber, data['mobileNumber'].toString()),
                          const Divider(),
                          if (role == 1)
                            buildListTile(localization.salary, data['salary'].toString()),
                          if (role == 1) const Divider(),
                          Container(
                            color: CustomColors.greyColor,
                            child: ListTile(
                              title: Text(
                                localization.changePassword,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: CustomColors.secondaryTextColor),
                              ),
                              onTap: () => _changePassword(scaffoldKey, data['password']),
                            ),
                          ),
                        ],
                      );
                    },
                    childCount: 1,
                  ),
                ),
              ],
            );
          }
          return Center(
            child: Components.errorImage(localization),
          );
        },
      ),
    );
  }

  ListTile buildListTile(String title, String data) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
      ),
      subtitle: Text(
        data,
        style: const TextStyle(fontSize: 16.0),
      ),
    );
  }

  shimmerEffect(double width, double height) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[500]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: [
          Container(
            height: height * 0.20,
            color: Colors.white,
          ),
          Expanded(
            child: ListView.separated(
              itemCount: 5,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      shimmerContainer(width * 0.45, 20.0),
                      const SizedBox(
                        height: 8.0,
                      ),
                      shimmerContainer(width * 0.35, 20.0),
                    ],
                  ),
                );
              },
              separatorBuilder: (BuildContext context, _) {
                return const Divider();
              },
            ),
          ),
        ],
      ),
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
