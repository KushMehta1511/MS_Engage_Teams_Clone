import 'package:cloud_firestore/cloud_firestore.dart';

class LoggedUser {
  final String id;
  final String email;
  final String photoUrl;
  final String displayName;

  LoggedUser({
    required this.id,
    required this.email,
    required this.photoUrl,
    required this.displayName,
  });

  factory LoggedUser.fromDocument(DocumentSnapshot doc) {
    return LoggedUser(
      id: doc.get('id'),
      email: doc.get('email'),
      photoUrl: doc.get('photoUrl'),
      displayName: doc.get('displayName'),
    );
  }
}
