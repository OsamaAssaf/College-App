import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginViewModel with ChangeNotifier {
  bool isPasswordVisible = false;

  void setIsPasswordVisible(bool newValue) {
    isPasswordVisible = newValue;
    notifyListeners();
  }

  bool isSplashEnd = false;

  setIsSplashEnd(bool newValue) {
    isSplashEnd = newValue;
    notifyListeners();
  }

  String version = '';

  void setAppInfo(String version) {
    this.version = version;
    notifyListeners();
  }

  bool isLoading = false;

  setIsLoading(bool newValue) {
    isLoading = newValue;
    notifyListeners();
  }

  User? user;

  setUser(User? newUser) {
    user = newUser;
    notifyListeners();
  }

  String? majorKey;
  String? userEmail;
  int? year;

  setUserEmailAndMajorAndYear(String? email) {
    userEmail = email;
    if (userEmail != null) {
      int i = userEmail!.indexOf('@');
      majorKey = '${userEmail![i - 3]}${userEmail![i - 2]}${userEmail![i - 1]}'.toUpperCase();
      int addedYear = int.parse(userEmail.toString().replaceRange(4, null, ''));
      int currentYear = DateTime.now().year;
      year = currentYear - addedYear + 1;
    }

    notifyListeners();
  }

  int? _role = 2;

  int? get role => _role;

  void setRole(String newRole) {
    switch (newRole) {
      case 'std.jo':
        _role = 0;
        break;
      case 'thr.jo':
        _role = 1;
        break;
      default:
        _role = 2;
    }
    notifyListeners();
  }

  Future<void> login(String email, String password, BuildContext context) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (_) {
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    isSplashEnd = false;
    _role = null;
    isLoading = false;
    notifyListeners();
  }
}
