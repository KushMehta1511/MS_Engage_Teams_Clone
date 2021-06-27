import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ms_teams_clone_engage/chat_screen.dart';
import 'package:ms_teams_clone_engage/logged_user.dart';
import 'package:ms_teams_clone_engage/login_page.dart';
import 'package:ms_teams_clone_engage/profile_page.dart';
import 'package:ms_teams_clone_engage/welcome_page.dart';

final _roomFirestore = FirebaseFirestore.instance.collection('room');

class CreateAccount extends StatefulWidget {
  const CreateAccount({Key? key}) : super(key: key);

  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  CollectionReference usersRef = FirebaseFirestore.instance.collection('users');
  final DateTime timestamp = DateTime.now();
  final _auth = FirebaseAuth.instance;
  final _emailFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();
  final _displayNameFormKey = GlobalKey<FormState>();
  final _roomFormKey = GlobalKey<FormState>();
  late String email;
  late String password;
  late String displayName;
  TextEditingController detailsTextEditingController =
      new TextEditingController();
  late String roomDetails = "EmptyRoom";

  String? validateEmailAddress(String? username) {
    bool emailValid = RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(username!);
    if (!emailValid) {
      return 'Enter a valid Email Address';
    } else {
      return null;
    }
  }

  String? validatePassword(String? password) {
    if (password!.trim().length < 6 || password.isEmpty) {
      return 'Password must be greater than 6 characters';
    } else {
      return null;
    }
  }

  String? validateDisplayName(String? displayName) {
    if (displayName!.trim().length < 3) {
      return 'Name is too short';
    } else if (displayName.trim().length > 12) {
      return 'Name is too long';
    } else {
      return null;
    }
  }

  Future<void> chatOptionDialog() {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Room Details'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Form(
                  key: _roomFormKey,
                  child: TextFormField(
                    controller: detailsTextEditingController,
                    autofocus: true,
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
                    onChanged: (data) {
                      setState(() {
                        roomDetails = data;
                      });
                    },
                  ),
                ),
                ElevatedButton(
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
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white10,
          title: Center(
            child: Hero(
              tag: 'logo',
              child: Padding(
                padding: EdgeInsets.only(
                    top: 10.0, bottom: 2.0, left: 20.0, right: 20.0),
                child: Image(
                  image: AssetImage(
                    'assets/images/logo.png',
                  ),
                  fit: BoxFit.cover,
                  height: 50.0,
                ),
              ),
            ),
          ),
        ),
        body: Container(
          decoration: BoxDecoration(),
          child: Center(
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: GestureDetector(
                    child: CircleAvatar(
                      radius: 50.0,
                      backgroundColor: Colors.white30,
                      child: Icon(
                        Icons.account_circle,
                        color: Color(0xFF534DD6),
                        size: 100.0,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      top: 10.0, bottom: 10.0, right: 20.0, left: 20.0),
                  child: Form(
                    key: _emailFormKey,
//                    autovalidate: true,
                    child: TextFormField(
                      onSaved: (newValue) => email = newValue!,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.email, color: Color(0xFF534DD6)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            8.0,
                          ),
                          borderSide: BorderSide(
                            color: Color(0xFF534DD6),
                          ),
                        ),
                        labelText: 'Email',
                        labelStyle: TextStyle(
                          fontSize: 15.0,
                          color: Color(0xFF534DD6),
                        ),
                        hintText: 'Enter Email address',
                      ),
                      validator: validateEmailAddress,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      top: 10.0, bottom: 10.0, right: 20.0, left: 20.0),
                  child: Form(
                    key: _passwordFormKey,
                    child: TextFormField(
                      onSaved: (newValue) => password = newValue!,
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.vpn_key,
                          color: Color(0xFF534DD6),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            8.0,
                          ),
                          borderSide: BorderSide(
                            color: Color(0xFF534DD6),
                          ),
                        ),
                        labelText: 'Password',
                        labelStyle: TextStyle(
                          fontSize: 15.0,
                          color: Color(0xFF534DD6),
                        ),
                        hintText: 'Enter Password',
                      ),
                      validator: validatePassword,
                      obscureText: true,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      top: 10.0, bottom: 10.0, right: 20.0, left: 20.0),
                  child: Form(
                    key: _displayNameFormKey,
//                    autovalidate: true,
                    child: TextFormField(
                      onSaved: (newValue) => displayName = newValue!,
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.account_box,
                          color: Color(
                            0xFF534DD6,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            8.0,
                          ),
                          borderSide: BorderSide(
                            color: Color(0xFF534DD6),
                          ),
                        ),
                        labelText: 'Name',
                        labelStyle: TextStyle(
                          fontSize: 15.0,
                          color: Color(0xFF534DD6),
                        ),
                        hintText: 'Enter Your Name to be displayed to Others',
                      ),
                      validator: validateDisplayName,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      top: 10.0, bottom: 10.0, right: 20.0, left: 90.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      ButtonTheme(
                        minWidth: 200.0,
                        height: 40.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        child: ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Color(0xFF534DD6))),
                          onPressed: () async {
                            if (_emailFormKey.currentState!.validate() &&
                                _passwordFormKey.currentState!.validate() &&
                                _displayNameFormKey.currentState!.validate()) {
                              _emailFormKey.currentState!.save();
                              _passwordFormKey.currentState!.save();
                              _displayNameFormKey.currentState!.save();
                              print("login user");
                              print("Email$email");
                              print("Displayname$displayName");
                              print("Password$password");
                              try {
                                final newUser =
                                    await _auth.createUserWithEmailAndPassword(
                                        email: email.trim(),
                                        password: password);
                                currentUser = (await _auth.currentUser)!;
                                DocumentSnapshot doc;
                                if (newUser != null) {
                                  await usersRef.doc(currentUser.uid).set({
                                    "id": currentUser.uid,
                                    "photoUrl": '',
                                    "email": email,
                                    "displayName": displayName,
                                    "timestamp": timestamp,
                                  });
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProfilePage(),
                                    ),
                                  );
                                }
                              } catch (e) {
                                Fluttertoast.showToast(
                                    msg:
                                        "This email address is already in use by another account",
                                    toastLength: Toast.LENGTH_LONG,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.black87,
                                    textColor: Colors.white,
                                    fontSize: 16.0);
                              }
                            }
                          },
                          child: Text(
                            'Sign Up',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.0,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: SizedBox(
                          width: 10.0,
                          child: Text(
                            '/',
                            style: TextStyle(
                              fontSize: 15.0,
                              color: Color(0xFF534DD6),
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginPage())),
                        child: Text(
                          'Log In',
                          style: TextStyle(
                              fontSize: 15.0,
                              color: Color(0xFF534DD6),
                              decoration: TextDecoration.underline),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
