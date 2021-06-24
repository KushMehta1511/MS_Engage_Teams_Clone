import 'package:flutter/material.dart';
import 'package:ms_teams_clone_engage/calendar_event_editing_page.dart';
import 'package:ms_teams_clone_engage/calendar_widget.dart';
import 'package:ms_teams_clone_engage/event_provider.dart';
import 'package:ms_teams_clone_engage/login_page.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class CalendarClass extends StatefulWidget {
  const CalendarClass({Key? key}) : super(key: key);

  @override
  _CalendarClassState createState() => _CalendarClassState();
}

class _CalendarClassState extends State<CalendarClass> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text("Calendar"),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => LoginPage()));
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: CalendarWidget(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => EventEditingPage()));
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
