import 'package:college_app/res/colors.dart';
import 'package:college_app/res/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../view_models/login/login_view_model.dart';

class AboutView extends StatelessWidget {
  const AboutView({Key? key}) : super(key: key);

  final String developerEmail = 'osama.assaf.y@gmail.com';

  @override
  Widget build(BuildContext context) {
    AppLocalizations? localization = AppLocalizations.of(context);
    String version = Provider.of<LoginViewModel>(context).version;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: Components.commonAppBar(localization!.about),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                color: CustomColors.cardColor,
                width: width,
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: width * 0.25,
                      child: Image.asset('assets/icon/launcher_icon.png'),
                    ),
                    const SizedBox(
                      width: 32.0,
                    ),
                    FittedBox(
                      child: Column(
                        children: [
                          Text(
                            localization.appName.toUpperCase(),
                            style: TextStyle(
                                color: CustomColors.primaryTextColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 24.0),
                          ),
                          Text(
                            '${localization.version} $version',
                            style: TextStyle(color: CustomColors.primaryTextColor),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 12.0,
              ),
              Container(
                  color: CustomColors.cardColor,
                  width: width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextButton(
                        onPressed: () {},
                        child: Text(localization.sendFeedback),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text(localization.privacyPolicy),
                      ),
                    ],
                  )),
              const SizedBox(
                height: 12.0,
              ),
              Container(
                  color: CustomColors.cardColor,
                  width: width,
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localization.graduationProject.toUpperCase(),
                        style: TextStyle(
                            color: CustomColors.primaryTextColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 24.0),
                      ),
                      Text(
                        localization.alBalqaUniversity,
                        style: TextStyle(color: CustomColors.primaryTextColor, fontSize: 20.0),
                      ),
                    ],
                  )),
              const SizedBox(
                height: 12.0,
              ),
              Text(
                localization.aboutDeveloper.toUpperCase(),
                style: TextStyle(
                    color: CustomColors.primaryTextColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 24.0),
              ),
              const SizedBox(
                height: 8.0,
              ),
              Container(
                  color: CustomColors.cardColor,
                  width: width,
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Osama Assaf',
                        style: TextStyle(color: CustomColors.primaryTextColor, fontSize: 24.0),
                      ),
                      const Divider(),
                      Text(
                        '${localization.contactInformation}:',
                        style: TextStyle(color: CustomColors.primaryTextColor, fontSize: 20.0),
                      ),
                      const SizedBox(
                        height: 4.0,
                      ),
                      Row(
                        children: [
                          Text(
                            '${localization.email}: ',
                            style: TextStyle(
                              color: CustomColors.primaryTextColor,
                            ),
                          ),
                          GestureDetector(
                            child: Text(
                              developerEmail,
                              style: TextStyle(
                                  color: CustomColors.secondaryTextColor,
                                  decoration: TextDecoration.underline),
                            ),
                            onTap: () async {
                              if (!await launchUrl(Uri.parse('mailto:$developerEmail'))) {
                                Components.showErrorToast(localization.somethingWrong);
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 4.0,
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50.0),
                                color: Colors.white,
                              ),
                              child: const Icon(FontAwesomeIcons.facebook,
                                  color: Color.fromRGBO(66, 103, 178, 1.0), size: 32.0),
                            ),
                            onTap: () async {
                              if (!await launchUrl(
                                  Uri.parse('https://www.facebook.com/osama.assaf.5/'))) {
                                Components.showErrorToast(localization.somethingWrong);
                              }
                            },
                          ),
                          const SizedBox(
                            width: 16.0,
                          ),
                          GestureDetector(
                            child: Container(
                              color: Colors.white,
                              child: const Icon(FontAwesomeIcons.linkedin,
                                  color: Color.fromRGBO(10, 102, 194, 1.0), size: 32.0),
                            ),
                            onTap: () async {
                              if (!await launchUrl(Uri.parse(
                                  'https://www.linkedin.com/in/osama-assaf-392820216/'))) {
                                Components.showErrorToast(localization.somethingWrong);
                              }
                            },
                          ),
                        ],
                      ),
                      const Divider(),
                      Row(
                        children: [
                          Text(
                            'Copyright ',
                            style: TextStyle(
                              color: CustomColors.primaryTextColor,
                            ),
                          ),
                          const Icon(
                            Icons.copyright,
                            size: 14.0,
                          ),
                          Text(
                            ' 2022',
                            style: TextStyle(
                              color: CustomColors.primaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
