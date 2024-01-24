import 'package:cached_network_image/cached_network_image.dart';
import 'package:college_app/res/components.dart';
import 'package:college_app/view_models/common/map_view_model.dart';
import 'package:college_app/view_models/login/login_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class ShowMapView extends StatelessWidget {
  ShowMapView({Key? key}) : super(key: key);

  final ShowMapViewModel _viewModel = ShowMapViewModel();
  final List<Widget> actions = [];
  @override
  Widget build(BuildContext context) {
    AppLocalizations? localization = AppLocalizations.of(context);

    int? role = Provider.of<LoginViewModel>(context).role;
    if (role == 2) {
      actions.add(TextButton(
          onPressed: () {
            _viewModel.pickImage(context);
          },
          child: Text(localization!.edit)));
    }

    return Scaffold(
      appBar: Components.commonAppBar(localization!.map, actions: actions),
      body: Center(
        child: FutureBuilder(
          future: _viewModel.getMapImageUrl(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasData) {
              String imageURL = snapshot.data;
              return InteractiveViewer(
                child: RotatedBox(
                  quarterTurns: 1,
                  child: CachedNetworkImage(
                    imageUrl: imageURL,
                    placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => Components.errorImage(localization),
                    fit: BoxFit.contain,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              );
            }
            return Center(
              child: Components.errorImage(localization),
            );
          },
        ),
      ),
    );
  }
}
