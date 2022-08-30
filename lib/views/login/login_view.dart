import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../res/colors.dart';
import '../../res/components.dart';
import '../../view_models/login/login_view_model.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final LoginViewModel _loginViewModel = LoginViewModel();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String email = '';
  String password = '';

  late FocusNode _emailFocusNode;
  late FocusNode _passwordFocusNode;

  @override
  void initState() {
    super.initState();
    _emailFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();
  }

  @override
  void dispose() {
    super.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
  }

  Future<void> _login(BuildContext context) async {
    _emailFocusNode.unfocus();
    _passwordFocusNode.unfocus();
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        Provider.of<LoginViewModel>(context, listen: false).setIsLoading(true);
        await _loginViewModel.login(email, password, context);
      } on FirebaseAuthException catch (e) {
        Provider.of<LoginViewModel>(context, listen: false).setIsLoading(false);
        if (e.code == 'user-not-found') {
          Components.errorDialog(context, 'No user found for that email.');
        } else if (e.code == 'wrong-password') {
          Components.errorDialog(context, 'Wrong password provided for that user.');
        } else if (e.code == 'network-request-failed') {
          Components.errorDialog(context, 'No internet connection.');
        } else {
          Components.errorDialog(context, 'Check your internet.\nTry again later.');
        }
      } catch (_) {
        Provider.of<LoginViewModel>(context, listen: false).setIsLoading(false);
        Components.errorDialog(context, 'Check your internet.\nTry again later.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    AppLocalizations? localization = AppLocalizations.of(context);
    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          alignment: AlignmentDirectional.topCenter,
          children: [
            Container(height: height),
            ClipPath(
              clipper: WaveClipperTwo(),
              child: Container(
                height: height * 0.30,
                decoration: BoxDecoration(
                  color: CustomColors.loginViewSecondColor,
                ),
              ),
            ),
            ClipPath(
              clipper: WaveClipperTwo(),
              child: Container(
                height: height * 0.25,
                decoration: BoxDecoration(
                  color: CustomColors.loginViewFirstColor,
                ),
              ),
            ),
            Positioned.fill(
              child: Align(
                alignment: AlignmentDirectional.bottomCenter,
                child: ClipPath(
                  clipper: WaveClipperTwo(reverse: true, flip: true),
                  child: Container(
                    height: height * 0.15,
                    decoration: BoxDecoration(
                      color: CustomColors.loginViewFirstColor,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 32.0,
              top: height * 0.40,
              child: Card(
                elevation: 10.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ),
                child: Form(
                  key: _formKey,
                  child: SizedBox(
                    width: width * 0.70,
                    height: height * 0.40,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            buildTextFormField(
                              context: context,
                              labelText: localization!.email,
                              textInputAction: TextInputAction.next,
                              textInputType: TextInputType.emailAddress,
                            ),
                            const SizedBox(
                              height: 16.0,
                            ),
                            buildTextFormField(
                              context: context,
                              labelText: localization.password,
                              textInputAction: TextInputAction.done,
                              textInputType: TextInputType.visiblePassword,
                              isPassword: true,
                            ),
                            const SizedBox(
                              height: 32.0,
                            ),
                            Consumer<LoginViewModel>(
                              builder: (BuildContext context, LoginViewModel value, _) {
                                return InkWell(
                                  borderRadius: BorderRadius.circular(50.0),
                                  onTap: () => !value.isLoading ? _login(context) : null,
                                  child: Ink(
                                    width: 150.0,
                                    height: 50.0,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50.0),
                                      gradient: LinearGradient(colors: [
                                        CustomColors.secondaryColor,
                                        CustomColors.primaryColor,
                                      ]),
                                    ),
                                    child: Center(
                                      child: !value.isLoading
                                          ? Text(
                                              localization.login.toUpperCase(),
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20.0,
                                                color: CustomColors.primaryTextColor,
                                              ),
                                            )
                                          : const CircularProgressIndicator(),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Directionality buildTextFormField(
      {required BuildContext context,
      required String labelText,
      required TextInputAction textInputAction,
      required TextInputType textInputType,
      isPassword = false}) {
    bool isPasswordVisible = Provider.of<LoginViewModel>(context).isPasswordVisible;
    return Directionality(
      textDirection: TextDirection.ltr,
      child: TextFormField(
        focusNode: isPassword ? _passwordFocusNode : _emailFocusNode,
        style: TextStyle(color: CustomColors.primaryTextColor),
        textInputAction: textInputAction,
        keyboardType: textInputType,
        obscureText: isPassword
            ? isPasswordVisible
                ? false
                : true
            : false,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(color: CustomColors.secondaryTextColor.withOpacity(0.6)),
          suffixIcon: isPassword
              ? IconButton(
                  onPressed: () {
                    Provider.of<LoginViewModel>(context, listen: false)
                        .setIsPasswordVisible(!isPasswordVisible);
                  },
                  icon: Icon(
                    isPasswordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: CustomColors.secondaryTextColor.withOpacity(0.6),
                  ))
              : null,
        ),
        validator: (String? value) {
          if (value == null || value.isEmpty) {
            if (!isPassword) {
              return AppLocalizations.of(context)!.pleaseEnterEmail;
            } else {
              return '${AppLocalizations.of(context)!.pleaseEnter} ${AppLocalizations.of(context)!.password}';
            }
          } else if (!isPassword) {
            if (RegExp(
                    r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$")
                .hasMatch(value)) {
              return null;
            }
            return AppLocalizations.of(context)!.pleaseEnterValidEmail;
          } else if (isPassword && value.length < 6) {
            return AppLocalizations.of(context)!.pleaseEnterValidPassword;
          }
          return null;
        },
        onSaved: (String? value) {
          if (isPassword) {
            password = value!;
          } else {
            email = value!;
          }
        },
      ),
    );
  }
}
