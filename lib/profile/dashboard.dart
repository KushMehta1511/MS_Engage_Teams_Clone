import 'dart:math';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ms_teams_clone_engage/chat_screen.dart';
import 'package:ms_teams_clone_engage/internet_connection_status.dart';
import 'package:ms_teams_clone_engage/login_page.dart';

class DashboardClass extends StatefulWidget {
  const DashboardClass({Key? key}) : super(key: key);

  @override
  _DashboardClassState createState() => _DashboardClassState();
}

class _DashboardClassState extends State<DashboardClass> {
  final _usersRef = FirebaseFirestore.instance.collection('rooms');
  final _dashboardRef = FirebaseFirestore.instance
      .collection('dashboard')
      .doc(currentUser.uid)
      .collection('rooms');
  final _auth = FirebaseAuth.instance;
  final roomDetailsTextEditingController = TextEditingController();
  final _roomDetailsKey = GlobalKey<FormState>();
  var roomDetails = "room";

  Color getBackgroundColor() {
    List<Color> colors = [];
    colors.add(Colors.blue);
    colors.add(Colors.teal);
    colors.add(Colors.red);
    colors.add(Colors.orange);
    colors.add(Colors.green);
    colors.add(Colors.pink);
    Random randColInd = new Random();
    int nextInd = randColInd.nextInt(6);
    return colors[nextInd];
  }

  String splitDisplayName(String roomName) {
    List<String> userNameSplit = roomName.split(' ');
    if (userNameSplit.length > 1) {
      return userNameSplit[0][0].toUpperCase() +
          " " +
          userNameSplit[userNameSplit.length - 1][0].toUpperCase();
    } else {
      return userNameSplit[0][0].toUpperCase();
    }
  }

  buildRooms() {
    return StreamBuilder(
        stream: _dashboardRef.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            print('no data');
            return Center(
              child: SizedBox(
                height: 75.0,
                width: 75.0,
                child: CircularProgressIndicator(),
              ),
            );
          }
          return ListView(
            children: snapshot.data!.docs.map((document) {
              String roomName = document['roomName'];
              return Column(
                children: [
                  Container(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: getBackgroundColor(),
                        child: Text(
                          splitDisplayName(roomName),
                          style:
                              TextStyle(color: Theme.of(context).primaryColor),
                        ),
                      ),
                      title: Text(
                        roomName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () {
                        InternetConnectionStatusClass
                            .getInternetConnectionStatus();
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ChatScreen(roomDetails: roomName),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    height: 10.0,
                    child: Divider(
                      indent: 20.0,
                      endIndent: 20.0,
                      thickness: 2.0,
                    ),
                  )
                ],
              );
            }).toList(),
          );
        });
  }

  onPressed() {
    InternetConnectionStatusClass.getInternetConnectionStatus();
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Room Details'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Form(
                  key: _roomDetailsKey,
                  child: TextFormField(
                    controller: roomDetailsTextEditingController,
                    autofocus: true,
                    validator: (value) {
                      bool roomValid = false;
                      if (value != null) {
                        roomValid = value.length > 0 ? true : false;
                      }
                      if (!roomValid) {
                        return 'Enter a valid Room Name';
                      } else {
                        return null;
                      }
                    },
                    onChanged: (data) {
                      setState(() {
                        roomDetails = data;
                      });
                    },
                  ),
                ),
                ElevatedButton(
                    onPressed: () async {
                      if (_roomDetailsKey.currentState!.validate()) {
                        // final url = 'sms:$smsMobileNumberDetails';
                        // if (await canLaunch(url)) {
                        //   await launch(url);
                        // } else {
                        //   throw 'Could Not Call $url';
                        // }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ChatScreen(roomDetails: roomDetails),
                          ),
                        );
                      }
                    },
                    child: Text("Enter Room")),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text("Meetings"),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Container(
        child: buildRooms(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: Theme.of(context).primaryColor,
        child: Icon(Icons.add),
      ),
    );
  }
}
