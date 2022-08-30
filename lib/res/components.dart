import 'package:college_app/res/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

class Components {
  static AppBar commonAppBar(String title, {List<Widget>? actions}) {
    return AppBar(
      foregroundColor: CustomColors.primaryTextColor,
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      actions: actions,
    );
  }

  static Future errorDialog(BuildContext context, String errorMessage) {
    return showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Error Occurred"),
        content: Text(errorMessage),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context)!.ok)),
        ],
      ),
    );
  }

  static List<String> setGender(BuildContext context) {
    AppLocalizations? localization = AppLocalizations.of(context);

    List<String> genders = [
      localization!.male,
      localization.female,
    ];
    return genders;
  }

  static List<String> setMajors(BuildContext context) {
    AppLocalizations? localization = AppLocalizations.of(context);
    List<String> majors = [
      localization!.networkEngineering,
      localization.computerEngineering,
      localization.mechanicalEngineering,
      localization.electricalEngineering,
      localization.communicationsEngineering,
    ];

    return majors;
  }

  static List<String> majors = [
    'Network Engineering',
    'Computer Engineering',
    'Mechanical Engineering',
    'Electrical Engineering',
    'Communications Engineering',
  ];

  static Map majorsCode = {
    'Network Engineering': 'NET',
    'Computer Engineering': 'CMP',
    'Mechanical Engineering': 'MEC',
    'Electrical Engineering': 'ELC',
    'Communications Engineering': 'COM',
  };

  static void showToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: CustomColors.toastBackgroundColor,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  static void showSuccessToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: CustomColors.successColor,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  static void showErrorToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: CustomColors.redColor,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  static Future showCustomDialog(BuildContext context, String? title, String message) {
    return showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: title != null ? Text(title) : null,
        content: Text(message),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context)!.ok)),
        ],
      ),
    );
  }

  static void successSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: CustomColors.successColor,
      ),
    );
  }

  static void normalSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        content: Text(message),
      ),
    );
  }

  static Column noDataImage(AppLocalizations? localization) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('assets/images/no_data.jpg'),
        const SizedBox(
          height: 16.0,
        ),
        Text(
          localization!.opps,
          style: TextStyle(fontWeight: FontWeight.bold, color: CustomColors.primaryTextColor),
        ),
        Text(
          localization.noDataYet,
          textAlign: TextAlign.center,
          style: TextStyle(color: CustomColors.primaryTextColor),
        ),
      ],
    );
  }

  static Column errorImage(AppLocalizations? localization) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('assets/images/something_went_wrong.png'),
        const SizedBox(
          height: 16.0,
        ),
        Text(
          localization!.opps,
          style: TextStyle(fontWeight: FontWeight.bold, color: CustomColors.primaryTextColor),
        ),
        Text(
          localization.somethingWrongCheckInternet,
          textAlign: TextAlign.center,
          style: TextStyle(color: CustomColors.primaryTextColor),
        ),
      ],
    );
  }

  static Future<ImageSource?> pickImageAlert(BuildContext context, ImageSource? imageSource) async {
    await showDialog(
        context: context,
        builder: (_) => AlertDialog(
              backgroundColor: CustomColors.canvasColor,
              content: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      imageSource = ImageSource.gallery;
                      Navigator.of(context).pop();
                    },
                    label: Text(AppLocalizations.of(context)!.gallery),
                    icon: const Icon(Icons.photo_library_outlined),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(CustomColors.cardColor),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      imageSource = ImageSource.camera;
                      Navigator.of(context).pop();
                    },
                    label: Text(AppLocalizations.of(context)!.camera),
                    icon: const Icon(Icons.camera_alt_outlined),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(CustomColors.cardColor),
                    ),
                  ),
                ],
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0),
              ),
            ));
    return imageSource;
  }
}
