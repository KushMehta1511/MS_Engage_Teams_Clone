import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ms_teams_clone_engage/event.dart';
import 'package:ms_teams_clone_engage/event_provider.dart';
import 'package:provider/provider.dart';

class EventEditingPage extends StatefulWidget {
  final Event? event;
  const EventEditingPage({Key? key, this.event}) : super(key: key);

  @override
  _EventEditingPageState createState() => _EventEditingPageState();
}

class _EventEditingPageState extends State<EventEditingPage> {
  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  late DateTime fromDate;
  late DateTime toDate;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.event == null) {
      fromDate = DateTime.now();
      toDate = DateTime.now().add(Duration(hours: 1));
    }
  }

  List<Widget> buildEditingActions() {
    return [
      ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          primary: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        onPressed: saveForm,
        icon: Icon(Icons.save),
        label: Text('Save'),
      ),
    ];
  }

  Widget buildTitle() {
    return TextFormField(
      style: TextStyle(fontSize: 24),
      decoration: InputDecoration(
          border: UnderlineInputBorder(), hintText: 'Add Event Title'),
      onFieldSubmitted: (_) => saveForm(),
      validator: (value) {
        return value != null && value.isEmpty ? 'Title Cannot be Empty' : null;
      },
      controller: titleController,
    );
  }

  String getToDate(DateTime dateTime) {
    final date = DateFormat.yMMMEd().format(dateTime);
    return '$date';
  }

  String getToTime(DateTime dateTime) {
    final time = DateFormat.Hm().format(dateTime);
    return '$time';
  }

  Widget buildDropDownField({
    required String text,
    required VoidCallback onClicked,
  }) {
    return ListTile(
      title: Text(text),
      trailing: Icon(Icons.arrow_drop_down),
      onTap: onClicked,
    );
  }

  Widget buildHeader({required String header, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(header,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            )),
        child,
      ],
    );
  }

  Future<DateTime?> pickDateTime(
    DateTime initialDate, {
    required bool pickDate,
    DateTime? firstDate,
  }) async {
    if (pickDate) {
      final date = await showDatePicker(
          context: context,
          initialDate: initialDate,
          firstDate: firstDate ?? DateTime(2015, 8),
          lastDate: DateTime(2101));
      if (date == null) {
        return null;
      }
      final time =
          Duration(hours: initialDate.hour, minutes: initialDate.minute);
      return date.add(time);
    } else {
      final timeOfDay = await showTimePicker(
          context: context, initialTime: TimeOfDay.fromDateTime(initialDate));
      if (timeOfDay == null) {
        return null;
      }
      final Date =
          DateTime(initialDate.year, initialDate.month, initialDate.day);
      final time = Duration(hours: timeOfDay.hour, minutes: timeOfDay.minute);
      return Date.add(time);
    }
  }

  Future pickFromDateTime({required bool pickDate}) async {
    final date = await pickDateTime(fromDate, pickDate: pickDate);
    if (date == null) {
      return;
    }
    if (date.isAfter(toDate)) {
      toDate =
          DateTime(date.year, date.month, date.day, toDate.hour, toDate.minute);
    }
    setState(() {
      fromDate = date;
    });
  }

  Widget buildFrom() {
    return buildHeader(
      header: 'FROM',
      child: Row(children: [
        Expanded(
            flex: 2,
            child: buildDropDownField(
              text: getToDate(fromDate),
              onClicked: () {
                pickFromDateTime(pickDate: true);
              },
            )),
        Expanded(
            child: buildDropDownField(
          text: getToTime(fromDate),
          onClicked: () {
            pickFromDateTime(pickDate: false);
          },
        )),
      ]),
    );
  }

  Future pickToDateTime({required bool pickDate}) async {
    final date = await pickDateTime(toDate,
        pickDate: pickDate, firstDate: pickDate ? fromDate : null);
    if (date == null) {
      return;
    }
    setState(() {
      toDate = date;
    });
  }

  Widget buildTo() {
    return buildHeader(
      header: 'TO',
      child: Row(children: [
        Expanded(
            flex: 2,
            child: buildDropDownField(
              text: getToDate(toDate),
              onClicked: () {
                pickToDateTime(pickDate: true);
              },
            )),
        Expanded(
            child: buildDropDownField(
          text: getToTime(toDate),
          onClicked: () {
            pickToDateTime(pickDate: false);
          },
        )),
      ]),
    );
  }

  Widget buildDateTimePickers() {
    return Column(children: [buildFrom(), buildTo()]);
  }

  Future saveForm() async {
    final isValid = _formKey.currentState!.validate();
    if (isValid) {
      FirebaseFirestore.instance
          .collection('calendarEvents')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('events')
          .add({
        'title': titleController.text,
        'description': 'Description',
        'from': fromDate,
        'to': toDate
      });
      final event = Event(
          title: titleController.text,
          description: 'Description',
          from: fromDate,
          to: toDate,
          isAllDay: false);
      final provider = Provider.of<EventProvider>(context, listen: false);
      provider.addEvent(event);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: CloseButton(),
        actions: buildEditingActions(),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(12),
        child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                buildTitle(),
                SizedBox(height: 12),
                buildDateTimePickers(),
              ],
            )),
      ),
    );
  }
}
