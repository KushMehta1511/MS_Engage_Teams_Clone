import 'package:flutter/material.dart';
import 'package:ms_teams_clone_engage/calendar/event.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

//Creating the event data source and its necessary functions
class EventDataSource extends CalendarDataSource {
  EventDataSource(List<Event> appointments) {
    this.appointments = appointments;
  }
  //Function to get a particular event
  Event getEvent(int index) {
    return appointments![index] as Event;
  }

  //Function to get start time of event
  @override
  DateTime getStartTime(int index) {
    return getEvent(index).from;
  }

  //Function to get end time of event
  @override
  DateTime getEndTime(int index) {
    return getEvent(index).to;
  }

  //Function to get subject of event
  @override
  String getSubject(int index) {
    return getEvent(index).title;
  }

  //Function to get background color of event
  @override
  Color getColor(int index) {
    return getEvent(index).backgroundColor;
  }

  //Function to check if event is for entire day or not
  @override
  bool isAllDay(int index) {
    return getEvent(index).isAllDay;
  }
}
