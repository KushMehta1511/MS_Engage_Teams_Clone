import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ms_teams_clone_engage/constants.dart';
import 'package:ms_teams_clone_engage/login_page.dart';
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
  late TextEditingController emailTextEditingController =
      TextEditingController();
  late TextEditingController mobileTextEditingController =
      TextEditingController();

  late TextEditingController smsMobileTextEditingController =
      TextEditingController();
  //late PickedFile file;
  //final ImagePicker _picker = ImagePicker();
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
        });
      });
    });
  }

  getPhotoUrl() {
    if (isFileNull) {
      if (photoUrl == "") {
        return AssetImage('assets/images/profile.png');
      } else {
        return NetworkImage(photoUrl);
      }
    }
  }

  // handleChooseFromGallery() async {
  //   PickedFile? file = await _picker.getImage(source: ImageSource.gallery);
  //   setState(() {
  //     this.file = file!;
  //     isFileNull = false;
  //   });
  // }

  // compressImage() async {
  //   final tempDir = await getTemporaryDirectory();
  //   final path = tempDir.path;
  //   Im.Image imageFile = Im.decodeImage(file.readAsBytesSync());
  //   final compressedImageFile = File('$path/img_${loggedInUser.uid}.jpg')
  //     ..writeAsBytesSync(
  //       Im.encodeJpg(imageFile, quality: 60),
  //     );
  //   setState(() {
  //     file = compressedImageFile as PickedFile;
  //   });
  // }

  // Future<String> uploadImage(imageFile) async {
  //   compressImage();
  //   StorageUploadTask uploadTask =
  //       storageRef.child("profile_${currentUser.id}.jpg").putFile(imageFile);
  //   StorageTaskSnapshot storageSnap = await uploadTask.onComplete;
  //   String downloadUrl = await storageSnap.ref.getDownloadURL();
  //   return downloadUrl;
  // }

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

                      // } else {
                      //   Fluttertoast.showToast(
                      //       msg: "Please create a room before entering",
                      //       toastLength: Toast.LENGTH_LONG,
                      //       gravity: ToastGravity.BOTTOM,
                      //       timeInSecForIosWeb: 1,
                      //       backgroundColor: Colors.black87,
                      //       textColor: Colors.white,
                      //       fontSize: 16.0);
                      // }
                    },
                    child: Text("Open Email Draft")),
              ],
            ),
          ),
          //actions: <Widget>[
          //   // IconButton(
          //   //   icon: Icon(Icons.insert_photo),
          //   //   onPressed: () {
          //   //     Navigator.push(
          //   //       context,
          //   //       MaterialPageRoute(
          //   //         builder: (context) => ChatScreen(
          //   //           roomDetails: roomDetails,
          //   //         ),
          //   //       ),
          //   //     );
          //   //   },
          //   // ),
          //   // IconButton(
          //   //   icon: Icon(Icons.camera),
          //   //   onPressed: () {
          //   //     Navigator.push(
          //   //       context,
          //   //       MaterialPageRoute(
          //   //         builder: (context) => ChatScreen(roomDetails: roomDetails),
          //   //       ),
          //   //     );
          //   //   },
          //   // ),

          //   ElevatedButton(
          //       onPressed: () {
          //         _roomFirestore.doc(roomDetails);
          //         Navigator.push(
          //             context,
          //             MaterialPageRoute(
          //                 builder: (context) =>
          //                     ChatScreen(roomDetails: roomDetails)));
          //       },
          //       child: Text("Create room")),
          // ],
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

                      // } else {
                      //   Fluttertoast.showToast(
                      //       msg: "Please create a room before entering",
                      //       toastLength: Toast.LENGTH_LONG,
                      //       gravity: ToastGravity.BOTTOM,
                      //       timeInSecForIosWeb: 1,
                      //       backgroundColor: Colors.black87,
                      //       textColor: Colors.white,
                      //       fontSize: 16.0);
                      // }
                    },
                    child: Text("Make a call")),
              ],
            ),
          ),
          //actions: <Widget>[
          //   // IconButton(
          //   //   icon: Icon(Icons.insert_photo),
          //   //   onPressed: () {
          //   //     Navigator.push(
          //   //       context,
          //   //       MaterialPageRoute(
          //   //         builder: (context) => ChatScreen(
          //   //           roomDetails: roomDetails,
          //   //         ),
          //   //       ),
          //   //     );
          //   //   },
          //   // ),
          //   // IconButton(
          //   //   icon: Icon(Icons.camera),
          //   //   onPressed: () {
          //   //     Navigator.push(
          //   //       context,
          //   //       MaterialPageRoute(
          //   //         builder: (context) => ChatScreen(roomDetails: roomDetails),
          //   //       ),
          //   //     );
          //   //   },
          //   // ),

          //   ElevatedButton(
          //       onPressed: () {
          //         _roomFirestore.doc(roomDetails);
          //         Navigator.push(
          //             context,
          //             MaterialPageRoute(
          //                 builder: (context) =>
          //                     ChatScreen(roomDetails: roomDetails)));
          //       },
          //       child: Text("Create room")),
          // ],
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

                      // } else {
                      //   Fluttertoast.showToast(
                      //       msg: "Please create a room before entering",
                      //       toastLength: Toast.LENGTH_LONG,
                      //       gravity: ToastGravity.BOTTOM,
                      //       timeInSecForIosWeb: 1,
                      //       backgroundColor: Colors.black87,
                      //       textColor: Colors.white,
                      //       fontSize: 16.0);
                      // }
                    },
                    child: Text("Send an SMS")),
              ],
            ),
          ),
          //actions: <Widget>[
          //   // IconButton(
          //   //   icon: Icon(Icons.insert_photo),
          //   //   onPressed: () {
          //   //     Navigator.push(
          //   //       context,
          //   //       MaterialPageRoute(
          //   //         builder: (context) => ChatScreen(
          //   //           roomDetails: roomDetails,
          //   //         ),
          //   //       ),
          //   //     );
          //   //   },
          //   // ),
          //   // IconButton(
          //   //   icon: Icon(Icons.camera),
          //   //   onPressed: () {
          //   //     Navigator.push(
          //   //       context,
          //   //       MaterialPageRoute(
          //   //         builder: (context) => ChatScreen(roomDetails: roomDetails),
          //   //       ),
          //   //     );
          //   //   },
          //   // ),

          //   ElevatedButton(
          //       onPressed: () {
          //         _roomFirestore.doc(roomDetails);
          //         Navigator.push(
          //             context,
          //             MaterialPageRoute(
          //                 builder: (context) =>
          //                     ChatScreen(roomDetails: roomDetails)));
          //       },
          //       child: Text("Create room")),
          // ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              // child: CircleAvatar(
              //   backgroundColor: Colors.grey,
              //   radius: 50.0,
              //   backgroundImage: getPhotoUrl(),
              // ),
              child: Stack(
                children: <Widget>[
                  CircleAvatar(
                    backgroundColor: Colors.grey,
                    radius: 50.0,
                    backgroundImage: getPhotoUrl(),
                  ),
                  // Positioned(
                  //   top: 65.0,
                  //   left: 30.0 + 5.0,
                  //   right: -(35.0 + 10.0),
                  //   bottom: -20.0,
                  //   child: Container(
                  //     decoration: BoxDecoration(
                  //         shape: BoxShape.circle, color: Color(0xFFFAFAFA)),
                  //     child: IconButton(
                  //       icon: Icon(
                  //         Icons.photo_camera,
                  //         color: Colors.black,
                  //         size: 25.0,
                  //       ),
                  //       onPressed: handleChooseFromGallery,
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
            ListTile(
              title: Text(userDisplayName),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Item 2'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        //leading: null,
        //automaticallyImplyLeading: false,
        actions: <Widget>[
          // ChangeThemeButtonWidget(),
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => VideoCallScreen(
                              roomDetails: widget.roomDetails,
                            )));
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
          // IconButton(
          //     icon: Icon(Icons.logout),
          //     onPressed: () {
          //       _auth.signOut();
          //       Navigator.pop(context);
          //       Navigator.push(context,
          //           MaterialPageRoute(builder: (context) => LoginPage()));
          //     }),
        ],
        title: Text(widget.roomDetails),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessagesStream(
              roomDetails: widget.roomDetails,
              userDisplayName: userDisplayName,
            ),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
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
                          'timestamp': timestamp,
                        });
                      }

                      messageText = "";
                    },
                    // child: Text(
                    //   'Send',
                    //   style: kSendButtonTextStyle,
                    // ),
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

  const MessagesStream(
      {Key? key, required this.roomDetails, required this.userDisplayName})
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
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }
        final messages = snapshot.data!.docs;
        List<MessageBubble> messageBubbles = [];
        for (var message in messages) {
          //final messageText = message.data['text'];
          final messageText = message.get('text');
          final messageSender = message.get('sender');
          //final messageSender = loggedInUser.displayName;

          final currentUser = userDisplayName;

          final messageBubble = MessageBubble(
            sender: messageSender,
            text: messageText,
            isMe: currentUser == messageSender,
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
  MessageBubble({required this.sender, required this.text, required this.isMe});

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
              color: Colors.black54,
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
            color: isMe ? Colors.lightBlueAccent : Colors.white,
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
          ),
        ],
      ),
    );
  }
}
