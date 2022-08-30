import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../res/colors.dart';
import '../../res/components.dart';
import '../../view_models/admin/add_new_user_view_model.dart';

class AddNewUserView extends StatefulWidget {
  const AddNewUserView({
    Key? key,
    required this.heroTag,
    required this.whoToAdd,
  }) : super(key: key);

  final String heroTag;
  final int whoToAdd;

  @override
  State<AddNewUserView> createState() => _AddNewUserViewState();
}

class _AddNewUserViewState extends State<AddNewUserView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AddNewUserViewModel _viewModel = AddNewUserViewModel();

  late TextEditingController _majorController;

  @override
  void initState() {
    _majorController = TextEditingController();
    _viewModel.setUserData(widget.whoToAdd);
    super.initState();
  }

  @override
  void dispose() {
    _majorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations? localization = AppLocalizations.of(context);
    List<String> majors = Components.setMajors(context);
    List<String> genders = Components.setGender(context);
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
                fontSize: 18.0,
                color: CustomColors.primaryTextColor,
              ),
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                buildTextFormField(
                  hintText: localization!.firstName,
                  studentDataKey: 'firstName',
                  textInputType: TextInputType.name,
                ),
                const SizedBox(
                  height: 8.0,
                ),
                buildTextFormField(
                  hintText: localization.middleName,
                  studentDataKey: 'middleName',
                  textInputType: TextInputType.name,
                ),
                const SizedBox(
                  height: 8.0,
                ),
                buildTextFormField(
                  hintText: localization.lastName,
                  studentDataKey: 'lastName',
                  textInputType: TextInputType.name,
                ),
                const SizedBox(
                  height: 8.0,
                ),
                buildDropdownButtonFormField(
                    localization: localization,
                    hintText: localization.gender,
                    itemValue: genders,
                    onChanged: (value) {
                      _viewModel.userData!['gender'] = value!;
                    },
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return '${localization.pleaseEnter} ${localization.gender}';
                      }
                      return null;
                    },
                    onSaved: (String? value) {
                      int index = genders.indexOf(value!);
                      _viewModel.userData!['gender'] = _viewModel.genders[index];
                    }),
                const SizedBox(
                  height: 8.0,
                ),
                buildTextFormField(
                  hintText: localization.address,
                  studentDataKey: 'address',
                  textInputType: TextInputType.name,
                ),
                const SizedBox(
                  height: 8.0,
                ),
                buildTextFormField(
                  hintText: localization.mobileNumber,
                  studentDataKey: 'mobileNumber',
                  textInputType: TextInputType.phone,
                  isMobileNumber: true,
                ),
                const SizedBox(
                  height: 8.0,
                ),
                buildDropdownButtonFormField(
                    localization: localization,
                    hintText: widget.whoToAdd == 0 ? localization.major : localization.section,
                    itemValue: majors,
                    onChanged: (value) {
                      if (widget.whoToAdd == 0) {
                        _viewModel.userData!['major'] = value!;
                      } else {
                        _viewModel.userData!['section'] = value!;
                      }
                    },
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return '${localization.pleaseEnter} ${localization.major}';
                      }
                      return null;
                    },
                    onSaved: (String? value) {
                      int index = majors.indexOf(value!);
                      _viewModel.userData!['major'] = Components.majors[index];
                    }),
                const SizedBox(
                  height: 8.0,
                ),
                if (widget.whoToAdd == 1)
                  buildTextFormField(
                    hintText: localization.yearsOfExperience,
                    studentDataKey: 'yearsOfExperience',
                    textInputType: TextInputType.number,
                    isInteger: true,
                  ),
                if (widget.whoToAdd == 1)
                  const SizedBox(
                    height: 8.0,
                  ),
                if (widget.whoToAdd == 1)
                  buildTextFormField(
                    hintText: localization.salary,
                    studentDataKey: 'salary',
                    textInputType: TextInputType.number,
                    isDouble: true,
                  ),
                const SizedBox(
                  height: 32.0,
                ),
                SizedBox(
                  height: 50.0,
                  width: 200.0,
                  child: ElevatedButton(
                    onPressed: () async {
                      await _viewModel.submit(_formKey, context, widget.whoToAdd, mounted);
                    },
                    child: Text(
                      localization.save,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  DropdownButtonFormField<String> buildDropdownButtonFormField(
      {required AppLocalizations localization,
      required String hintText,
      required List<String> itemValue,
      required Function(String?) onChanged,
      required String? Function(String?) validator,
      required Function(String?) onSaved}) {
    return DropdownButtonFormField(
      style: TextStyle(
        color: CustomColors.secondaryTextColor,
      ),
      decoration: InputDecoration(
        hintText: hintText,
      ),
      items: itemValue.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: onChanged,
      validator: validator,
      onSaved: onSaved,
    );
  }

  TextFormField buildTextFormField({
    required String hintText,
    required String studentDataKey,
    required TextInputType textInputType,
    bool isMobileNumber = false,
    bool isInteger = false,
    bool isDouble = false,
  }) {
    return TextFormField(
      cursorColor: CustomColors.secondaryColor,
      textInputAction: TextInputAction.next,
      style: TextStyle(
        color: CustomColors.secondaryTextColor,
      ),
      keyboardType: textInputType,
      decoration: InputDecoration(
        hintText: hintText,
      ),
      validator: (String? value) {
        if (value == null || value.isEmpty) {
          return '${AppLocalizations.of(context)!.pleaseEnter} $hintText';
        }
        if (isMobileNumber) {
          if (!RegExp(r"^(?:[+0]9)?[0-9]{10,12}$").hasMatch(value)) {
            return AppLocalizations.of(context)!.pleaseEnterValidMobile;
          }
        }
        if (isInteger) {
          if (double.tryParse(value) == null) {
            return AppLocalizations.of(context)!.pleaseEnterValidYearsOfExperience;
          }
        }
        if (isDouble) {
          if (double.tryParse(value) == null) {
            return AppLocalizations.of(context)!.pleaseEnterValidSalary;
          }
        }
        return null;
      },
      onSaved: (String? value) {
        _viewModel.userData![studentDataKey] = value!;
      },
    );
  }
}
