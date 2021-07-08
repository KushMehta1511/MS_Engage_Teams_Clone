import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:ms_teams_clone_engage/calendar/event_provider.dart';
import 'package:ms_teams_clone_engage/authentication/login_page.dart';
import 'package:ms_teams_clone_engage/utilities/my_themes.dart';
import 'package:provider/provider.dart';

//main function
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize();
  await Firebase.initializeApp();
  runApp(MyApp());
}

//Initialing and creating the Material app
class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => EventProvider(),
      child: MaterialApp(
        title: 'Team Clone',
        debugShowCheckedModeBanner: false,
        //Takes in system theme
        themeMode: ThemeMode.system,
        theme: MyThemes.lightTheme,
        darkTheme: MyThemes.darkTheme,
        //Routing to Home page which opens upon app startup
        home: LoginPage(),
      ),
    );
  }
}
