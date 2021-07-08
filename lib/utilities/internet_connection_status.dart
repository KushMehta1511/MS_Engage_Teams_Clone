import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

//Class to check for internet status
class InternetConnectionStatusClass {
  //function to check for internet staus before performing any backend operation
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
