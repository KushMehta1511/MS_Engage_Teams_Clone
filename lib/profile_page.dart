import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ms_teams_clone_engage/calendar_class.dart';
import 'package:ms_teams_clone_engage/chat_screen.dart';
import 'package:ms_teams_clone_engage/login_page.dart';
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

  getPhotoUrl() {
    if (isFileNull) {
      if (photoUrl == "") {
        return AssetImage('assets/images/profile.png');
      } else {
        return NetworkImage(photoUrl);
      }
    }
  }

  editProfile() {
    setState(() {
      isEdit = false;
      readOnly = false;
      _displayNameValid = false;
    });
  }

  updateProfile() async {
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
        await _usersRef
            .doc(currentUser.uid)
            .update({
              'displayName': editDisplayName,
              "photoUrl": photoUrl,
            })
            .then((value) => print("User Updated"))
            .catchError((error) => print("Failed to update user: $error"));
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
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.lightBlueAccent,
          automaticallyImplyLeading: true,
          actions: <Widget>[
            IconButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => CalendarClass()));
              },
              icon: Icon(Icons.calendar_today),
            ),
            IconButton(
              onPressed: () {
                _auth.signOut();
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => LoginPage()));
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
                          backgroundColor: Colors.grey,
                          radius: 50.0,
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
                                color: Color(0xFFFAFAFA)),
                            child: IconButton(
                              icon: Icon(
                                Icons.photo_camera,
                                color: Colors.black,
                                size: 25.0,
                              ),
                              onPressed:
                                  isEdit ? null : handleChooseFromGallery,
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
                          color: Theme.of(context).accentColor.withOpacity(0.7),
                          elevation: 5.0,
                          onPressed: isEdit ? editProfile : updateProfile,
                          padding: EdgeInsets.all(10.0),
                          child: Text(
                            isEdit ? 'Edit Profile' : 'UpdateProfile',
                            style: TextStyle(
                              color: Color(0xFF003D66),
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
                          prefixIcon:
                              Icon(Icons.group, color: Color(0xFF003D66)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              8.0,
                            ),
                            borderSide: BorderSide(
                              color: Color(0xFF003D66),
                            ),
                          ),
                          labelText: 'Room Details',
                          labelStyle: TextStyle(
                            fontSize: 15.0,
                            color: Color(0xFF003D66),
                          ),
                          hintText: 'Enter Room Id',
                        ),
                        //                      autovalidate: true,
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
                        style: TextStyle(
                          color: Color(0xFF003D66),
                        ),
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
                          color: Theme.of(context).accentColor.withOpacity(0.7),
                          elevation: 5.0,
                          onPressed: () {
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
                              color: Color(0xFF003D66),
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
      ),
    );
  }
}
