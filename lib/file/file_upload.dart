import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ms_teams_clone_engage/file/firebase_api.dart';
import 'package:ms_teams_clone_engage/utilities/internet_connection_status.dart';
import 'package:ms_teams_clone_engage/authentication/login_page.dart';
import 'package:ms_teams_clone_engage/main.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:timeago/timeago.dart' as timeago;

final _files = FirebaseFirestore.instance.collection('files');

//File upload page stateful widget
class FileUploadPage extends StatefulWidget {
  final String roomDetails;

  const FileUploadPage({Key? key, required this.roomDetails}) : super(key: key);

  @override
  _FileUploadPageState createState() => _FileUploadPageState();
}

class _FileUploadPageState extends State<FileUploadPage> {
  final _auth = FirebaseAuth.instance;

  final _usersRef = FirebaseFirestore.instance.collection('users');
  UploadTask? task;
  late File? file = File('file.txt');
  ReceivePort receivePort = ReceivePort();
  int progress = 0;
  @override
  void initState() {
    super.initState();
    //Setting up ports and permission for file downloading
    IsolateNameServer.registerPortWithName(
        receivePort.sendPort, "Downloading File");
    receivePort.listen((message) {
      setState(() {
        progress = message;
      });
    });
    FlutterDownloader.registerCallback(downloadCallback);
    // print(widget.roomDetails);
  }

  //Flutter downloader callback
  static downloadCallback(id, status, progress) {
    SendPort? sendPort = IsolateNameServer.lookupPortByName("Downloading File");
    sendPort!.send(progress);
  }

  //Function to select file to upload from internal storage
  selectFile() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);
    if (result == null) {
      return;
    }
    final path = result.files.single.path!;
    setState(() {
      file = File(path);
    });
  }

  //Function to upload selected file to firebase firestore by calling the upload function of FirebaseApi class
  uploadFile() async {
    if (file == null) {
      return;
    }
    final fileName = basename(file!.path);
    final destination = 'files/${currentUser.uid}/$fileName';
    FirebaseApi.uploadFile(destination, file!);
  }

  //Function to generate file type logo for specific files
  getPhotoUrl(String fileName) {
    List<String> extensions = fileName.split('.');
    if (extensions[extensions.length - 1] == 'jpeg' ||
        extensions[extensions.length - 1] == 'jpg') {
      return AssetImage('assets/images/jpeg_logo.jpg');
    } else if (extensions[extensions.length - 1] == 'pdf') {
      return AssetImage('assets/images/pdf_logo.png');
    } else if (extensions[extensions.length - 1] == 'docx') {
      return AssetImage('assets/images/word_logo.png');
    } else if (extensions[extensions.length - 1] == 'mp4' ||
        extensions[extensions.length - 1] == 'avi') {
      return AssetImage('assets/images/video_logo.png');
    }
    return null;
  }

  //Function to ask permission, download file and save to external storage directory
  _downloadFile(QueryDocumentSnapshot documentSnapshot) async {
    final status = await Permission.storage.request();
    if (status.isGranted) {
      final baseStorage = await getExternalStorageDirectory();
      print(baseStorage);
      final id = await FlutterDownloader.enqueue(
          url: documentSnapshot['fileUrl'],
          savedDir: baseStorage!.path,
          fileName: documentSnapshot['fileName']);
      print(baseStorage);
    } else {
      Fluttertoast.showToast(
          msg: "Please grant permission to store files",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black87,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  //Stream builder to create a stream for files and display them in list view
  buildFile() {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('files')
            .doc(widget.roomDetails)
            .collection('roomFiles')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            print('no data');
            return Center(
              child: SizedBox(
                height: 75.0,
                width: 75.0,
                child: CircularProgressIndicator(),
              ),
            );
          }
          //Displaying the files in list view
          return ListView(
            children: snapshot.data!.docs.map((document) {
              return Column(
                children: [
                  Container(
                    child: ListTile(
                      trailing: Text(
                          '${timeago.format(document['timestamp'].toDate())}'),
                      leading: CircleAvatar(
                        backgroundColor: Colors.grey,
                        backgroundImage: getPhotoUrl(document['fileName']),
                      ),
                      title: Text(
                        document['fileName'],
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline),
                      ),
                      onTap: () {
                        InternetConnectionStatusClass
                            .getInternetConnectionStatus();
                        _downloadFile(document);
                      },
                    ),
                  ),
                  SizedBox(
                    height: 10.0,
                    child: Divider(
                      indent: 20.0,
                      endIndent: 20.0,
                      thickness: 2.0,
                    ),
                  )
                ],
              );
            }).toList(),
          );
        });
  }

  //Building file upload page UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: CloseButton(),
        title: Text("Files"),
        actions: [
          IconButton(
            onPressed: () {
              InternetConnectionStatusClass.getInternetConnectionStatus();
              _auth.signOut();
              Navigator.pop(context);
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => MyApp()));
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          //Calling buildfile to display list view of files
          Expanded(
            child: buildFile(),
          ),
        ],
      ),
      //Button to add new files
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          InternetConnectionStatusClass.getInternetConnectionStatus();
          //Selecting file and uploading to firebase
          try {
            final result =
                await FilePicker.platform.pickFiles(allowMultiple: false);
            if (result == null) {
              return;
            }
            final path = result.files.single.path!;
            setState(() {
              file = File(path);
            });
            if (file == null) {
              return;
            }
            final fileName = basename(file!.path);
            final destination =
                'files/${widget.roomDetails}/${currentUser.uid}/$fileName';
            task = FirebaseApi.uploadFile(destination, file!);
            if (task == null) {
              return;
            }
            final circularProgressIndicator = CircularProgressIndicator();
            circularProgressIndicator.createElement();
            final snapshot = await task!.whenComplete(() {
              circularProgressIndicator;
            });
            //Storing the details of the file in firebase firestore
            final urlDownload = await snapshot.ref.getDownloadURL();
            _files.doc(widget.roomDetails).collection('roomFiles').add({
              'fileUrl': urlDownload,
              'uploader': currentUser.uid,
              'timestamp': DateTime.now(),
              'filePath': 'files/${currentUser.uid}/$fileName',
              'fileName': fileName,
              'room': widget.roomDetails,
            });
            print('Download-link$urlDownload');
          } catch (e) {
            Fluttertoast.showToast(
                msg: e.toString(),
                backgroundColor: Colors.black,
                textColor: Colors.white,
                gravity: ToastGravity.BOTTOM,
                toastLength: Toast.LENGTH_SHORT);
          }
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: Icon(
          Icons.attach_file,
          color: Colors.white,
        ),
      ),
    );
  }
}
