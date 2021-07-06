import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class FirebaseFile extends StatelessWidget {
  final String fileUrl;
  final String uploader;
  final Timestamp timestamp;
  final String filePath;
  final String fileName;
  final String room;

  FirebaseFile({
    required this.fileUrl,
    required this.uploader,
    required this.timestamp,
    required this.filePath,
    required this.fileName,
    required this.room,
  });

  factory FirebaseFile.fromDocument(DocumentSnapshot doc) {
    return FirebaseFile(
      fileUrl: doc.get('fileUrl'),
      uploader: doc.get('uploader'),
      timestamp: doc.get('timestamp'),
      filePath: doc.get('filePath'),
      fileName: doc.get('fileName'),
      room: doc.get('room'),
    );
  }

  getBackgroundText(String userDetail) {
    String photoUrl = "";
    String displayName = "";
    FirebaseFirestore.instance
        .collection('users')
        .where('id', isEqualTo: userDetail)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        photoUrl = element['photoUrl'];
        displayName = element['displayName'];
      });
    });
    if (photoUrl == "") {
      return Text(
        splitDisplayName(displayName),
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

  getPhotoUrl(String userDetail) {
    String photoUrl = "";
    FirebaseFirestore.instance
        .collection('users')
        .where('id', isEqualTo: userDetail)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        photoUrl = element['photoUrl'];
      });
    });
    if (photoUrl == "") {
      return null;
    } else {
      return NetworkImage(photoUrl);
    }
  }

  getDisplayName(String userDetail) {
    String displayName = "";
    FirebaseFirestore.instance
        .collection('users')
        .where('id', isEqualTo: userDetail)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        displayName = element['displayName'];
      });
    });
    return displayName;
  }

  _downloadFile() async {
    final status = await Permission.storage.request();
    if (status.isGranted) {
      final baseStorage = await getApplicationDocumentsDirectory();
      print(baseStorage.toString());
      final id = await FlutterDownloader.enqueue(
          url: fileUrl, savedDir: baseStorage.path, fileName: fileName);
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey,
              child: getBackgroundText(uploader),
              backgroundImage: getPhotoUrl(uploader),
            ),
            title: Text(
              fileName,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline),
            ),
            subtitle: Text(getDisplayName(uploader)),
            onTap: _downloadFile(),
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
  }
}
