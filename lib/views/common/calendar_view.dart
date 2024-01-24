import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../res/colors.dart';
import '../../res/components.dart';
import '../../view_models/admin/add_event_view_model.dart';
import '../../view_models/common/calendar_view_model.dart';
import '../../view_models/common/home_view_model.dart';
import '../../view_models/login/login_view_model.dart';
import '../admin/add_event_view.dart';

class CalendarView extends StatefulWidget {
  const CalendarView({Key? key}) : super(key: key);

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  final CalendarViewModel _viewModel = CalendarViewModel();

  @override
  Widget build(BuildContext context) {
    AppLocalizations? localization = AppLocalizations.of(context);
    return Scaffold(
      appBar: Components.commonAppBar(
        localization!.calendar,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _viewModel.getStreamData(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasData) {
            Map<String, dynamic> mapEvents = {};
            if (snapshot.data!.docs.isNotEmpty) {
              List events = snapshot.data!.docs;
              for (var element in events) {
                mapEvents[element.id] = element.data();
              }
            }
            return Consumer<CalendarViewModel>(
              builder: (BuildContext context, CalendarViewModel provider, _) {
                return buildCalendar(context, provider, mapEvents, localization);
              },
            );
          }
          return Center(
            child: Components.errorImage(localization),
          );
        },
      ),
    );
  }

  SingleChildScrollView buildCalendar(BuildContext context, CalendarViewModel provider,
      Map<String, dynamic> events, AppLocalizations? localization) {
    double height = MediaQuery.of(context).size.height;
    DateTime focusedDay = provider.focusedDay;
    DateTime? selectedDay = provider.selectedDay;
    List eventMessages = provider.eventMessages;
    String locale = Provider.of<HomeViewModel>(context).locale.toString();
    int? role = Provider.of<LoginViewModel>(context).role;
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: height),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildTableCalendar(locale, focusedDay, selectedDay, provider, context, events),
            const Divider(),
            DefaultTextStyle(
              style: GoogleFonts.nunito(
                fontSize: 18.0,
                color: CustomColors.primaryTextColor,
                fontWeight: FontWeight.bold,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: eventMessages.isNotEmpty
                          ? SingleChildScrollView(
                              physics: const NeverScrollableScrollPhysics(),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8.0),
                                    margin: const EdgeInsets.only(bottom: 8.0),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: CustomColors.secondaryColor),
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                    child: Text(selectedDay!.toIso8601String().split('T')[0]),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(8.0),
                                    margin: const EdgeInsets.only(bottom: 8.0),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: CustomColors.secondaryColor),
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                    child: (eventMessages.length == 1 &&
                                            eventMessages[0]['title'] ==
                                                localization!.thereIsNoEvents)
                                        ? Text(eventMessages[0]['title'])
                                        : Column(
                                            children: [
                                              for (int i = 0; i < eventMessages.length; i++)
                                                InkWell(
                                                  child:
                                                      Text('${i + 1}-${eventMessages[i]['title']}'),
                                                  onTap: () {
                                                    {
                                                      showDialog(
                                                        context: context,
                                                        builder: (ctx) {
                                                          return AlertDialog(
                                                            backgroundColor:
                                                                CustomColors.canvasColor,
                                                            content: SingleChildScrollView(
                                                              child: DefaultTextStyle(
                                                                style: GoogleFonts.nunito(
                                                                    color: CustomColors
                                                                        .primaryTextColor,
                                                                    fontSize: 16.0),
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment.start,
                                                                  children: [
                                                                    Row(
                                                                      children: [
                                                                        Text(provider.selectedDay!
                                                                            .toIso8601String()
                                                                            .split('T')[0]),
                                                                        Padding(
                                                                          padding: const EdgeInsets
                                                                              .symmetric(
                                                                              horizontal: 8.0),
                                                                          child: CircleAvatar(
                                                                            radius: 2,
                                                                            backgroundColor:
                                                                                CustomColors
                                                                                    .greyColor,
                                                                          ),
                                                                        ),
                                                                        Text(DateFormat('EEEE')
                                                                            .format(provider
                                                                                .selectedDay!)),
                                                                      ],
                                                                    ),
                                                                    const SizedBox(
                                                                      height: 16.0,
                                                                    ),
                                                                    if (eventMessages[i]
                                                                            ['imageUrl'] !=
                                                                        null)
                                                                      Image.network(eventMessages[i]
                                                                          ['imageUrl']),
                                                                    if (eventMessages[i]
                                                                            ['imageUrl'] !=
                                                                        null)
                                                                      const SizedBox(
                                                                        height: 16.0,
                                                                      ),
                                                                    Text(
                                                                        '${localization!.title}: ${eventMessages[i]['title']}'),
                                                                    if (eventMessages[i]
                                                                            ['description'] !=
                                                                        null)
                                                                      const SizedBox(
                                                                        height: 16.0,
                                                                      ),
                                                                    if (eventMessages[i]
                                                                            ['description'] !=
                                                                        null)
                                                                      Text(
                                                                          '${localization.description}: ${eventMessages[i]['description']}'),
                                                                    const SizedBox(
                                                                      height: 16.0,
                                                                    ),
                                                                    if (role == 2)
                                                                      ElevatedButton(
                                                                        onPressed: provider
                                                                                .deleteEventLoading
                                                                            ? null
                                                                            : () async {
                                                                                try {
                                                                                  provider
                                                                                      .setDeleteEventLoading(
                                                                                          true);
                                                                                  await provider.deleteEvent(
                                                                                      context,
                                                                                      selectedDay,
                                                                                      eventMessages[
                                                                                              i][
                                                                                          'eventID'],
                                                                                      mounted);
                                                                                } catch (e) {
                                                                                  Components.showToast(
                                                                                      localization
                                                                                          .somethingWrong);
                                                                                }
                                                                                provider
                                                                                    .setDeleteEventLoading(
                                                                                        false);
                                                                                if (!mounted) {
                                                                                  return;
                                                                                }
                                                                                Navigator.pop(ctx);
                                                                              },
                                                                        style: ButtonStyle(
                                                                          textStyle:
                                                                              MaterialStateProperty.all<
                                                                                      TextStyle>(
                                                                                  const TextStyle(
                                                                                      fontSize:
                                                                                          20.0)),
                                                                        ),
                                                                        child: Text(localization
                                                                            .deleteEvent),
                                                                      ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      );
                                                    }
                                                  },
                                                ),
                                            ],
                                          ),
                                  ),
                                  if (role == 2)
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) => ChangeNotifierProvider(
                                              create: (_) => AddEventViewModel(),
                                              child: AddEventView(
                                                  selectedDay: selectedDay,
                                                  calendarContext: context,
                                                  currentEvents: events[
                                                      selectedDay.toIso8601String().split('T')[0]]),
                                            ),
                                          ),
                                        );
                                      },
                                      style: ButtonStyle(
                                        textStyle: MaterialStateProperty.all<TextStyle>(
                                            const TextStyle(fontSize: 20.0)),
                                      ),
                                      child: Text(localization!.addEvent),
                                    ),
                                ],
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.only(top: 16.0),
                              child: Column(
                                children: [
                                  if (role != 2)
                                    Text(AppLocalizations.of(context)!.selectEventsDayToSee),
                                  if (role == 2)
                                    Text(AppLocalizations.of(context)!.selectEventsDayToAdd),
                                ],
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<Expanded> buildExpanded(
      double width,
      List<dynamic> eventMessages,
      DateTime? selectedDay,
      AppLocalizations? localization,
      BuildContext context,
      CalendarViewModel provider,
      int? role,
      Map<String, dynamic> events) async {
    return Expanded(
      child: DefaultTextStyle(
        style: GoogleFonts.nunito(
          fontSize: 18.0,
          color: CustomColors.primaryTextColor,
          fontWeight: FontWeight.bold,
        ),
        child: Row(
          children: [
            Container(
              width: width * 0.15,
              decoration: BoxDecoration(
                color: CustomColors.secondaryColor,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(15.0),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: eventMessages.isNotEmpty
                    ? SingleChildScrollView(
                        physics: const NeverScrollableScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8.0),
                              margin: const EdgeInsets.only(bottom: 8.0),
                              decoration: BoxDecoration(
                                border: Border.all(color: CustomColors.secondaryColor),
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: Text(selectedDay!.toIso8601String().split('T')[0]),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8.0),
                              margin: const EdgeInsets.only(bottom: 8.0),
                              decoration: BoxDecoration(
                                border: Border.all(color: CustomColors.secondaryColor),
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: (eventMessages.length == 1 &&
                                      eventMessages[0]['title'] == localization!.thereIsNoEvents)
                                  ? Text(eventMessages[0]['title'])
                                  : Column(
                                      children: [
                                        for (int i = 0; i < eventMessages.length; i++)
                                          InkWell(
                                            child: Text('${i + 1}-${eventMessages[i]['title']}'),
                                            onTap: () {
                                              {
                                                showDialog(
                                                  context: context,
                                                  builder: (ctx) {
                                                    return AlertDialog(
                                                      backgroundColor: CustomColors.canvasColor,
                                                      content: SingleChildScrollView(
                                                        child: DefaultTextStyle(
                                                          style: GoogleFonts.nunito(
                                                              color: CustomColors.primaryTextColor,
                                                              fontSize: 16.0),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment.start,
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  Text(provider.selectedDay!
                                                                      .toIso8601String()
                                                                      .split('T')[0]),
                                                                  Padding(
                                                                    padding:
                                                                        const EdgeInsets.symmetric(
                                                                            horizontal: 8.0),
                                                                    child: CircleAvatar(
                                                                      radius: 2,
                                                                      backgroundColor:
                                                                          CustomColors.greyColor,
                                                                    ),
                                                                  ),
                                                                  Text(DateFormat('EEEE').format(
                                                                      provider.selectedDay!)),
                                                                ],
                                                              ),
                                                              const SizedBox(
                                                                height: 16.0,
                                                              ),
                                                              if (eventMessages[i]['imageUrl'] !=
                                                                  null)
                                                                Image.network(
                                                                    eventMessages[i]['imageUrl']),
                                                              if (eventMessages[i]['imageUrl'] !=
                                                                  null)
                                                                const SizedBox(
                                                                  height: 16.0,
                                                                ),
                                                              Text(
                                                                  '${localization!.title}: ${eventMessages[i]['title']}'),
                                                              if (eventMessages[i]['description'] !=
                                                                  null)
                                                                const SizedBox(
                                                                  height: 16.0,
                                                                ),
                                                              if (eventMessages[i]['description'] !=
                                                                  null)
                                                                Text(
                                                                    '${localization.description}: ${eventMessages[i]['description']}'),
                                                              const SizedBox(
                                                                height: 16.0,
                                                              ),
                                                              if (role == 2)
                                                                ElevatedButton(
                                                                  onPressed: provider
                                                                          .deleteEventLoading
                                                                      ? null
                                                                      : () async {
                                                                          try {
                                                                            provider
                                                                                .setDeleteEventLoading(
                                                                                    true);
                                                                            await provider
                                                                                .deleteEvent(
                                                                                    context,
                                                                                    selectedDay,
                                                                                    eventMessages[i]
                                                                                        ['eventID'],
                                                                                    mounted);
                                                                          } catch (e) {
                                                                            Components.showToast(
                                                                                localization
                                                                                    .somethingWrong);
                                                                          }
                                                                          provider
                                                                              .setDeleteEventLoading(
                                                                                  false);
                                                                          if (!mounted) return;
                                                                          Navigator.pop(ctx);
                                                                        },
                                                                  style: ButtonStyle(
                                                                    textStyle: MaterialStateProperty
                                                                        .all<TextStyle>(
                                                                            const TextStyle(
                                                                                fontSize: 20.0)),
                                                                  ),
                                                                  child: Text(
                                                                      localization.deleteEvent),
                                                                ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                );
                                              }
                                            },
                                          ),
                                      ],
                                    ),
                            ),
                            if (role == 2)
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => ChangeNotifierProvider(
                                        create: (_) => AddEventViewModel(),
                                        child: AddEventView(
                                            selectedDay: selectedDay,
                                            calendarContext: context,
                                            currentEvents: events[
                                                selectedDay.toIso8601String().split('T')[0]]),
                                      ),
                                    ),
                                  );
                                },
                                style: ButtonStyle(
                                  textStyle: MaterialStateProperty.all<TextStyle>(
                                      const TextStyle(fontSize: 20.0)),
                                ),
                                child: Text(localization!.addEvent),
                              ),
                          ],
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Column(
                          children: [
                            if (role != 2) Text(AppLocalizations.of(context)!.selectEventsDayToSee),
                            if (role == 2) Text(AppLocalizations.of(context)!.selectEventsDayToAdd),
                          ],
                        ),
                      ),
              ),
            ),
            Container(
              width: width * 0.15,
              decoration: BoxDecoration(
                color: CustomColors.secondaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TableCalendar<dynamic> buildTableCalendar(
      String locale,
      DateTime focusedDay,
      DateTime? selectedDay,
      CalendarViewModel provider,
      BuildContext context,
      Map<String, dynamic> events) {
    return TableCalendar(
      locale: locale,
      daysOfWeekHeight: 24.0,
      firstDay: DateTime.utc(2022, 1, 1),
      lastDay: DateTime.utc(2025, 1, 1),
      weekendDays: const [DateTime.saturday, DateTime.friday],
      focusedDay: focusedDay,
      startingDayOfWeek: StartingDayOfWeek.saturday,
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextStyle: TextStyle(
            fontWeight: FontWeight.bold, fontSize: 17.0, color: CustomColors.primaryTextColor),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: TextStyle(color: CustomColors.primaryTextColor),
      ),
      calendarStyle: CalendarStyle(
          tableBorder: const TableBorder(
              horizontalInside: BorderSide(color: Colors.grey),
              verticalInside: BorderSide(color: Colors.grey)),
          defaultTextStyle: TextStyle(color: CustomColors.primaryTextColor),
          selectedDecoration: BoxDecoration(
            color: CustomColors.secondaryColor,
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: CustomColors.primaryTextColor,
            shape: BoxShape.circle,
          ),
          holidayTextStyle: const TextStyle(color: Colors.grey),
          holidayDecoration: BoxDecoration(
            border: Border.fromBorderSide(
              BorderSide(color: CustomColors.secondaryColor, width: 1.4),
            ),
            shape: BoxShape.circle,
          )),
      holidayPredicate: (DateTime day) {
        if (day.weekday == DateTime.friday || day.weekday == DateTime.saturday) {
          return true;
        }
        return false;
      },
      selectedDayPredicate: (DateTime day) {
        return isSameDay(selectedDay, day);
      },
      onDaySelected: (DateTime selectedDay, DateTime focusedDay) {
        provider.setSelectedDay(selectedDay);
        provider.setFocusedDay(focusedDay);
        provider.showEventsForDay(context, events, selectedDay);
      },
      onPageChanged: (DateTime focusedDay) {
        focusedDay = focusedDay;
      },
      eventLoader: (DateTime day) {
        String date = day.toIso8601String().split('T')[0];
        if (events.containsKey(date)) {
          List result = [];
          for (int i = 0; i < events[date].length; i++) {
            result.add(events[date][i]);
          }
          return result;
        }
        return [];
      },
    );
  }
}
