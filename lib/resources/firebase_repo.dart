import 'package:firebase_auth/firebase_auth.dart';
import 'package:ms_teams_clone_engage/resources/firebase_functions.dart';

class FireBaseRepository {
  FirebaseMethods _firebaseMethods = new FirebaseMethods();

  Future<User> getCurrentUser() => _firebaseMethods.getCurrentUser();
//   Future<UserCredential> signInWithGoogle() =>
//       _firebaseMethods.signInWithGoogle();
}
