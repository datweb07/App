// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class AuthService {
//   // instance of authentication and firestore
//   final FirebaseAuth auth = FirebaseAuth.instance;
//   final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

//   // Get current user
//   User? getCurrentUer(){

//   }
//   // Sign in
//   Future<UserCredential> signInWithEmailPassword(String email, password) async {
//     try {
//       // Sign user
//       UserCredential userCredential = await auth.signInWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//       // Save user information
//       firebaseFirestore.collection("Users").doc(userCredential.user!.uid).set({
//         'uid': userCredential.user!.uid,
//         'email': email,
//       });

//       return userCredential;
//     } on FirebaseAuthException catch (e) {
//       throw Exception(e.code);
//     }
//   }

//   // Sign up
//   Future<UserCredential> signUpWithEmailPassword(String email, password) async {
//     try {
//       // Create user
//       UserCredential userCredential = await auth
//           .createUserWithEmailAndPassword(email: email, password: password);

//       // Save user information
//       firebaseFirestore.collection("Users").doc(userCredential.user!.uid).set({
//         'uid': userCredential.user!.uid,
//         'email': email,
//       });

//       return userCredential;
//     } on FirebaseAuthException catch (e) {
//       throw Exception(e.code);
//     }
//   }

//   // Sign out
//   Future<void> signOut() async {
//     return await auth.signOut();
//   }

//   // Errors
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  // Get current user
  User? getCurrentUser() {
    return auth.currentUser;
  }

  // Sign in
  Future<UserCredential> signInWithEmailPassword(String email, password) async {
    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Cập nhật thông tin đăng nhập
      await firebaseFirestore
          .collection("Users")
          .doc(userCredential.user!.uid)
          .set({
            'uid': userCredential.user!.uid,
            'email': email,
            'isOnline': true,
            'lastSeen': Timestamp.now(),
          }, SetOptions(merge: true)); // merge để không ghi đè dữ liệu cũ

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw handleException(e);
    }
  }

  // Sign up
  Future<UserCredential> signUpWithEmailPassword(String email, password) async {
    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Tạo thông tin mới
      await firebaseFirestore
          .collection("Users")
          .doc(userCredential.user!.uid)
          .set({
            'uid': userCredential.user!.uid,
            'email': email,
            'isOnline': true,
            'lastSeen': Timestamp.now(),
          }, SetOptions(merge: true)); // merge để giữ dữ liệu cũ

      return userCredential;
    } on FirebaseAuthException catch (e) {
      // throw Exception(e.code);
      throw handleException(e);
    }
  }

  // Sign out
  Future<void> signOut() async {
    final uid = auth.currentUser?.uid;
    if (uid != null) {
      await firebaseFirestore.collection("Users").doc(uid).update({
        'isOnline': false,
        'lastSeen': Timestamp.now(),
      });
    }
    return await auth.signOut();
  }

  String handleException(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Email đã được sử dụng.';
      case 'user-not-found':
        return 'Không tìm thấy người dùng với email này.';
      case 'wrong-password':
        return 'Sai mật khẩu.';
      case 'weak-password':
        return 'Mật khẩu quá yếu.';
      case 'invalid-email':
        return 'Email không hợp lệ.';
      default:
        return 'Lỗi không xác định: ${e.message}';
    }
  }
}
