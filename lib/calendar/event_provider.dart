import 'package:flutter/cupertino.dart';
import 'package:ms_teams_clone_engage/calendar/event.dart';

//Creates the provider and notifies the state changes
class EventProvider extends ChangeNotifier {
  final List<Event> _events = [];
  List<Event> get events {
    return _events;
  }

  DateTime _selectedDate = DateTime.now();

  DateTime get selectedDate => _selectedDate;

  void setDate(DateTime date) => _selectedDate = date;

  List<Event> get eventOfSelectedDate => _events;

  void addEvent(Event event) {
    _events.add(event);
    notifyListeners();
  }
}
