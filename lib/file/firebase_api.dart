import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ms_teams_clone_engage/firebase_file.dart';

class FirebaseApi {
  static UploadTask? uploadFile(String destination, File file) {
    try {
      final ref = FirebaseStorage.instance.ref(destination);
      Fluttertoast.showToast(
          msg: "File uploaded successfully",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black87,
          textColor: Colors.white,
          fontSize: 16.0);
      return ref.putFile(file);
    } on FirebaseException catch (e) {
      Fluttertoast.showToast(
          msg: e.message.toString(),
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black87,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  static splitPath(String path) {
    List<String> pathDetail = path.split('/');
    return pathDetail[1];
  }

  // static Future<List<FirebaseFile>?> listAll(String roomDetails) async {
  //   DocumentSnapshot doc = await FirebaseFirestore.instance
  //       .collection('files')
  //       .doc(roomDetails)
  //       .collection('roomFiles')
  //       .doc()
  //       .get();
  //   if (!doc.exists) {
  //     return null;
  //   } else{

  //   }
  //   final ref = FirebaseStorage.instance.ref(path);
  //   if (ref != null) {
  //     final result = await ref.listAll();
  //     final urls = await _getDownloadLinks(result.items);
  //     return urls
  //         .asMap()
  //         .map((index, url) {
  //           final ref = result.items[index];
  //           final userDetail = splitPath(path);
  //           final name = ref.name;
  //           final file = FirebaseFile(
  //               ref: ref, name: name, url: url, userDetail: userDetail);
  //           return MapEntry(index, file);
  //         })
  //         .values
  //         .toList();
  //   } else {
  //     return null;
  //   }
  // }

  static _getDownloadLinks(List<Reference> items) {
    Future.wait(items.map((e) => e.getDownloadURL()).toList());
  }
}
