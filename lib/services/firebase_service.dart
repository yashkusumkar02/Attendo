import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Register Teacher
  Future<User?> registerTeacher(String email, String password, String name, String college) async {
    try {
      // Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Store Teacher Details in Firestore
      await _db.collection("users").doc(userCredential.user!.uid).set({
        "uid": userCredential.user!.uid,
        "name": name,
        "email": email,
        "role": "teacher",
        "college": college,
        "createdAt": DateTime.now(),
      });

      return userCredential.user;
    } catch (e) {
      print("Error Registering Teacher: $e");
      return null;
    }
  }
}
