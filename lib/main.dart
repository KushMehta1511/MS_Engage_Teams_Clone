import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:ms_teams_clone_engage/event_provider.dart';
import 'package:ms_teams_clone_engage/login_page.dart';
import 'package:ms_teams_clone_engage/my_themes.dart';
import 'package:ms_teams_clone_engage/resources/firebase_repo.dart';
import 'package:ms_teams_clone_engage/search_screen.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // FireBaseRepository _fireBaseRepository = FireBaseRepository();
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => EventProvider(),
      child: MaterialApp(
        title: 'Team Clone',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.system,
        theme: MyThemes.lightTheme,
        darkTheme: MyThemes.darkTheme,
        initialRoute: '/',
        routes: {
          '/search_screen': (context) => SearchScreen(),
        },
        // theme: ThemeData(
        //   primarySwatch: Colors.teal,
        //   accentColor: Colors.blue,
        // ),
        home: LoginPage(),
      ),
    );
  }
}
