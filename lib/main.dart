import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'res/colors.dart';
import 'view_models/common/home_view_model.dart';
import 'view_models/login/login_view_model.dart';
import 'views/common/home_view.dart';
import 'views/login/login_view.dart';
import 'views/common/splash_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      Provider.of<LoginViewModel>(context, listen: false).setUser(user);
      if (user == null) {
        Provider.of<LoginViewModel>(context, listen: false).setUserEmailAndMajorAndYear(null);
      } else {
        Provider.of<LoginViewModel>(context, listen: false).setRole(user.email!.split('@')[1]);
        Provider.of<LoginViewModel>(context, listen: false).setUserEmailAndMajorAndYear(user.email);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getLocal();
    });
    super.initState();
  }

  Future<void> getLocal() async {
    await Provider.of<HomeViewModel>(context, listen: false).initLocale();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    Locale? locale = Provider.of<HomeViewModel>(context).locale;
    return Consumer<LoginViewModel>(
      builder: (BuildContext context, LoginViewModel provider, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: ThemeData(
            useMaterial3: false,
            textTheme: GoogleFonts.nunitoTextTheme(
              Theme.of(context).textTheme,
            ),
            iconTheme: IconThemeData(color: CustomColors.primaryTextColor),
            listTileTheme: ListTileThemeData(
              iconColor: CustomColors.primaryTextColor,
              textColor: CustomColors.primaryTextColor,
            ),
            expansionTileTheme: ExpansionTileThemeData(
              collapsedTextColor: CustomColors.primaryTextColor,
              textColor: CustomColors.secondaryTextColor,
              collapsedIconColor: CustomColors.primaryTextColor,
              iconColor: CustomColors.secondaryTextColor,
            ),
            textButtonTheme: TextButtonThemeData(
              style: ButtonStyle(
                  foregroundColor:
                      MaterialStateProperty.all<Color>(CustomColors.secondaryTextColor),
                  textStyle: MaterialStateProperty.all<TextStyle>(
                      const TextStyle(fontWeight: FontWeight.bold))),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ButtonStyle(
                textStyle: MaterialStateProperty.all<TextStyle>(
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 24.0)),
                foregroundColor: MaterialStateProperty.all<Color>(CustomColors.primaryTextColor),
                backgroundColor: MaterialStateProperty.all<Color>(CustomColors.secondaryColor),
              ),
            ),
            outlinedButtonTheme: OutlinedButtonThemeData(
                style: ButtonStyle(
                    foregroundColor:
                        MaterialStateProperty.all<Color>(CustomColors.primaryTextColor),
                    textStyle: MaterialStateProperty.all<TextStyle>(
                      const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    side: MaterialStateProperty.all<BorderSide>(
                        BorderSide(color: CustomColors.secondaryColor)))),
            inputDecorationTheme: InputDecorationTheme(
              fillColor: const Color.fromRGBO(113, 93, 109, 1.0).withOpacity(0.5),
              filled: true,
              hintStyle: TextStyle(color: CustomColors.secondaryTextColor.withOpacity(0.6)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: CustomColors.greyColor)),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: CustomColors.secondaryColor)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: CustomColors.secondaryColor)),
            ),
            radioTheme: RadioThemeData(
              fillColor: MaterialStateProperty.all<Color>(CustomColors.secondaryColor),
            ),
            dividerColor: CustomColors.dividerColor,
            cardColor: CustomColors.cardColor,
            canvasColor: CustomColors.canvasColor,
            colorScheme: ColorScheme.fromSwatch().copyWith(
              primary: CustomColors.primaryColor,
              secondary: CustomColors.secondaryColor,
            ),
          ),
          home: provider.user != null
              ? provider.isSplashEnd
                  ? HomeView()
                  : const SplashView()
              : const LoginView(),
        );
      },
    );
  }
}
