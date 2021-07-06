import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ms_teams_clone_engage/calendar/calendar_class.dart';
import 'package:ms_teams_clone_engage/unwanted/change_theme_button.dart';
import 'package:ms_teams_clone_engage/chat/chat_screen.dart';
import 'package:ms_teams_clone_engage/profile/dashboard.dart';
import 'package:ms_teams_clone_engage/utilities/internet_connection_status.dart';
import 'package:ms_teams_clone_engage/authentication/login_page.dart';
import 'package:ms_teams_clone_engage/main.dart';
import 'package:permission_handler/permission_handler.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

final _usersRef = FirebaseFirestore.instance.collection('users');

class _ProfilePageState extends State<ProfilePage> {
  final _auth = FirebaseAuth.instance;
  late String photoUrl = "";
  late String userDisplayName = "Name";
  bool isFileNull = true;
  bool isEdit = true;
  bool readOnly = true;
  bool _displayNameValid = true;
  late String editDisplayName = "Name";
  final _editDisplayNameFormKey = GlobalKey<FormState>();
  TextEditingController displayNameController = TextEditingController();
  final _roomFormKey = GlobalKey<FormState>();
  TextEditingController roomDetailsController = TextEditingController();
  late String roomDetails = "Enter Room";

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    //print(loggedInUser.uid);
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
          // print(element['displayName']);
          displayNameController.text = element['displayName'];
          editDisplayName = element['displayName'];
          userDisplayName = element['displayName'];
          photoUrl = element['photoUrl'];
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
          style: TextStyle(color: Theme.of(context).accentColor),
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

  editProfile() {
    InternetConnectionStatusClass.getInternetConnectionStatus();
    setState(() {
      isEdit = false;
      readOnly = false;
      _displayNameValid = false;
    });
  }

  updateProfile() async {
    InternetConnectionStatusClass.getInternetConnectionStatus();
    setState(() {
      if (!_editDisplayNameFormKey.currentState!.validate()) {
        setState(() {
          _displayNameValid = false;
        });
      } else {
        setState(() {
          _displayNameValid = true;
        });
      }
      isEdit = true;
      readOnly = true;
    });

    if (_displayNameValid) {
      if (!isFileNull) {
        await _usersRef.doc(currentUser.uid).update({
          'displayName': editDisplayName,
          "photoUrl": photoUrl,
        }).then((value) {
          return Fluttertoast.showToast(
              msg: "Profile Updated",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.black87,
              textColor: Colors.white,
              fontSize: 16.0);
        }).catchError((error) {
          return Fluttertoast.showToast(
              msg: "Could Not Update Details, Maybe User has been Deleted",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.black87,
              textColor: Colors.white,
              fontSize: 16.0);
        });
      } else {
        await _usersRef.doc(currentUser.uid).update({
          'displayName': editDisplayName,
        }).then((value) {
          return Fluttertoast.showToast(
              msg: "Profile Updated",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.black87,
              textColor: Colors.white,
              fontSize: 16.0);
        }).catchError((error) {
          return Fluttertoast.showToast(
              msg: "Could Not Update Details, Maybe User has been Deleted",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.black87,
              textColor: Colors.white,
              fontSize: 16.0);
        });
      }
    }
  }

  handleChooseFromGallery() async {
    InternetConnectionStatusClass.getInternetConnectionStatus();
    try {
      final _picker = ImagePicker();
      PickedFile image;
      final _storage = FirebaseStorage.instance;
      var permission = await Permission.photos.request();
      var permissionStatus = permission;
      if (permissionStatus.isGranted == true) {
        image = (await _picker.getImage(source: ImageSource.gallery))!;
        var file = File(image.path);
        if (image != null) {
          setState(() {
            isFileNull = false;
          });
          var storageSnapshot = await _storage
              .ref()
              .child('profileImages/${currentUser.uid}/photo')
              .putFile(file);
          var downloadUrl = await storageSnapshot.ref.getDownloadURL();
          setState(() {
            photoUrl = downloadUrl;
          });
        } else {
          print('No Path Received');
        }
      } else {
        print('Grant Permissions and start again');
      }
    } catch (e) {
      Fluttertoast.showToast(
          msg: e.toString(),
          backgroundColor: Colors.black,
          textColor: Colors.white,
          gravity: ToastGravity.BOTTOM,
          toastLength: Toast.LENGTH_SHORT);
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        actions: <Widget>[
          IconButton(
            onPressed: () {
              InternetConnectionStatusClass.getInternetConnectionStatus();
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => DashboardClass()));
            },
            icon: Icon(Icons.meeting_room_outlined),
          ),
          IconButton(
            onPressed: () {
              InternetConnectionStatusClass.getInternetConnectionStatus();
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => CalendarClass()));
            },
            icon: Icon(Icons.calendar_today),
          ),
          IconButton(
            onPressed: () {
              InternetConnectionStatusClass.getInternetConnectionStatus();
              _auth.signOut();
              Navigator.pop(context);
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => MyApp()));
            },
            icon: Icon(Icons.logout),
          ),
        ],
        title: Text('Profile'),
      ),
      body: ListView(
        children: <Widget>[
          Container(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Stack(
                    children: <Widget>[
                      CircleAvatar(
                        backgroundColor: getBackgroundColor(),
                        radius: 50.0,
                        child: getBackgroundText(),
                        backgroundImage: getPhotoUrl(),
                      ),
                      Positioned(
                        top: 65.0,
                        left: 30.0 + 5.0,
                        right: -(35.0 + 10.0),
                        bottom: -20.0,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.photo_camera,
                              color: Theme.of(context).primaryColor,
                              size: 25.0,
                            ),
                            onPressed: isEdit ? null : handleChooseFromGallery,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                        padding: EdgeInsets.only(top: 12.0),
                        child: Text(
                          "Display Name",
                          style: TextStyle(color: Colors.grey),
                        )),
                  ),
                  Form(
                    key: _editDisplayNameFormKey,
                    child: TextFormField(
                      enabled: isEdit ? false : true,
                      autofocus: isEdit ? false : true,
                      readOnly: readOnly,
                      controller: displayNameController,
                      onChanged: (value) {
                        setState(() {
                          editDisplayName = value;
                        });
                      },
                      validator: (value) {
                        bool editNameValid = false;
                        if (value != null) {
                          editNameValid = value.length > 3 ? true : false;
                        }
                        if (!editNameValid) {
                          return 'Display Name Should be atleast 3 characters long';
                        } else {
                          return null;
                        }
                      },
                      decoration: InputDecoration(
                        hintText: "Update Display Name",
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 20.0),
                    child: ButtonTheme(
                      minWidth: 200.0,
                      height: 40.0,
                      child: RaisedButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            8.0,
                          ),
                        ),
                        color: Theme.of(context).primaryColor,
                        elevation: 5.0,
                        onPressed: isEdit ? editProfile : updateProfile,
                        padding: EdgeInsets.all(10.0),
                        child: Text(
                          isEdit ? 'Edit Profile' : 'UpdateProfile',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 200,
                  ),
                  Form(
                    key: _roomFormKey,
                    child: TextFormField(
                      controller: roomDetailsController,
                      onChanged: (newValue) => roomDetails = newValue,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.group,
                            color: Theme.of(context).primaryColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            8.0,
                          ),
                          borderSide: BorderSide(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        labelText: 'Room Details',
                        labelStyle: TextStyle(
                          fontSize: 15.0,
                          color: Theme.of(context).primaryColor,
                        ),
                        hintText: 'Enter Room Id',
                      ),
                      validator: (value) {
                        bool roomValid = false;
                        if (value != null) {
                          roomValid = value.length > 3 ? true : false;
                        }
                        if (!roomValid) {
                          return 'Room Name should be greater than 3';
                        } else {
                          return null;
                        }
                      },
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 20.0),
                    child: ButtonTheme(
                      minWidth: 200.0,
                      height: 40.0,
                      child: RaisedButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            8.0,
                          ),
                        ),
                        color: Theme.of(context).primaryColor,
                        elevation: 5.0,
                        onPressed: () {
                          InternetConnectionStatusClass
                              .getInternetConnectionStatus();
                          if (_roomFormKey.currentState!.validate()) {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatScreen(
                                  roomDetails: roomDetails,
                                ),
                              ),
                            );
                          }
                        },
                        padding: EdgeInsets.all(10.0),
                        child: Text(
                          "Enter Room",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
