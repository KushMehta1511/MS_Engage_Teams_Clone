import 'package:flutter/material.dart';
import 'package:ms_teams_clone_engage/calendar/event_data_source.dart';
import 'package:ms_teams_clone_engage/calendar/event_provider.dart';
import 'package:ms_teams_clone_engage/calendar/tasks_widget.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

//Calendar Widget stateful widget
class CalendarWidget extends StatelessWidget {
  const CalendarWidget({Key? key}) : super(key: key);

  //Building calendar UI using Sfcalendar
  @override
  Widget build(BuildContext context) {
    final events = Provider.of<EventProvider>(context).events;
    return SfCalendar(
      view: CalendarView.month,
      cellBorderColor: Theme.of(context).primaryColor,
      dataSource: EventDataSource(events),
      todayTextStyle: TextStyle(color: Colors.white),
      todayHighlightColor: Theme.of(context).primaryColor,
      initialSelectedDate: DateTime.now(),
      onLongPress: (details) {
        //showing details upon long press on calendar event
        final provider = Provider.of<EventProvider>(context, listen: false);
        provider.setDate(details.date!);
        //Displaying event selected
        showModalBottomSheet(
            context: context, builder: (context) => TasksWidget());
      },
    );
  }
}
