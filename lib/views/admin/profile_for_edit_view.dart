import 'dart:async';

import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../res/colors.dart';
import '../../res/components.dart';
import '../../view_models/admin/profile_for_edit_view_model.dart';

class ProfileForEditView extends StatefulWidget {
  const ProfileForEditView({Key? key, required this.role, required this.userData})
      : super(key: key);

  final int role;
  final DocumentSnapshot userData;

  @override
  State<ProfileForEditView> createState() => _ProfileForEditViewState();
}

class _ProfileForEditViewState extends State<ProfileForEditView> {
  final ProfileForEditViewModel _viewModel = ProfileForEditViewModel();

  int? year;
  Timer? _timer;

  TextEditingController? _firstNameController;
  TextEditingController? _middleNameController;
  TextEditingController? _lastNameController;
  TextEditingController? _mobileNumberController;
  TextEditingController? _salaryNumberController;

  @override
  void initState() {
    _viewModel.setUserData(widget.role, widget.userData['email']);
    int addedYear = int.parse(widget.userData['idNumber'].toString().replaceRange(4, null, ''));
    int currentYear = DateTime.now().year;
    year = currentYear - addedYear + 1;
    _salaryNumberController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProfileForEditViewModel>(context, listen: false)
          .setSomeData(widget.role, widget.userData);
    });

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    if (_timer != null) {
      _timer!.cancel();
    }
    if (_firstNameController != null) {
      _firstNameController!.dispose();
      _middleNameController!.dispose();
      _lastNameController!.dispose();
    }
    if (_mobileNumberController != null) {
      _mobileNumberController!.dispose();
    }
    if (_salaryNumberController != null) {
      _salaryNumberController!.dispose();
    }
  }

  void updateUserName(AppLocalizations? localization) {
    List<String> splitOldName = widget.userData['fullName'].toString().split(' ');
    _firstNameController = TextEditingController(text: splitOldName[0]);
    _middleNameController = TextEditingController(text: splitOldName[1]);
    _lastNameController = TextEditingController(text: splitOldName[2]);
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          return AlertDialog(
            title: Text('${localization!.updateUserName}:'),
            scrollable: true,
            content: Column(
              children: [
                TextField(
                  controller: _firstNameController,
                  decoration: InputDecoration(
                      label: Text(localization.firstName), border: const OutlineInputBorder()),
                ),
                const SizedBox(
                  height: 8.0,
                ),
                TextField(
                  controller: _middleNameController,
                  decoration: InputDecoration(
                      label: Text(localization.middleName), border: const OutlineInputBorder()),
                ),
                const SizedBox(
                  height: 8.0,
                ),
                TextField(
                  controller: _lastNameController,
                  decoration: InputDecoration(
                      label: Text(localization.lastName), border: const OutlineInputBorder()),
                ),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    _firstNameController!.clear();
                    _middleNameController!.clear();
                    _lastNameController!.clear();
                    Navigator.pop(context);
                  },
                  child: Text(localization.cancel)),
              OutlinedButton(
                  onPressed: () async {
                    if (_firstNameController!.text.isEmpty ||
                        _middleNameController!.text.isEmpty ||
                        _lastNameController!.text.isEmpty) {
                      Components.showToast(localization.allFieldRequired);
                      return;
                    }
                    String fullName =
                        '${_firstNameController!.text.replaceFirst(_firstNameController!.text[0], _firstNameController!.text[0].toUpperCase())} ${_middleNameController!.text.replaceFirst(_middleNameController!.text[0], _middleNameController!.text[0].toUpperCase())} ${_lastNameController!.text.replaceFirst(_lastNameController!.text[0], _lastNameController!.text[0].toUpperCase())}';
                    try {
                      await _viewModel.updateUserName(widget.userData['email'], fullName);
                      if (!mounted) return;
                      Navigator.pop(context);
                      Provider.of<ProfileForEditViewModel>(context, listen: false)
                          .changeUserName(fullName);
                      Components.successSnackBar(context, localization.nameChangedSuccessfully);
                    } catch (e) {
                      Navigator.pop(context);
                      Components.errorDialog(context, e.toString());
                    }
                  },
                  child: Text(localization.update)),
            ],
          );
        });
  }

  void updateMobileNumber(AppLocalizations? localization) {
    String oldMobileNumber = widget.userData['mobileNumber'];
    _mobileNumberController = TextEditingController(text: oldMobileNumber);
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          return AlertDialog(
            title: Text('${localization!.updateMobileNumber}:'),
            scrollable: true,
            content: Column(
              children: [
                TextField(
                  controller: _mobileNumberController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                      label: Text(localization.mobileNumber), border: const OutlineInputBorder()),
                ),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    _mobileNumberController!.clear();
                    Navigator.pop(context);
                  },
                  child: Text(localization.cancel)),
              OutlinedButton(
                  onPressed: () async {
                    if (_mobileNumberController!.text.isEmpty) {
                      Components.showToast(localization.pleaseEnterMobileNumber);
                      return;
                    }
                    if (!RegExp(r"^(?:[+0]9)?[0-9]{10,12}$")
                        .hasMatch(_mobileNumberController!.text)) {
                      Components.showToast(AppLocalizations.of(context)!.pleaseEnterValidMobile);
                      return;
                    }
                    try {
                      await _viewModel.updateMobileNumber(
                          widget.userData['email'], _mobileNumberController!.text);
                      if (!mounted) return;
                      Navigator.pop(context);
                      Provider.of<ProfileForEditViewModel>(context, listen: false)
                          .changeMobileNumber(_mobileNumberController!.text);
                      Components.successSnackBar(context, 'Mobile number changed');
                    } catch (e) {
                      Navigator.pop(context);
                      Components.errorDialog(context, e.toString());
                    }
                  },
                  child: Text(localization.update)),
            ],
          );
        });
  }

  void updateSalary(AppLocalizations? localization) {
    double oldSalary = widget.userData['salary'];
    _salaryNumberController = TextEditingController(text: oldSalary.toString());
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          return AlertDialog(
            title: Text('${localization!.updateSalary}:'),
            scrollable: true,
            content: Column(
              children: [
                TextField(
                  controller: _salaryNumberController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      label: Text(localization.salary), border: const OutlineInputBorder()),
                ),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    _salaryNumberController!.clear();
                    Navigator.pop(context);
                  },
                  child: Text(localization.cancel)),
              OutlinedButton(
                  onPressed: () async {
                    if (_salaryNumberController!.text.isEmpty) {
                      Components.showToast(localization.pleaseEnterNewSalary);
                      return;
                    }
                    if (double.tryParse(_salaryNumberController!.text) == null) {
                      Components.showToast(localization.pleaseEnterValidSalary);
                      return;
                    }
                    if (double.parse(_salaryNumberController!.text) < 0) {
                      Components.showToast(localization.pleaseEnterValidSalary);
                      return;
                    }
                    try {
                      double salary = double.parse(_salaryNumberController!.text);
                      await _viewModel.updateSalary(widget.userData['email'], salary);
                      if (!mounted) return;
                      Navigator.pop(context);
                      Provider.of<ProfileForEditViewModel>(context, listen: false)
                          .changeSalary(salary);
                      Components.successSnackBar(context, 'Salary changed');
                    } catch (e) {
                      Navigator.pop(context);
                      Components.errorDialog(context, e.toString());
                    }
                  },
                  child: Text(localization.update)),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    AppLocalizations? localization = AppLocalizations.of(context);
    String localizationMajor = _viewModel.getLocalizationMajor(context, widget.userData['section']);
    return Scaffold(
      body: Consumer<ProfileForEditViewModel>(
          builder: (BuildContext context, ProfileForEditViewModel provider, _) {
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
                      imageUrl: widget.userData['imageURL'],
                      fit: BoxFit.contain,
                    ),
                    title: FittedBox(
                      child: Row(
                        children: [
                          Icon(
                            widget.userData['gender'].toString() == 'Male'
                                ? Icons.male
                                : Icons.female,
                            color: widget.userData['gender'].toString() == 'Male'
                                ? Colors.blue
                                : Colors.pink,
                            size: 16.0,
                          ),
                          Text(
                            provider.userName ?? '',
                            style: TextStyle(
                              fontSize: 16.0,
                              color: CustomColors.secondaryTextColor,
                              backgroundColor: Colors.black.withOpacity(0.5),
                            ),
                          ),
                          const SizedBox(
                            width: 4.0,
                          ),
                          editIcon(() {
                            updateUserName(localization);
                          }, 12.0)
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
                          widget.role == 0
                              ? localization!.studentNumber
                              : widget.role == 1
                                  ? localization!.teacherNumber
                                  : localization!.adminNumber,
                          widget.userData['idNumber'].toString()),
                      const Divider(),
                      buildListTile(localization.section, localizationMajor.toString()),
                      const Divider(),
                      if (widget.role == 0)
                        buildListTile(localization.average, widget.userData['result'].toString()),
                      if (widget.role == 0) const Divider(),
                      if (widget.role == 0) buildListTile(localization.year, year.toString()),
                      if (widget.role == 0) const Divider(),
                      buildListTile(
                        localization.mobileNumber,
                        provider.mobileNumber ?? '',
                        trailing: editIcon(() {
                          updateMobileNumber(localization);
                        }, 22.0),
                      ),
                      const Divider(),
                      if (widget.role == 1)
                        buildListTile(
                          localization.salary,
                          '${provider.salary ?? ''}',
                          trailing: editIcon(() {
                            updateSalary(localization);
                          }, 22.0),
                        ),
                      if (widget.role == 1) const Divider(),
                      Container(
                        color: CustomColors.greyColor,
                        child: ListTile(
                          title: Text(
                            localization.showUserPassword,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: CustomColors.secondaryTextColor),
                          ),
                          subtitle: provider.userPassword == null
                              ? null
                              : Container(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                                  child: RichText(
                                    text: TextSpan(
                                      text: '${localization.userPasswordIs}: ',
                                      style: DefaultTextStyle.of(context).style.apply(
                                            color: CustomColors.primaryTextColor,
                                          ),
                                      children: <TextSpan>[TextSpan(text: provider.userPassword)],
                                    ),
                                  ),
                                ),
                          onTap: () {
                            provider.setUserPassword(widget.userData['password']);
                            _timer = Timer(const Duration(seconds: 10), () {
                              provider.setUserPassword(null);
                            });
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 8.0,
                      ),
                      Container(
                        color: CustomColors.redColor,
                        child: ListTile(
                          title: Text(
                            localization.deleteUser,
                            style: TextStyle(
                              color: CustomColors.secondaryTextColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (ctx) {
                                  return AlertDialog(
                                    title: Text(
                                      localization.areYouSure,
                                      style: TextStyle(color: CustomColors.redColor),
                                    ),
                                    backgroundColor: CustomColors.canvasColor,
                                    content: Text(
                                      localization.wantDeleteUser,
                                      style: TextStyle(color: CustomColors.primaryTextColor),
                                    ),
                                    actions: [
                                      TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text(localization.cancel)),
                                      TextButton(
                                          onPressed: () async {
                                            try {
                                              await _viewModel.deleteUser(widget.userData['email']);
                                              if (!mounted) return;
                                              Navigator.of(context).pop();
                                              Navigator.of(context).pop();
                                            } catch (_) {
                                              Components.showErrorToast(
                                                  localization.somethingWrong);
                                            }
                                          },
                                          child: Text(
                                            localization.deleteUser,
                                            style: TextStyle(color: CustomColors.redColor),
                                          )),
                                    ],
                                  );
                                });
                          },
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
      }),
    );
  }

  ListTile buildListTile(String title, String data, {Widget? trailing}) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
      ),
      subtitle: Text(
        data,
        style: const TextStyle(fontSize: 16.0),
      ),
      trailing: trailing,
    );
  }

  InkWell editIcon(Function() onTap, double size) {
    return InkWell(
      onTap: onTap,
      child: FaIcon(
        FontAwesomeIcons.penToSquare,
        size: size,
      ),
    );
  }
}
