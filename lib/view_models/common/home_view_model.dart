import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeViewModel with ChangeNotifier {
  Locale? locale;

  Future<void> initLocale() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedLocal = (prefs.get('locale') ?? 'en') as String?;
    locale = Locale(savedLocal!);
    notifyListeners();
  }

  Future<void> setLocale(Locale value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('locale', value.toString());
    locale = value;
    notifyListeners();
  }

  int sliderIndex = 0;

  void setSliderIndex(int index) {
    sliderIndex = index;
    notifyListeners();
  }

  List<String> sliderImages = [
    'assets/images/home/slider_image/img1.jpg',
    'assets/images/home/slider_image/img2.jpg',
    'assets/images/home/slider_image/img3.jpg',
    'assets/images/home/slider_image/img4.jpg',
    'assets/images/home/slider_image/img5.jpg',
  ];

  List<String> cardImages = [
    'assets/images/home/card_image/student.png',
    'assets/images/home/card_image/teacher.png',
    'assets/images/home/card_image/admin.png',
    'assets/images/home/card_image/about.png',
  ];
}
