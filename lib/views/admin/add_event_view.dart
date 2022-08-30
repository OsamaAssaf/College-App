import 'dart:io';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../models/calender_event_model.dart';
import '../../res/colors.dart';
import '../../res/components.dart';
import '../../view_models/admin/add_event_view_model.dart';
import '../../view_models/common/calendar_view_model.dart';

class AddEventView extends StatefulWidget {
  const AddEventView(
      {Key? key,
      required this.selectedDay,
      required this.calendarContext,
      required this.currentEvents})
      : super(key: key);

  final DateTime selectedDay;
  final BuildContext calendarContext;
  final Map<String, dynamic>? currentEvents;

  @override
  State<AddEventView> createState() => _AddEventViewState();
}

class _AddEventViewState extends State<AddEventView> {
  final AddEventViewModel _viewModel = AddEventViewModel();

  late TextEditingController _eventTitleController;
  late TextEditingController _eventDescriptionController;

  Widget addEvent(AppLocalizations? localization, File? imageFile, AddEventViewModel provider) {
    return !provider.isLoading
        ? TextButton.icon(
            icon: const Icon(Icons.add),
            style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all<Color>(CustomColors.secondaryTextColor),
            ),
            label: Text(localization!.add),
            onPressed: () async {
              if (_eventTitleController.text.isEmpty) {
                Components.showToast('You must add title');
                return;
              }
              String title = _eventTitleController.text;
              String? description = _eventDescriptionController.text.isEmpty
                  ? null
                  : _eventDescriptionController.text;
              try {
                provider.setIsLoading(true);
                int eventID = await _viewModel.getEventID();
                String? imageUrl;
                if (imageFile != null) {
                  imageUrl = await _viewModel.uploadImageToFirebase(eventID, imageFile);
                }
                CalenderEventModel eventModel = CalenderEventModel(
                  eventID: eventID,
                  title: title,
                  description: description,
                  imageUrl: imageUrl,
                );
                await _viewModel.uploadEvent(eventModel, widget.selectedDay);
                Map<String, dynamic> currentEvents = {};
                if (widget.currentEvents != null) {
                  currentEvents = widget.currentEvents!;
                  currentEvents[eventID.toString()] = eventModel.toJSON();
                } else {
                  currentEvents[eventID.toString()] = eventModel.toJSON();
                }
                Map<String, dynamic> event = {
                  widget.selectedDay.toIso8601String().split('T')[0]: currentEvents
                };
                if (!mounted) return;
                Provider.of<CalendarViewModel>(widget.calendarContext, listen: false)
                    .showEventsForDay(widget.calendarContext, event, widget.selectedDay);
                Components.showSuccessToast(localization.eventAdded);
                Navigator.pop(context);
              } catch (_) {
                provider.setIsLoading(false);
                Components.errorDialog(context, localization.somethingWrong);
              }
            },
          )
        : const Center(child: CircularProgressIndicator());
  }

  @override
  void initState() {
    super.initState();
    _eventTitleController = TextEditingController();
    _eventDescriptionController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _eventTitleController.dispose();
    _eventDescriptionController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations? localization = AppLocalizations.of(context);
    return Consumer<AddEventViewModel>(
      builder: (BuildContext context, AddEventViewModel provider, _) {
        return Scaffold(
          appBar: Components.commonAppBar(localization!.addNewEvent,
              actions: [addEvent(localization, provider.imageFile, provider)]),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  TextField(
                    controller: _eventTitleController,
                    readOnly: provider.isLoading,
                    style: TextStyle(color: CustomColors.secondaryTextColor),
                    decoration: InputDecoration(
                      label: Text(localization.title),
                      labelStyle: TextStyle(
                        color: CustomColors.secondaryTextColor.withOpacity(0.6),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 8.0,
                  ),
                  TextField(
                    controller: _eventDescriptionController,
                    readOnly: provider.isLoading,
                    style: TextStyle(color: CustomColors.secondaryTextColor),
                    minLines: 2,
                    maxLines: 4,
                    decoration: InputDecoration(
                        labelStyle: TextStyle(
                          color: CustomColors.secondaryTextColor.withOpacity(0.6),
                        ),
                        label: Text(localization.description)),
                  ),
                  const SizedBox(
                    height: 8.0,
                  ),
                  const Divider(),
                  OutlinedButton(
                    onPressed: () async {
                      if (provider.isLoading) {
                        return;
                      }
                      await provider.pickImage(context);
                    },
                    child: Text(localization.chooseImage),
                  ),
                  const SizedBox(
                    height: 8.0,
                  ),
                  Container(
                    child: provider.imageFile != null ? Image.file(provider.imageFile!) : null,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
