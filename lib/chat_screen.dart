import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ms_teams_clone_engage/constants.dart';
import 'package:ms_teams_clone_engage/file_upload.dart';
import 'package:ms_teams_clone_engage/login_page.dart';
import 'package:ms_teams_clone_engage/profile_page.dart';
import 'package:ms_teams_clone_engage/video_call.dart';
//import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:url_launcher/url_launcher.dart';

final _firestore = FirebaseFirestore.instance.collection('room');
final _usersRef = FirebaseFirestore.instance.collection('users');
late User loggedInUser;

enum optionsMenu { email, call, message, signout }

class ChatScreen extends StatefulWidget {
  static const String id = 'chat_screen_demo';
  final String roomDetails;

  const ChatScreen({Key? key, required this.roomDetails}) : super(key: key);
  @override
  _ChatScreenState createState() => new _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final DateTime timestamp = DateTime.now();
  final messageTextController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final _emailDetailFormKey = GlobalKey<FormState>();
  final _callDetailFormKey = GlobalKey<FormState>();
  final _messageDetailFormKey = GlobalKey<FormState>();
  late String userDisplayName = "Name";
  late String photoUrl = "";
  late String userEmailAddress = "123@gmail.com";
  late TextEditingController emailTextEditingController =
      TextEditingController();
  late TextEditingController mobileTextEditingController =
      TextEditingController();

  late TextEditingController smsMobileTextEditingController =
      TextEditingController();
  bool isFileNull = true;
  late String emailDetails = "@mail.com";
  late var mobileNumberDetails = "1234567890";
  late var smsMobileNumberDetails = "1234567890";

  late String messageText;

  @override
  void initState() {
    super.initState();

    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
        getDisplayName();
      }
    } catch (e) {
      print(e);
    }
  }

  void getDisplayName() async {
    DocumentSnapshot doc = await _usersRef.doc(loggedInUser.uid).get();
    if (!doc.exists) {
      CircularProgressIndicator();
    }
    _usersRef.where('email', isEqualTo: loggedInUser.email).get().then((value) {
      value.docs.forEach((element) {
        setState(() {
          print(element['displayName']);
          userDisplayName = element['displayName'];
          photoUrl = element['photoUrl'];
          userEmailAddress = loggedInUser.email!;
        });
      });
    });
  }

  getBackgroundText() {
    if (isFileNull) {
      if (photoUrl == "") {
        return Text(
          splitDisplayName(),
          style: TextStyle(color: Theme.of(context).accentColor),
        );
      } else {
        return null;
      }
    } else {
      if (photoUrl == "") {
        return Text(
          splitDisplayName(),
          style: TextStyle(color: Theme.of(context).primaryColor),
        );
      } else {
        return null;
      }
    }
  }

  String splitDisplayName() {
    List<String> userNameSplit = userDisplayName.split(' ');
    if (userNameSplit.length > 1) {
      return userNameSplit[0][0].toUpperCase() +
          " " +
          userNameSplit[userNameSplit.length - 1][0].toUpperCase();
    } else {
      return userNameSplit[0][0].toUpperCase();
    }
  }

  getPhotoUrl() {
    if (isFileNull) {
      if (photoUrl == "") {
        return null;
      } else {
        return NetworkImage(photoUrl);
      }
    } else {
      if (photoUrl == "") {
        return null;
      } else {
        return NetworkImage(photoUrl);
      }
    }
  }

  signout() {
    _auth.signOut();
    Navigator.pop(context);
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => LoginPage()));
  }

  String? validateEmailAddress(String? username) {
    bool emailValid = false;
    if (username != null) {
      emailValid = RegExp(
              r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
          .hasMatch(username);
    }
    if (!emailValid) {
      return 'Enter a valid Email Address';
    } else {
      return null;
    }
  }

  sendEmail() {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Email Address'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Form(
                  key: _emailDetailFormKey,
                  child: TextFormField(
                    controller: emailTextEditingController,
                    autofocus: true,
                    validator: (value) {
                      bool emailValid = false;
                      if (value != null) {
                        emailValid = RegExp(
                                r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                            .hasMatch(value);
                      }
                      if (!emailValid) {
                        return 'Enter a valid Email Address';
                      } else {
                        return null;
                      }
                    },
                    onChanged: (String? data) {
                      setState(() {
                        emailDetails = data!;
                      });
                    },
                  ),
                ),
                ElevatedButton(
                    onPressed: () async {
                      if (_emailDetailFormKey.currentState!.validate()) {
                        final url = 'mailto:$emailDetails';
                        if (await canLaunch(url)) {
                          await launch(url);
                        } else {
                          throw 'Could Not Launch $url';
                        }
                      }
                    },
                    child: Text("Open Email Draft")),
              ],
            ),
          ),
        );
      },
    );
  }

  makeCall() {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Mobile Number'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Form(
                  key: _callDetailFormKey,
                  child: TextFormField(
                    controller: mobileTextEditingController,
                    autofocus: true,
                    validator: (value) {
                      bool mobileValid = false;
                      if (value != null) {
                        mobileValid = value.length == 10 ? true : false;
                      }
                      if (!mobileValid) {
                        return 'Enter a valid Mobile Number';
                      } else {
                        return null;
                      }
                    },
                    onChanged: (data) {
                      setState(() {
                        mobileNumberDetails = data;
                      });
                    },
                  ),
                ),
                ElevatedButton(
                    onPressed: () async {
                      if (_callDetailFormKey.currentState!.validate()) {
                        final url = 'tel:$mobileNumberDetails';
                        if (await canLaunch(url)) {
                          await launch(url);
                        } else {
                          throw 'Could Not Call $url';
                        }
                      }
                    },
                    child: Text("Make a call")),
              ],
            ),
          ),
        );
      },
    );
  }

  sendMessage() {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Mobile Number'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Form(
                  key: _messageDetailFormKey,
                  child: TextFormField(
                    controller: smsMobileTextEditingController,
                    autofocus: true,
                    validator: (value) {
                      bool smsValid = false;
                      if (value != null) {
                        smsValid = value.length == 10 ? true : false;
                      }
                      if (!smsValid) {
                        return 'Enter a valid Mobile Number';
                      } else {
                        return null;
                      }
                    },
                    onChanged: (data) {
                      setState(() {
                        smsMobileNumberDetails = data;
                      });
                    },
                  ),
                ),
                ElevatedButton(
                    onPressed: () async {
                      if (_messageDetailFormKey.currentState!.validate()) {
                        final url = 'sms:$smsMobileNumberDetails';
                        if (await canLaunch(url)) {
                          await launch(url);
                        } else {
                          throw 'Could Not Call $url';
                        }
                      }
                    },
                    child: Text("Send an SMS")),
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
        leading: CloseButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => ProfilePage()));
          },
        ),
        automaticallyImplyLeading: true,
        title: Row(
          children: [
            Text(widget.roomDetails),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [],
            ),
          ],
        ),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FileUploadPage(
                    roomDetails: widget.roomDetails,
                  ),
                ),
              );
            },
            icon: Icon(Icons.attach_file),
          ),
          IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VideoCallScreen(
                      roomDetails: widget.roomDetails,
                    ),
                  ),
                );
              },
              icon: Icon(Icons.video_call)),
          PopupMenuButton<optionsMenu>(
            icon: Icon(Icons.more_vert),
            itemBuilder: (BuildContext context) =>
                <PopupMenuEntry<optionsMenu>>[
              PopupMenuItem(
                  value: optionsMenu.email,
                  child: ListTile(
                    leading:
                        IconButton(icon: Icon(Icons.email), onPressed: () {}),
                    title: Text("Send Email"),
                  )),
              PopupMenuItem(
                  value: optionsMenu.call,
                  child: ListTile(
                    leading: IconButton(
                      icon: Icon(Icons.call),
                      onPressed: () {},
                    ),
                    title: Text("Make a Call"),
                  )),
              PopupMenuItem(
                  value: optionsMenu.message,
                  child: ListTile(
                    leading: IconButton(
                      icon: Icon(Icons.message),
                      onPressed: () {},
                    ),
                    title: Text("Send a Message"),
                  )),
              PopupMenuItem(
                value: optionsMenu.signout,
                child: ListTile(
                  leading:
                      IconButton(icon: Icon(Icons.logout), onPressed: () {}),
                  title: Text("SignOut"),
                ),
              )
            ],
            onSelected: (optionsMenu result) {
              if (result == optionsMenu.email) {
                sendEmail();
              } else if (result == optionsMenu.call) {
                makeCall();
              } else if (result == optionsMenu.message) {
                sendMessage();
              } else {
                signout();
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessagesStream(
              roomDetails: widget.roomDetails,
              userDisplayName: userDisplayName,
              userEmailAddress: userEmailAddress,
            ),
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                      color: Theme.of(context).primaryColor, width: 2.0),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        messageText = value;
                      },
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 20.0),
                          hintText: 'Type your message here...',
                          border: InputBorder.none,
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CircleAvatar(
                              backgroundColor: Colors.grey,
                              child: getBackgroundText(),
                              backgroundImage: getPhotoUrl(),
                            ),
                          )),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      messageTextController.clear();
                      if (messageText != "") {
                        _firestore
                            .doc(widget.roomDetails)
                            .collection('messages')
                            .add({
                          'text': messageText,
                          'sender': userDisplayName,
                          'senderEmail': userEmailAddress,
                          'timestamp': timestamp,
                        });
                      }

                      messageText = "";
                    },
                    child: Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessagesStream extends StatelessWidget {
  final String roomDetails;
  final String userDisplayName;
  final String userEmailAddress;

  const MessagesStream(
      {Key? key,
      required this.roomDetails,
      required this.userDisplayName,
      required this.userEmailAddress})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .doc(roomDetails)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Theme.of(context).primaryColor,
            ),
          );
        }
        final messages = snapshot.data!.docs;
        List<MessageBubble> messageBubbles = [];
        for (var message in messages) {
          final messageText = message.get('text');
          final messageSender = message.get('sender');
          final messageSenderEmailAddress = message.get('senderEmail');

          final currentUser = userDisplayName;
          final currentUserEmailAddress = userEmailAddress;

          final messageBubble = MessageBubble(
            sender: messageSender,
            text: messageText,
            isMe: currentUserEmailAddress == messageSenderEmailAddress,
          );

          messageBubbles.add(messageBubble);
        }
        return Expanded(
          child: ListView(
            reverse: true,
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
            children: messageBubbles,
          ),
        );
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  MessageBubble({
    required this.sender,
    required this.text,
    required this.isMe,
  });

  final String sender;
  final String text;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            sender,
            style: TextStyle(
              fontSize: 12.0,
              // color: Colors.black54,
            ),
          ),
          Material(
            borderRadius: isMe
                ? BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0))
                : BorderRadius.only(
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0),
                    topRight: Radius.circular(30.0),
                  ),
            elevation: 5.0,
            color: isMe ? Theme.of(context).primaryColor : Colors.white,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Text(
                text,
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black54,
                  fontSize: 15.0,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
