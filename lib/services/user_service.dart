import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Lưu loại người dùng
  static Future<bool> saveUserType(String userType) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('Users').doc(user.uid).set({
          'userType': userType,
          'email': user.email,
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        return true;
      }
      return false;
    } catch (e) {
      print('Error saving user type: $e');
      return false;
    }
  }

  // Lấy loại người dùng
  static Future<String?> getUserType() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot doc = await _firestore
            .collection('Users')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          return data['userType'] as String?;
        }
      }
      return null;
    } catch (e) {
      print('Error getting user type: $e');
      return null;
    }
  }

  // Kiểm tra xem người dùng đã chọn loại chưa
  static Future<bool> hasUserType() async {
    String? userType = await getUserType();
    return userType != null && userType.isNotEmpty;
  }

  // Xóa loại người dùng (khi logout hoặc reset)
  static Future<bool> clearUserType() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('Users').doc(user.uid).update({
          'userType': FieldValue.delete(),
        });
        return true;
      }
      return false;
    } catch (e) {
      print('Error clearing user type: $e');
      return false;
    }
  }

  // Cập nhật thông tin người dùng
  static Future<bool> updateUserInfo({
    String? userType,
    String? displayName,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        Map<String, dynamic> updateData = {
          'lastUpdated': FieldValue.serverTimestamp(),
        };

        if (userType != null) updateData['userType'] = userType;
        if (displayName != null) updateData['displayName'] = displayName;
        if (additionalData != null) updateData.addAll(additionalData);

        await _firestore
            .collection('Users')
            .doc(user.uid)
            .set(updateData, SetOptions(merge: true));
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating user info: $e');
      return false;
    }
  }

  // Lấy thông tin đầy đủ của người dùng
  static Future<Map<String, dynamic>?> getUserInfo() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot doc = await _firestore
            .collection('Users')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          return doc.data() as Map<String, dynamic>?;
        }
      }
      return null;
    } catch (e) {
      print('Error getting user info: $e');
      return null;
    }
  }
}
