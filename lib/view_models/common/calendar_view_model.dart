import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CalendarViewModel extends ChangeNotifier {
  DateTime? selectedDay;
  DateTime focusedDay = DateTime.now();

  void setSelectedDay(DateTime day) {
    selectedDay = day;
    notifyListeners();
  }

  void setFocusedDay(DateTime day) {
    focusedDay = day;
    notifyListeners();
  }

  List eventMessages = [];

  void setEventMessage(List newValue) {
    eventMessages = newValue;
    notifyListeners();
  }

  Stream<QuerySnapshot> getStreamData() {
    final CollectionReference<Map<String, dynamic>> data =
        FirebaseFirestore.instance.collection('calendar_events');
    return data.snapshots();
  }

  void showEventsForDay(BuildContext context, Map<String, dynamic> events, DateTime selectedDay) {
    String date = selectedDay.toIso8601String().split('T')[0];

    if (events.containsKey(date)) {
      List eventsList = [];
      events[date].forEach((key, value) {
        eventsList.add(value);
      });
      setEventMessage(eventsList);
    } else {
      setEventMessage([
        {'title': AppLocalizations.of(context)!.thereIsNoEvents}
      ]);
    }
    notifyListeners();
  }

  Future<void> deleteEvent(BuildContext context, DateTime selectedDay, int eventID, mounted) async {
    String eventDate = selectedDay.toIso8601String().split('T')[0];
    final DocumentReference<Map<String, dynamic>> eventPath =
        FirebaseFirestore.instance.collection('calendar_events').doc(eventDate);
    try {
      final DocumentSnapshot<Map<String, dynamic>> res = await eventPath.get();
      Map<String, dynamic>? events = res.data();
      if (events != null) {
        events.remove(eventID.toString());
      }
      if (events!.isEmpty) {
        await eventPath.delete();
      } else {
        await eventPath.set(events);
      }
      Map<String, dynamic> event = {
        eventDate: events,
      };
      if (!mounted) return;
      showEventsForDay(context, event, selectedDay);
    } catch (_) {
      rethrow;
    }
  }

  bool deleteEventLoading = false;

  void setDeleteEventLoading(bool newValue) {
    deleteEventLoading = newValue;
    notifyListeners();
  }
}
