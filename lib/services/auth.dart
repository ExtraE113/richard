import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  FirebaseAuth auth = FirebaseAuth.instance;

  Future<String> getUID() async {
    if (auth.currentUser != null) {
      return auth.currentUser.uid;
    } else {
      UserCredential userCredential = await FirebaseAuth.instance.signInAnonymously();
      return userCredential.user.uid;
    }
  }
}
