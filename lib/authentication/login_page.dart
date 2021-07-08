import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ms_teams_clone_engage/chat/chat_screen.dart';
import 'package:ms_teams_clone_engage/utilities/internet_connection_status.dart';
import 'package:ms_teams_clone_engage/profile/profile_page.dart';
import 'package:ms_teams_clone_engage/authentication/signup_page.dart';
import 'package:google_sign_in/google_sign_in.dart';

//Login Page stateful Widget
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
  //Google Sign In
  Future<UserCredential> signInWithGoogle() async {
    InternetConnectionStatusClass.getInternetConnectionStatus();
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth =
        await googleUser!.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    CircularProgressIndicator();
    // Once signed in, return the UserCredential
    final authCredential = await _auth.signInWithCredential(credential);
    currentUser = authCredential.user!;
    //Creating user in firebase firestore if not exists
    DocumentSnapshot doc = await usersRef.doc(currentUser.uid).get();
    if (doc.exists) {
    } else {
      usersRef.doc(currentUser.uid).set({
        'displayName': currentUser.displayName,
        'email': currentUser.email,
        'id': currentUser.uid,
        'photoUrl': googleUser.photoUrl,
        'timestamp': timestamp
      });
    }
    return authCredential;
  }

  CollectionReference usersRef = FirebaseFirestore.instance.collection('users');
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

  @override
  void initState() {
    super.initState();
    InternetConnectionStatusClass.getInternetConnectionStatus();

    //Auto Login
    _auth.authStateChanges().listen((firebaseUser) async {
      // firebaseUser = _auth.currentUser;
      if (firebaseUser != null) {
        CircularProgressIndicator();
        DocumentSnapshot doc = await usersRef.doc(firebaseUser.uid).get();
        if (doc.exists) {
          doc = await usersRef.doc(firebaseUser.uid).get();
        }
        try {
          currentUser = _auth.currentUser!;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProfilePage(),
            ),
          );
        } catch (e) {
          build(context);
        }
      } else {
        build(context);
      }
    });
  }

  //Validating email address
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

  //Validating Password
  String? validatePassword(String? password) {
    if (password != null && password.trim().length < 6 ||
        password != null && password.isEmpty) {
      return 'Password must be greater than 6 characters';
    } else {
      return "";
    }
  }

  //Building the login page UI
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Container(
          decoration: BoxDecoration(),
          child: Center(
            child: ListView(
              shrinkWrap: true,
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
                    //Email address text field
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
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      top: 10.0, bottom: 10.0, right: 20.0, left: 20.0),
                  child: Form(
                    key: _passwordFormKey,
                    //Passwor Text Field
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
                      validator: (value) {
                        if (value != null && value.trim().length < 6 ||
                            value != null && value.isEmpty) {
                          return 'Password must be greater than 6 characters';
                        } else {
                          return null;
                        }
                      },
                      obscureText: true,
                    ),
                  ),
                ),
                //Login and Signup buttons
                Padding(
                  padding: EdgeInsets.only(
                      top: 10.0, bottom: 10.0, right: 20.0, left: 90.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      //Login Button
                      ButtonTheme(
                        minWidth: 200.0,
                        height: 40.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Color(
                              0xFF534DD6,
                            ).withOpacity(0.7)),
                          ),
                          onPressed: () async {
                            InternetConnectionStatusClass
                                .getInternetConnectionStatus();
                            if (_emailFormKey.currentState!.validate() &&
                                _passwordFormKey.currentState!.validate()) {
                              _emailFormKey.currentState!.save();
                              _passwordFormKey.currentState!.save();
                              // print("login user");
                              // print("Username$username");
                              // print("Password$password");

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
                                  currentUser = (await _auth.currentUser)!;
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
                      //Signup Button
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
                SizedBox(
                  width: 100.0,
                  child: Divider(
                    indent: 20.0,
                    endIndent: 20.0,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                //Google Sign Up button
                Center(
                  child: IconButton(
                    onPressed: signInWithGoogle,
                    icon: FaIcon(
                      FontAwesomeIcons.google,
                      color: Theme.of(context).primaryColor,
                    ),
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
