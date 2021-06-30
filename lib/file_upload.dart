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
import 'package:ms_teams_clone_engage/firebase_api.dart';
import 'package:ms_teams_clone_engage/firebase_file.dart';
import 'package:ms_teams_clone_engage/login_page.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:timeago/timeago.dart' as timeago;

final _files = FirebaseFirestore.instance.collection('files');

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
  // late Future<List<FirebaseFile>?> futureFiles;
// var fileName = file != null ? basename(file!.path) : 'No File Uploaded';
  ReceivePort receivePort = ReceivePort();
  int progress = 0;
  @override
  void initState() {
    super.initState();
    // futureFiles = FirebaseApi.listAll('files/${widget.roomDetails}');
    // futureFiles = FirebaseApi.listAll(widget.roomDetails);
    IsolateNameServer.registerPortWithName(
        receivePort.sendPort, "Downloading File");
    receivePort.listen((message) {
      setState(() {
        progress = message;
      });
    });
    FlutterDownloader.registerCallback(downloadCallback);
    print(widget.roomDetails);
  }

  static downloadCallback(id, status, progress) {
    SendPort? sendPort = IsolateNameServer.lookupPortByName("Downloading File");
    sendPort!.send(progress);
  }

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

  uploadFile() async {
    if (file == null) {
      return;
    }
    final fileName = basename(file!.path);
    final destination = 'files/${currentUser.uid}/$fileName';
    FirebaseApi.uploadFile(destination, file!);
  }

  // addFile() {
  //   return showDialog<void>(
  //     context: context as BuildContext,
  //     barrierDismissible: true, // user must tap button!
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text('Upload File'),
  //         content: SingleChildScrollView(
  //           child: ListBody(
  //             children: <Widget>[
  //               ElevatedButton(
  //                 onPressed: selectFile,
  //                 child: Row(
  //                   mainAxisSize: MainAxisSize.max,
  //                   children: <Widget>[
  //                     Icon(Icons.attach_file),
  //                     Text('Select File'),
  //                   ],
  //                 ),
  //               ),
  //               // Text(fileName),
  //               ElevatedButton(
  //                 onPressed: uploadFile,
  //                 child: Row(
  //                   mainAxisSize: MainAxisSize.max,
  //                   children: <Widget>[
  //                     Icon(Icons.cloud_upload),
  //                     Text('Upload File'),
  //                   ],
  //                 ),
  //                 // onPressed: () async {
  //                 //   if (_callDetailFormKey.currentState!.validate()) {
  //                 //     final url = 'tel:$mobileNumberDetails';
  //                 //     if (await canLaunch(url)) {
  //                 //       await launch(url);
  //                 //     } else {
  //                 //       throw 'Could Not Call $url';
  //                 //     }
  //                 //   }
  //                 // },
  //                 // child: Text("Make a call")
  //               ),
  //               Text('0% uploaded')
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  getBackgroundText(String userDetail) {
    String photoUrl = "";
    String displayName = "";
    //print(userDetail);
    _usersRef.where('id', isEqualTo: userDetail).get().then((value) {
      value.docs.forEach((element) {
        //print(element['photoUrl']);
        setState(() {
          photoUrl = element['photoUrl'];
          displayName = element['displayName'];
        });
      });
      // print(photoUrl);
      // print(displayName);
    });

    if (photoUrl == "") {
      return Text(
        displayName,
      );
    } else {
      return null;
    }
  }

  String splitDisplayName(String displayName) {
    List<String> userNameSplit = displayName.split(' ');
    if (userNameSplit.length > 1) {
      return userNameSplit[0][0].toUpperCase() +
          " " +
          userNameSplit[userNameSplit.length - 1][0].toUpperCase();
    } else {
      return userNameSplit[0][0].toUpperCase();
    }
  }

  // getPhotoUrl(String userDetail) {
  //   String photoUrl = "";
  //   _usersRef.where('id', isEqualTo: userDetail).get().then((value) {
  //     value.docs.forEach((element) {
  //       setState(() {
  //         photoUrl = element['photoUrl'];
  //       });
  //     });
  //   });
  //   if (photoUrl == "") {
  //     return null;
  //   } else {
  //     return NetworkImage(photoUrl);
  //   }
  // }

  getPhotoUrl(String fileName) {
    List<String> extensions = fileName.split('.');
    if (extensions[extensions.length - 1] == 'jpeg' ||
        extensions[extensions.length - 1] == 'jpg') {
      return AssetImage('assets/images/jpeg_logo.jpg');
    } else if (extensions[extensions.length - 1] == 'pdf') {
      return AssetImage('assets/images/pdf_logo.png');
    } else if (extensions[extensions.length - 1] == 'docx') {
      return AssetImage('assets/images/word_logo.png');
    } else {
      return null;
    }
  }

  getDisplayName(String userDetail) {
    String displayName = "";
    _usersRef.where('id', isEqualTo: userDetail).get().then((value) {
      value.docs.forEach((element) {
        setState(() {
          displayName = element['displayName'];
        });
      });
    });
    return displayName;
  }

  _downloadFile(QueryDocumentSnapshot documentSnapshot) async {
    final status = await Permission.storage.request();
    if (status.isGranted) {
      final baseStorage = await getDownloadsDirectory();
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

  // buildFile() {
  //   return ListTile(
  //     leading: CircleAvatar(
  //       backgroundColor: Colors.grey,
  //       child: getBackgroundText(file.userDetail),
  //       backgroundImage: getPhotoUrl(file.userDetail),
  //     ),
  //     title: Text(
  //       file.name,
  //       style: TextStyle(
  //           fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
  //     ),
  //     subtitle: Text(getDisplayName(file.userDetail)),
  //     onTap: _downloadFile(file),
  //   );
  // }

  // buildFile() {
  //   // DocumentSnapshot doc = await _files.doc().get();
  //   // if (!doc.exists) {
  //   //   return CircularProgressIndicator();
  //   // }
  //   List<FirebaseFile> file = [];
  //   String room = "";
  //   _files.where('room', isEqualTo: widget.roomDetails).get().then((value) {
  //     value.docs.forEach((element) {
  //       setState(() {
  //         room = element['room'];
  //       });
  //       // print(room + "Hello");
  //       // print(FirebaseFile.fromDocument(element).room);
  //       file.add(FirebaseFile.fromDocument(element));
  //     });
  //   });
  //   // print(file.length);
  //   return ListView(
  //     children: file,
  //   );
  // }

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
          // List<FirebaseFile> files = [];
          // snapshot.data!.docs.map((DocumentSnapshot document) {
          //   print(FirebaseFile.fromDocument(document).uploader);
          //   files.add(FirebaseFile.fromDocument(document));
          // });
          return ListView(
            children: snapshot.data!.docs.map((document) {
              String uid = document['uploader'];
              String displayName = document['uploaderDisplayName'];
              return Column(
                children: [
                  Container(
                    child: ListTile(
                      trailing: Text(
                          '${timeago.format(document['timestamp'].toDate())}'),
                      leading: CircleAvatar(
                        backgroundColor: Colors.grey,
                        // child: getBackgroundText(uid),
                        backgroundImage: getPhotoUrl(document['fileName']),
                      ),
                      title: Text(
                        document['fileName'],
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline),
                      ),
                      // subtitle: Text(displayName),
                      onTap: () {
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
  // Future getFiles() async {
  //   QuerySnapshot qn =
  //       await _files.where('room', isEqualTo: widget.roomDetails).get();
  //   return qn.docs;
  // }

  // buildFile() {
  //   return FutureBuilder(
  //     future: getFiles(),
  //     builder: (BuildContext context, AsyncSnapshot snapshot) {
  //       if (!snapshot.hasData) {
  //         print('no data');
  //         return Center(
  //           child: SizedBox(
  //             height: 75.0,
  //             width: 75.0,
  //             child: CircularProgressIndicator(),
  //           ),
  //         );
  //       }
  //       List<FirebaseFile> files = [];
  //       snapshot.data!.docs.map((DocumentSnapshot document) {
  //         print(FirebaseFile.fromDocument(document).uploader);
  //         files.add(FirebaseFile.fromDocument(document));
  //       });
  //       return ListView(
  //         children: files,
  //       );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: CloseButton(),
        title: Text("Files"),
        actions: [
          IconButton(
            onPressed: () {
              _auth.signOut();
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => LoginPage()));
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      // body: FutureBuilder<List<FirebaseFile>?>(
      //   future: futureFiles,
      //   builder: (context, snapshot) {
      //     switch (snapshot.connectionState) {
      //       case ConnectionState.waiting:
      //         return Center(
      //           child: CircularProgressIndicator(),
      //         );
      //       default:
      //         if (snapshot.hasError) {
      //           Fluttertoast.showToast(
      //               msg: "Some error occured",
      //               toastLength: Toast.LENGTH_LONG,
      //               gravity: ToastGravity.BOTTOM,
      //               timeInSecForIosWeb: 1,
      //               backgroundColor: Colors.black87,
      //               textColor: Colors.white,
      //               fontSize: 16.0);
      //           return Text('Some error occurred');
      //         } else {
      //           final files = snapshot.data!;
      //           return Column(
      //             crossAxisAlignment: CrossAxisAlignment.start,
      //             children: [
      //               Expanded(
      //                 child: ListView.builder(itemBuilder: (context, index) {
      //                   final file = files[index];
      //                   return buildFile(context, file);
      //                 }),
      //               ),
      //             ],
      //           );
      //         }
      //     }
      //   },
      // ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: buildFile(),
            // child: Text(_files.snapshots().toString()),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        // onPressed: addFile(),
        onPressed: () async {
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
          final urlDownload = await snapshot.ref.getDownloadURL();
          _files.doc(widget.roomDetails).collection('roomFiles').add({
            'fileUrl': urlDownload,
            'uploader': currentUser.uid,
            'uploaderDisplayName': _auth.currentUser!.displayName,
            'timestamp': DateTime.now(),
            'filePath': 'files/${currentUser.uid}/$fileName',
            'fileName': fileName,
            'room': widget.roomDetails,
          });
          print('Download-link$urlDownload');
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
