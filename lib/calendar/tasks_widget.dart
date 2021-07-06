import 'package:flutter/material.dart';
import 'package:ms_teams_clone_engage/calendar/event_data_source.dart';
import 'package:ms_teams_clone_engage/calendar/event_provider.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class TasksWidget extends StatefulWidget {
  const TasksWidget({Key? key}) : super(key: key);

  @override
  _TasksWidgetState createState() => _TasksWidgetState();
}

class _TasksWidgetState extends State<TasksWidget> {
  Widget appointmentBuilder(
      BuildContext context, CalendarAppointmentDetails details) {
    final event = details.appointments.first;
    return Container(
      width: details.bounds.width,
      height: details.bounds.height,
      decoration: BoxDecoration(
        color: event.backgroundColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(event.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            )),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<EventProvider>(context);
    final selectedEvents = provider.eventOfSelectedDate;
    if (selectedEvents.isEmpty) {
      return Center(
          child: Text(
        'No Events Found',
        style: TextStyle(color: Colors.black, fontSize: 24),
      ));
    }
    return SfCalendar(
      view: CalendarView.timelineDay,
      dataSource: EventDataSource(provider.events),
      initialDisplayDate: provider.selectedDate,
      headerHeight: 0,
      todayHighlightColor: Colors.black,
      selectionDecoration: BoxDecoration(
        color: Colors.transparent,
      ),
      appointmentBuilder: appointmentBuilder,
    );
  }
}
