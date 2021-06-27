import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ms_teams_clone_engage/chat_screen.dart';
import 'package:ms_teams_clone_engage/logged_user.dart';
import 'package:ms_teams_clone_engage/profile_page.dart';
import 'package:ms_teams_clone_engage/resources/firebase_repo.dart';
import 'package:ms_teams_clone_engage/signup_page.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:ms_teams_clone_engage/welcome_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

late User currentUser;
//late LoggedUser currentUser;
final CollectionReference _roomFirestore =
    FirebaseFirestore.instance.collection('room');

class _LoginPageState extends State<LoginPage> {
  // Future<UserCredential> signInWithGoogle() async {
  //   // Trigger the authentication flow
  //   final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

  //   // Obtain the auth details from the request
  //   final GoogleSignInAuthentication googleAuth =
  //       await googleUser!.authentication;

  //   // Create a new credential
  //   final credential = GoogleAuthProvider.credential(
  //     accessToken: googleAuth.accessToken,
  //     idToken: googleAuth.idToken,
  //   );

  //   // Once signed in, return the UserCredential
  //   return await FirebaseAuth.instance.signInWithCredential(credential);
  // }

  //FireBaseRepository _fireBaseRepository = FireBaseRepository();
  CollectionReference usersRef = FirebaseFirestore.instance.collection('users');
  //late User currentUser;

  final _auth = FirebaseAuth.instance;
  final _passwordFormKey = GlobalKey<FormState>();
  final _emailFormKey = GlobalKey<FormState>();
  final _roomFormKey = GlobalKey<FormState>();
  TextEditingController detailsTextEditingController =
      new TextEditingController();
  late String roomDetails = "EnterRoom";
  late String username;
  late String password;
  final DateTime timestamp = DateTime.now();

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

  String? validatePassword(String? password) {
    if (password != null && password.trim().length < 6 ||
        password != null && password.isEmpty) {
      return 'Password must be greater than 6 characters';
    } else {
      return "";
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
                      validator: (String? value) {
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
                        roomDetails = data;
                      }),
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

                      // else {
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
                    child: Text("Enter Room")),
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

  // void googleSignIn() {
  //   _fireBaseRepository.signInWithGoogle().then((UserCredential user) {
  //     if (user != null) {
  //       createUserInFirestore();
  //     } else {
  //       print("Error in signing");
  //     }
  //   });
  // }

  // signInWithGoogle() async {
  //   final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
  //   final GoogleSignInAuthentication googleSignInAuthentication =
  //       await googleUser!.authentication;
  //   final credential = GoogleAuthProvider.credential(
  //     accessToken: googleSignInAuthentication.accessToken,
  //     idToken: googleSignInAuthentication.idToken,
  //   );
  //   DocumentSnapshot doc =
  //       await usersRef.doc(googleUser.hashCode.toString()).get();
  //   if (!doc.exists) {
  //     usersRef.add({
  //       "id": googleUser.hashCode,
  //       //"username": username,
  //       "photoUrl": googleUser.photoUrl,
  //       "email": googleUser.email,
  //       "displayName": googleUser.displayName,
  //       "timestamp": timestamp,
  //     });
  //   }
  //   currentUser = LoggedUser.fromDocument(doc);
  //   chatOptionDialog();
  // }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Container(
          decoration: BoxDecoration(
              // gradient: LinearGradient(
              //   begin: Alignment.topRight,
              //   end: Alignment.bottomLeft,
              //   colors: [
              //     Theme.of(context).primaryColor,
              //     Theme.of(context).accentColor,
              //   ],
              // ),

              ),
          child: Center(
            child: ListView(
              shrinkWrap: true,
              // mainAxisAlignment: MainAxisAlignment.center,
              // crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Hero(
                  tag: 'logo',
                  child: Padding(
                    padding: EdgeInsets.only(
                        top: 10.0, bottom: 2.0, left: 20.0, right: 20.0),
                    child: Image(
                      image: AssetImage(
                        'assets/images/logo.png',
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
                      onSaved: (String? value) => username = value!,
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
//                      autovalidate: true,
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
                      // style: TextStyle(
                      //   color: Color(0xFF003D66),
                      // ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      top: 10.0, bottom: 10.0, right: 20.0, left: 20.0),
                  child: Form(
                    key: _passwordFormKey,
//                    autovalidate: true,
                    child: TextFormField(
                      onSaved: (String? value) {
                        password = value!;
                      },
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
//                      autovalidate: true,
                      validator: (value) {
                        if (value != null && value.trim().length < 6 ||
                            value != null && value.isEmpty) {
                          return 'Password must be greater than 6 characters';
                        } else {
                          return null;
                        }
                      },
                      // style: TextStyle(
                      //   color: Color(0xFF003D66),
                      // ),
                      obscureText: true,
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
                            // backgroundColor: MaterialStateProperty.all<Color>(
                            //   Theme.of(context).accentColor.withOpacity(0.7),
                            // ),
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Color(
                              0xFF534DD6,
                            ).withOpacity(0.7)),
                          ),
                          onPressed: () async {
                            if (_emailFormKey.currentState!.validate() &&
                                _passwordFormKey.currentState!.validate()) {
                              _emailFormKey.currentState!.save();
                              _passwordFormKey.currentState!.save();
                              print("login user");
                              print("Username$username");
                              print("Password$password");
                              // try {
                              //   UserCredential userCredential =
                              //       await _auth.signInWithEmailAndPassword(
                              //           email: username, password: password);
                              //   Navigator.pushReplacement(
                              //       context,
                              //       MaterialPageRoute(
                              //           builder: (context) => WelcomePage()));
                              // } on FirebaseAuthException catch (e) {
                              //   if (e.code == 'user-not-found') {
                              //     print('No user found for that email.');
                              //   } else if (e.code == 'wrong-password') {
                              //     print(
                              //         'Wrong password provided for that user.');
                              //   }
                              // }

                              try {
                                final user =
                                    await _auth.signInWithEmailAndPassword(
                                        email: username.trim(),
                                        password: password);
                                if (user != null) {
                                  DocumentSnapshot doc = await usersRef
                                      .doc(user.hashCode.toString())
                                      .get();
                                  if (doc.exists) {
                                    doc = await usersRef
                                        .doc(user.hashCode.toString())
                                        .get();
                                  }
                                  // else {
                                  //   Fluttertoast.showToast(
                                  //       msg:
                                  //           "There is no user record corresponding to this identifier. The user may have been deleted.",
                                  //       toastLength: Toast.LENGTH_LONG,
                                  //       gravity: ToastGravity.BOTTOM,
                                  //       timeInSecForIosWeb: 1,
                                  //       backgroundColor: Colors.black87,
                                  //       textColor: Colors.white,
                                  //       fontSize: 16.0);
                                  // }
                                  currentUser = (await _auth.currentUser)!;
                                  // chatOptionDialog();
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProfilePage(),
                                    ),
                                  );
                                }
                                // else {
                                //   Fluttertoast.showToast(
                                //       msg:
                                //           "There is no user record corresponding to this identifier. The user may have been deleted.",
                                //       toastLength: Toast.LENGTH_LONG,
                                //       gravity: ToastGravity.BOTTOM,
                                //       timeInSecForIosWeb: 1,
                                //       backgroundColor: Colors.black87,
                                //       textColor: Colors.white,
                                //       fontSize: 16.0);
                                // }
                              } catch (e) {
                                Fluttertoast.showToast(
                                    msg:
                                        "There is no user record corresponding to this identifier. The user may have been deleted.",
                                    toastLength: Toast.LENGTH_LONG,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.black87,
                                    textColor: Colors.white,
                                    fontSize: 16.0);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CreateAccount(),
                                  ),
                                );
                              }
                            }
                          },
                          child: Text(
                            'Log In',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.0,
                            ),
                          ),
                          // child: RaisedButton(
                          //   shape: RoundedRectangleBorder(
                          //     borderRadius: BorderRadius.circular(
                          //       30.0,
                          //     ),
                          //   ),
                          //   color: Theme.of(context).accentColor.withOpacity(0.7),
                          //   elevation: 5.0,
                          //   onPressed: () {
                          //     print("login user");
                          //     print("Username$username");
                          //     print("Password$password");
                          //   },
                          //   padding: EdgeInsets.all(10.0),
                          //   child: Text(
                          //     'Log In',
                          //     style: TextStyle(
                          //       color: Color(0xFF003D66),
                          //       fontSize: 20.0,
                          //     ),
                          //   ),
                          // ),
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
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CreateAccount(),
                            ),
                          );
                        },
                        child: Text(
                          'Sign Up',
                          style: TextStyle(
                              fontSize: 15.0,
                              color: Color(0xFF534DD6),
                              decoration: TextDecoration.underline),
                        ),
                      )
                    ],
                  ),
                ),
                // SizedBox(
                //   //height: 30.0,
                //   width: 100.0,
                //   child: Divider(
                //     indent: 20.0,
                //     endIndent: 20.0,
                //     color: Color(0xFF003D66),
                //   ),
                // ),
                // Padding(
                //   padding: EdgeInsets.all(10.0),
                //   child: GestureDetector(
                //     onTap: () {
                //       Navigator.pushReplacement(
                //           context,
                //           MaterialPageRoute(
                //               builder: (context) => ChatScreen(
                //                     roomDetails: roomDetails,
                //                   )));
                //     },
                //     // onTap: (signInWithGoogle),
                //     child: Container(
                //       width: 200.0,
                //       height: 50.0,
                //       decoration: BoxDecoration(
                //         image: DecorationImage(
                //           image: AssetImage(
                //             'assets/images/google_signin_button.png',
                //           ),
                //           //fit: BoxFit.cover,
                //         ),
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
