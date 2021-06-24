import 'package:flutter/material.dart';
import 'package:ms_teams_clone_engage/event_data_source.dart';
import 'package:ms_teams_clone_engage/event_provider.dart';
import 'package:ms_teams_clone_engage/tasks_widget.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class CalendarWidget extends StatelessWidget {
  const CalendarWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final events = Provider.of<EventProvider>(context).events;
    return SfCalendar(
      view: CalendarView.month,
      dataSource: EventDataSource(events),
      initialSelectedDate: DateTime.now(),
      onLongPress: (details) {
        final provider = Provider.of<EventProvider>(context, listen: false);
        provider.setDate(details.date!);

        showModalBottomSheet(
            context: context, builder: (context) => TasksWidget());
      },
    );
  }
}
