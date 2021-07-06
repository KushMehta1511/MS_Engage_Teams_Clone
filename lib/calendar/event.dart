import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Event {
  final String title;
  final String description;
  final DateTime from;
  final DateTime to;
  final Color backgroundColor;
  final bool isAllDay;

  Event(
      {required this.title,
      required this.description,
      required this.from,
      required this.to,
      this.backgroundColor = Colors.teal,
      this.isAllDay = false});

  factory Event.fromDocument(DocumentSnapshot doc) {
    return Event(
        description: doc['description'],
        from: doc['from'],
        title: doc['title'],
        to: doc['to']);
  }
}
