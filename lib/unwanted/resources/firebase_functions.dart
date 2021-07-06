import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ms_teams_clone_engage/unwanted/user.dart';

class FirebaseMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
//   final GoogleSignIn _googleSignIn = GoogleSignIn();
//   static final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<User> getCurrentUser() async {
    User currentUser;
    currentUser = await _auth.currentUser!;
    return currentUser;
  }

  // Future<List<UserManual>> fetchAllUsers(User user) async {
  //   // ignore: deprecated_member_use
  //   List<UserManual> userList = List<UserManual>();
  //   QuerySnapshot querySnapshot =
  //       await FirebaseFirestore.instance.collection("users").get();
  //   for (var i = 0; i < querySnapshot.docs.length; i++) {
  //     if (querySnapshot.docs[i].hashCode != user.hashCode) {
  //       userList.add(UserManual(email: querySnapshot.docs[i].get('email'));
  //     }
  //   }
  //   return userList;
  // }

//   Future<UserCredential> signInWithGoogle() async {
//     // Trigger the authentication flow
//     final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

//     // Obtain the auth details from the request
//     final GoogleSignInAuthentication googleAuth =
//         await googleUser!.authentication;

//     // Create a new credential
//     final credential = GoogleAuthProvider.credential(
//       accessToken: googleAuth.accessToken,
//       idToken: googleAuth.idToken,
//     );

//     // Once signed in, return the UserCredential
//     return await _auth.signInWithCredential(credential);
//   }

//   // Future<bool> authenticateUser(UserCredential user) async {
//   //   QuerySnapshot result = await firestore
//   //       .collection("users")
//   //       .where("email", isEqualTo: user.)
//   //       .get();
//   // }

//   // logInUser() async {
//   //   if (_passwordFormKey.currentState.validate() &&
//   //       _emailFormKey.currentState.validate()) {
//   //     _passwordFormKey.currentState.save();
//   //     _emailFormKey.currentState.save();
//   //     //print('$username has $password password');
//   //     try {
//   //       final user = await _auth.signInWithEmailAndPassword(
//   //           email: username.trim(), password: password);
//   //       if (user != null) {
//   //         DocumentSnapshot doc = await FirebaseFirestore.instance.collection("users").document(user.uid).get();
//   //         if (doc.exists) {
//   //           doc = await usersRef.document(user.uid).get();
//   //         }
//   //         currentUser = User.fromDocument(doc);
//   //         Navigator.push(
//   //           context,
//   //           MaterialPageRoute(
//   //             builder: (context) => WelcomePage(),
//   //           ),
//   //         );
//   //       }
//   //     } catch (e) {
//   //       if (e.message ==
//   //           'There is no user record corresponding to this identifier. The user may have been deleted.') {
//   //         Navigator.push(
//   //           context,
//   //           MaterialPageRoute(
//   //             builder: (context) => CreateAccount(),
//   //           ),
//   //         );
//   //         final flutterToast = FlutterToast(context);
//   //         flutterToast.showToast(
//   //           child: Container(
//   //             padding:
//   //                 const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
//   //             decoration: BoxDecoration(
//   //               borderRadius: BorderRadius.circular(25.0),
//   //               color: Color(0xFF003D66),
//   //             ),
//   //             child: Row(
//   //               mainAxisSize: MainAxisSize.min,
//   //               children: [
//   //                 Icon(
//   //                   Icons.error,
//   //                   color: Colors.red,
//   //                 ),
//   //                 SizedBox(
//   //                   width: 12.0,
//   //                 ),
//   //                 Text(
//   //                   "Please create an account.",
//   //                   style: TextStyle(
//   //                     color: Colors.white,
//   //                   ),
//   //                 ),
//   //               ],
//   //             ),
//   //           ),
//   //           gravity: ToastGravity.BOTTOM,
//   //           toastDuration: Duration(seconds: 2),
//   //         );
//   //       }
//   //     }
//   //   }
//   // }
}
