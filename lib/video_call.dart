import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jitsi_meet/jitsi_meet.dart';
import 'package:ms_teams_clone_engage/chat_screen.dart';
import 'package:ms_teams_clone_engage/login_page.dart';

class VideoCallScreen extends StatefulWidget {
  final String roomDetails;
  const VideoCallScreen({Key? key, required this.roomDetails})
      : super(key: key);

  @override
  _VideoCallScreenState createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  final _auth = FirebaseAuth.instance;
  final serverText = TextEditingController();
  final roomText = TextEditingController();
  late final roomTextValue = "";
  final subjectText = TextEditingController();
  late var subjectTextValue = "";
  final nameText = TextEditingController(text: currentUser.displayName);
  late var nameTextValue = "";
  late final emailText = TextEditingController(text: loggedInUser.email);
  final iosAppBarRGBAColor =
      TextEditingController(text: "#0080FF80"); //transparent blue
  bool? isAudioOnly = true;
  bool? isAudioMuted = true;
  bool? isVideoMuted = true;
  final _emailFormKey = GlobalKey<FormState>();
  final _nameFormKey = GlobalKey<FormState>();
  final _subjectFormKey = GlobalKey<FormState>();
  final _roomFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    JitsiMeet.addListener(JitsiMeetingListener(
        onConferenceWillJoin: _onConferenceWillJoin,
        onConferenceJoined: _onConferenceJoined,
        onConferenceTerminated: _onConferenceTerminated,
        onError: _onError));
  }

  @override
  void dispose() {
    super.dispose();
    JitsiMeet.removeAllListeners();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.lightBlueAccent,
          automaticallyImplyLeading: true,
          title: Text(widget.roomDetails),
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back)),
          actions: <Widget>[
            IconButton(
                onPressed: () {
                  _auth.signOut();
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => LoginPage()));
                },
                icon: Icon(Icons.logout))
          ],
        ),
        body: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
          ),
          child: kIsWeb
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: width * 0.30,
                      child: meetConfig(),
                    ),
                    Container(
                        width: width * 0.60,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Card(
                              color: Colors.white54,
                              child: SizedBox(
                                width: width * 0.60 * 0.70,
                                height: width * 0.60 * 0.70,
                                child: JitsiMeetConferencing(
                                  extraJS: [
                                    // extraJs setup example
                                    '<script>function echo(){console.log("echo!!!")};</script>',
                                    '<script src="https://code.jquery.com/jquery-3.5.1.slim.js" integrity="sha256-DrT5NfxfbHvMHux31Lkhxg42LY6of8TaYyK50jnxRnM=" crossorigin="anonymous"></script>'
                                  ],
                                ),
                              )),
                        ))
                  ],
                )
              : meetConfig(),
        ),
      ),
    );
  }

  Widget meetConfig() {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 16.0,
          ),
          // TextField(
          //   controller: serverText,
          //   decoration: InputDecoration(
          //       border: OutlineInputBorder(),
          //       labelText: "Server URL",
          //       hintText: "Hint: Leave empty for meet.jitsi.si"),
          // ),
          // SizedBox(
          //   height: 14.0,
          // ),
          Form(
            key: _roomFormKey,
            child: TextFormField(
              //controller: roomText,
              initialValue: widget.roomDetails,
              enabled: false,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Room",
              ),
              validator: (value) {
                return (value != null) ? null : "Please Enter a Room Name";
              },
            ),
          ),
          SizedBox(
            height: 14.0,
          ),
          Form(
            key: _subjectFormKey,
            child: TextFormField(
              controller: subjectText,
              onChanged: (value) {
                setState(() {
                  subjectTextValue = value;
                });
              },
              decoration: InputDecoration(
                hintText: "Enter a subject for the meeting",
                border: OutlineInputBorder(),
                labelText: "Subject",
              ),
              validator: (value) {
                return (value != null) ? null : "Please Enter a Subject Name";
              },
            ),
          ),
          SizedBox(
            height: 14.0,
          ),
          Form(
            key: _nameFormKey,
            child: TextFormField(
              controller: nameText,
              onChanged: (value) {
                setState(() {
                  nameTextValue = value;
                });
              },
              decoration: InputDecoration(
                hintText: "Enter display name to be used in the video call",
                border: OutlineInputBorder(),
                labelText: "Display Name",
              ),
              validator: (value) {
                return (value != null) ? null : "Please Enter a valid Name";
              },
            ),
          ),
          SizedBox(
            height: 14.0,
          ),
          Form(
            key: _emailFormKey,
            child: TextFormField(
              controller: emailText,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Email",
              ),
              enabled: false,
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
          SizedBox(
            height: 14.0,
          ),
          // TextField(
          //   controller: iosAppBarRGBAColor,
          //   decoration: InputDecoration(
          //       border: OutlineInputBorder(),
          //       labelText: "AppBar Color(IOS only)",
          //       hintText: "Hint: This HAS to be in HEX RGBA format"),
          // ),
          SizedBox(
            height: 14.0,
          ),
          CheckboxListTile(
            title: Text("Audio Only"),
            value: isAudioOnly,
            onChanged: _onAudioOnlyChanged,
          ),
          SizedBox(
            height: 14.0,
          ),
          CheckboxListTile(
            title: Text("Audio Muted"),
            value: isAudioMuted,
            onChanged: _onAudioMutedChanged,
          ),
          SizedBox(
            height: 14.0,
          ),
          CheckboxListTile(
            title: Text("Video Muted"),
            value: isVideoMuted,
            onChanged: _onVideoMutedChanged,
          ),
          Divider(
            height: 48.0,
            thickness: 2.0,
          ),
          SizedBox(
            height: 64.0,
            width: double.maxFinite,
            child: ElevatedButton(
              onPressed: () {
                if (_emailFormKey.currentState!.validate() &&
                    _subjectFormKey.currentState!.validate() &&
                    _roomFormKey.currentState!.validate() &&
                    _nameFormKey.currentState!.validate()) {
                  _joinMeeting();
                }
              },
              child: Text(
                "Join Meeting",
                style: TextStyle(color: Colors.white),
              ),
              style: ButtonStyle(
                  backgroundColor: MaterialStateColor.resolveWith(
                      (states) => Colors.lightBlueAccent)),
            ),
          ),
          SizedBox(
            height: 48.0,
          ),
        ],
      ),
    );
  }

  _onAudioOnlyChanged(bool? value) {
    setState(() {
      isAudioOnly = value;
    });
  }

  _onAudioMutedChanged(bool? value) {
    setState(() {
      isAudioMuted = value;
    });
  }

  _onVideoMutedChanged(bool? value) {
    setState(() {
      isVideoMuted = value;
    });
  }

  _joinMeeting() async {
    String? serverUrl = serverText.text.trim().isEmpty ? null : serverText.text;

    // Enable or disable any feature flag here
    // If feature flag are not provided, default values will be used
    // Full list of feature flags (and defaults) available in the README
    Map<FeatureFlagEnum, bool> featureFlags = {
      FeatureFlagEnum.WELCOME_PAGE_ENABLED: false,
    };
    if (!kIsWeb) {
      // Here is an example, disabling features for each platform
      if (Platform.isAndroid) {
        // Disable ConnectionService usage on Android to avoid issues (see README)
        featureFlags[FeatureFlagEnum.CALL_INTEGRATION_ENABLED] = false;
      } else if (Platform.isIOS) {
        // Disable PIP on iOS as it looks weird
        featureFlags[FeatureFlagEnum.PIP_ENABLED] = false;
      }
    }
    // Define meetings options here
    var options = JitsiMeetingOptions(room: roomTextValue)
      ..serverURL = serverUrl
      ..subject = subjectTextValue
      ..userDisplayName = nameTextValue
      ..userEmail = emailText.text
      ..iosAppBarRGBAColor = iosAppBarRGBAColor.text
      ..audioOnly = isAudioOnly
      ..audioMuted = isAudioMuted
      ..videoMuted = isVideoMuted
      ..featureFlags.addAll(featureFlags)
      ..webOptions = {
        "roomName": roomTextValue,
        "width": "100%",
        "height": "100%",
        "enableWelcomePage": false,
        "chromeExtensionBanner": null,
        "userInfo": {"displayName": nameTextValue}
      };

    debugPrint("JitsiMeetingOptions: $options");
    await JitsiMeet.joinMeeting(
      options,
      listener: JitsiMeetingListener(
          onConferenceWillJoin: (message) {
            debugPrint("${options.room} will join with message: $message");
          },
          onConferenceJoined: (message) {
            debugPrint("${options.room} joined with message: $message");
          },
          onConferenceTerminated: (message) {
            debugPrint("${options.room} terminated with message: $message");
          },
          genericListeners: [
            JitsiGenericListener(
                eventName: 'readyToClose',
                callback: (dynamic message) {
                  debugPrint("readyToClose callback");
                }),
          ]),
    );
  }

  void _onConferenceWillJoin(message) {
    debugPrint("_onConferenceWillJoin broadcasted with message: $message");
  }

  void _onConferenceJoined(message) {
    debugPrint("_onConferenceJoined broadcasted with message: $message");
  }

  void _onConferenceTerminated(message) {
    debugPrint("_onConferenceTerminated broadcasted with message: $message");
  }

  _onError(error) {
    debugPrint("_onError broadcasted: $error");
  }
}
