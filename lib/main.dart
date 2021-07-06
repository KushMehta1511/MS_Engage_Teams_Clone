import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:ms_teams_clone_engage/calendar/event_provider.dart';
import 'package:ms_teams_clone_engage/authentication/login_page.dart';
import 'package:ms_teams_clone_engage/utilities/my_themes.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize();
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
        // initialRoute: '/',
        // routes: {
        //   '/search_screen': (context) => SearchScreen(),
        // },
        // theme: ThemeData(
        //   primarySwatch: Colors.purple,
        //   accentColor: Colors.blue,
        // ),
        home: LoginPage(),
      ),
    );
  }
}
