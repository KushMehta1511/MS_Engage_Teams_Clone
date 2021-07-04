import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class InternetConnectionStatusClass {
  static getInternetConnectionStatus() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return null;
      }
    } on SocketException catch (_) {
      return Fluttertoast.showToast(
          msg: "Please Connect Your Internet",
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          toastLength: Toast.LENGTH_SHORT);
    }
  }
}
