import 'package:college_app/res/colors.dart';
import 'package:college_app/views/common/map_view.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../res/components.dart';
import '../../res/widgets/grid_card.dart';
import '../../view_models/common/home_view_model.dart';
import '../../view_models/login/login_view_model.dart';
import 'about_view.dart';
import '../admin/user_adminstrations_view.dart';
import '../admin/admin_view.dart';
import 'profile_view.dart';
import '../student/student_view.dart';
import '../teacher/teacher_view.dart';

class HomeView extends StatelessWidget {
  HomeView({Key? key}) : super(key: key);

  final HomeViewModel _viewModel = HomeViewModel();

  @override
  Widget build(BuildContext context) {
    AppLocalizations? localization = AppLocalizations.of(context);
    double height = MediaQuery.of(context).size.height;
    int? role = Provider.of<LoginViewModel>(context).role;
    String version = Provider.of<LoginViewModel>(context).version;
    return Consumer<HomeViewModel>(
      builder: (BuildContext context, HomeViewModel provider, _) {
        return Scaffold(
          appBar: Components.commonAppBar(localization!.home),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Stack(
                    alignment: AlignmentDirectional.topCenter,
                    children: [
                      CarouselSlider.builder(
                        itemCount: _viewModel.sliderImages.length,
                        itemBuilder: (BuildContext context, int index, int realIndex) {
                          return SizedBox(
                            width: double.infinity,
                            height: height * 0.20,
                            child: Image.asset(
                              _viewModel.sliderImages[index],
                              fit: BoxFit.cover,
                            ),
                          );
                        },
                        options: CarouselOptions(
                            viewportFraction: 1.0,
                            autoPlay: true,
                            onPageChanged: (int index, _) {
                              Provider.of<HomeViewModel>(context, listen: false)
                                  .setSliderIndex(index);
                            }),
                      ),
                      Positioned(
                        bottom: 16.0,
                        child: Row(
                          children: _viewModel.sliderImages.map(
                            (image) {
                              int imageIndex = _viewModel.sliderImages.indexOf(image);
                              return Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Consumer<HomeViewModel>(
                                  builder: (BuildContext context, HomeViewModel value, _) {
                                    return CircleAvatar(
                                      radius: imageIndex == value.sliderIndex ? 7.5 : 5.0,
                                      backgroundColor: imageIndex == value.sliderIndex
                                          ? Theme.of(context).colorScheme.primary
                                          : Colors.grey,
                                    );
                                  },
                                ),
                              );
                            },
                          ).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 2,
                    mainAxisSpacing: 16.0,
                    crossAxisSpacing: 16.0,
                    children: [
                      if (role != 1)
                        GridCard(
                          title: localization.students,
                          image: _viewModel.cardImages[0],
                          onTap: () {
                            if (role == 0) {
                              Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (_) => StudentView()));
                              return;
                            }
                            if (role == 2) {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => const AdminConfigurationsView(
                                  roleChosen: 0,
                                ),
                              ));
                            }
                          },
                        ),
                      if (role != 0)
                        GridCard(
                          title: localization.teachers,
                          image: _viewModel.cardImages[1],
                          onTap: () {
                            if (role == 1) {
                              Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (_) => TeacherView()));
                              return;
                            }
                            if (role == 2) {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => const AdminConfigurationsView(
                                  roleChosen: 1,
                                ),
                              ));
                            }
                          },
                        ),
                      if (role == 2)
                        GridCard(
                          title: localization.admins,
                          image: _viewModel.cardImages[2],
                          onTap: () {
                            Navigator.of(context)
                                .push(MaterialPageRoute(builder: (_) => AdminView()));
                          },
                        ),
                      GridCard(
                        title: localization.about,
                        image: _viewModel.cardImages[3],
                        onTap: () {
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (_) => const AboutView()));
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          drawer: Drawer(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: DrawerHeader(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    child: Text(
                      localization.appName,
                      style: TextStyle(fontSize: 32.0, color: CustomColors.primaryTextColor),
                    ),
                  ),
                ),
                ListTile(
                  title: Text(localization.profile),
                  leading: const Icon(Icons.person),
                  onTap: () {
                    int? role = Provider.of<LoginViewModel>(context, listen: false).role;
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (_) => ProfileView(role: role!)));
                  },
                ),
                const Divider(),
                ListTile(
                  title: Text(localization.map),
                  leading: const Icon(Icons.map_rounded),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => ShowMapView()));
                  },
                ),
                const Divider(),
                ExpansionTile(
                  title: Text(localization.language),
                  leading: const Icon(Icons.language_outlined),
                  children: [
                    TextButton(
                        onPressed: () {
                          provider.setLocale(const Locale('ar'));
                        },
                        style: ButtonStyle(
                          textStyle: MaterialStateProperty.all<TextStyle>(
                              const TextStyle(fontWeight: FontWeight.normal)),
                        ),
                        child: const Text("العربية")),
                    TextButton(
                        onPressed: () {
                          provider.setLocale(const Locale('en'));
                        },
                        style: ButtonStyle(
                          textStyle: MaterialStateProperty.all<TextStyle>(
                              const TextStyle(fontWeight: FontWeight.normal)),
                        ),
                        child: const Text("English")),
                  ],
                ),
                const Divider(),
                ListTile(
                  title: Text(
                    localization.logout,
                    style: TextStyle(color: CustomColors.redColor),
                  ),
                  leading: Icon(
                    Icons.logout_outlined,
                    color: CustomColors.redColor,
                  ),
                  onTap: () async {
                    await Provider.of<LoginViewModel>(context, listen: false).logout();
                  },
                ),
                const Divider(),
                ListTile(
                  title: Text(localization.about),
                  leading: const Icon(Icons.info_outline_rounded),
                  onTap: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (_) => const AboutView()));
                  },
                ),
                const Spacer(),
                Text(
                  '${localization.version} $version',
                  style: TextStyle(color: CustomColors.primaryTextColor),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
