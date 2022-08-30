import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_splash_screen/easy_splash_screen.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../res/colors.dart';
import '../../view_models/login/login_view_model.dart';

class SplashView extends StatefulWidget {
  const SplashView({Key? key}) : super(key: key);

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    User? user = Provider.of<LoginViewModel>(context, listen: false).user;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Provider.of<LoginViewModel>(context, listen: false).setRole(user!.email!.split('@')[1]);
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String version = packageInfo.version;
      if (!mounted) return;
      Provider.of<LoginViewModel>(context, listen: false).setAppInfo(version);
      Provider.of<LoginViewModel>(context, listen: false).setIsSplashEnd(true);
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations? localization = AppLocalizations.of(context);
    return Scaffold(
      body: EasySplashScreen(
        backgroundColor: CustomColors.canvasColor,
        logo: Image.asset('assets/images/app_icon.png'),
        logoSize: 100.0,
        title: Text(
          'College App',
          style: TextStyle(
            color: CustomColors.primaryTextColor,
          ),
        ),
        loaderColor: CustomColors.primaryTextColor,
        loadingText: Text(
          localization!.waitABit,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: CustomColors.primaryTextColor,
          ),
        ),
      ),
    );
  }
}
