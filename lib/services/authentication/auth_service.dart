import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  // Lấy người dùng hiện tại
  User? getCurrentUser() {
    return auth.currentUser;
  }

  // Đăng nhập
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

  // Đăng ký
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

  // Đăng xuất
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

  // Thông báo một vài ngoại lệ
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
