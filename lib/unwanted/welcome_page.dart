// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:ms_teams_clone_engage/chat_list_screen.dart';
// import 'package:ms_teams_clone_engage/login_page.dart';

// class WelcomePage extends StatefulWidget {
//   const WelcomePage({Key? key}) : super(key: key);

//   @override
//   _WelcomePageState createState() => _WelcomePageState();
// }

// class _WelcomePageState extends State<WelcomePage> {
//   final _auth = FirebaseAuth.instance;
//   //late User? currentUser = _auth.currentUser;

//   late PageController pageController;
//   int page = 0;
//   String? name;

//   void onPageChanged(int value) {
//     setState(() {
//       page = value;
//     });
//   }

//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     pageController = PageController();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.indigo,
//       body: PageView(
//         children: <Widget>[
//           Container(
//             child: ChatListScreen(),
//           ),
//           Center(
//             child: Text("CallLog Screen"),
//           ),
//           Center(
//             child: Text("Contact Screen"),
//           ),
//         ],
//         controller: pageController,
//         onPageChanged: onPageChanged,
//         physics: NeverScrollableScrollPhysics(),
//       ),
//       bottomNavigationBar: Container(
//         child: Padding(
//           padding: EdgeInsets.only(top: 10),
//           child: CupertinoTabBar(
//             backgroundColor: Colors.black87,
//             items: <BottomNavigationBarItem>[
//               BottomNavigationBarItem(
//                 icon: Icon(
//                   Icons.chat,
//                   color: (page == 0 ? Colors.indigo : Colors.grey),
//                 ),
//                 title: Text(
//                   "Chat",
//                   style: TextStyle(
//                       color: (page == 0) ? Colors.indigo : Colors.grey),
//                 ),
//               ),
//               BottomNavigationBarItem(
//                 icon: Icon(
//                   Icons.call,
//                   color: (page == 1 ? Colors.indigo : Colors.grey),
//                 ),
//                 title: Text(
//                   "Call",
//                   style: TextStyle(
//                       color: (page == 1) ? Colors.indigo : Colors.grey),
//                 ),
//               ),
//               BottomNavigationBarItem(
//                 icon: Icon(
//                   Icons.contact_phone,
//                   color: (page == 2 ? Colors.indigo : Colors.grey),
//                 ),
//                 title: Text(
//                   "Contact",
//                   style: TextStyle(
//                       color: (page == 2) ? Colors.indigo : Colors.grey),
//                 ),
//               )
//             ],
//             onTap: (int value) {
//               pageController.jumpToPage(value);
//             },
//             currentIndex: page,
//           ),
//         ),
//       ),
//     );
//   }
// }
