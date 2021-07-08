import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ms_teams_clone_engage/calendar/calendar_event_editing_page.dart';
import 'package:ms_teams_clone_engage/calendar/calendar_widget.dart';
import 'package:ms_teams_clone_engage/calendar/event.dart';
import 'package:ms_teams_clone_engage/calendar/event_provider.dart';
import 'package:ms_teams_clone_engage/authentication/login_page.dart';
import 'package:ms_teams_clone_engage/main.dart';
import 'package:provider/provider.dart';

class CalendarClass extends StatefulWidget {
  const CalendarClass({Key? key}) : super(key: key);

  @override
  _CalendarClassState createState() => _CalendarClassState();
}

class _CalendarClassState extends State<CalendarClass> {
  final _auth = FirebaseAuth.instance;
  final _calendarRef = FirebaseFirestore.instance
      .collection('calendarEvents')
      .doc(currentUser.uid)
      .collection('events');

  getEvents() {
    return StreamBuilder(
        stream: _calendarRef.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            print("no data");
            return Center(
              child: SizedBox(
                height: 75.0,
                width: 75.0,
                child: CircularProgressIndicator(),
              ),
            );
          }
          final events = snapshot.data!.docs;
          final provider = Provider.of<EventProvider>(context, listen: false);
          for (var event in events) {
            final title = event.get('title');
            final description = event.get('description');
            final from = DateTime.fromMicrosecondsSinceEpoch(
                event.get('from').microsecondsSinceEpoch);
            final to = DateTime.fromMicrosecondsSinceEpoch(
                event.get('to').microsecondsSinceEpoch);
            final eventCreate = new Event(
                title: title, description: description, from: from, to: to);
            provider.addEvent(eventCreate);
          }
          return CalendarWidget();
        });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      // Add Your Code here.
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text("Calendar"),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              _auth.signOut();
              Navigator.pop(context);
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => MyApp()));
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: getEvents(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => EventEditingPage()));
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
