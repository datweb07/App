import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_nckh/screens/chatting.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SearchFriendChatting extends StatefulWidget {
  const SearchFriendChatting({super.key});

  static void showAddFriendDialog(BuildContext context) {
    _SearchFriendChattingState._showAddFriendDialog(context);
  }

  @override
  _SearchFriendChattingState createState() => _SearchFriendChattingState();
}

class _SearchFriendChattingState extends State<SearchFriendChatting> {
  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }

  // Xử lý thông báo lỗi Firebase
  static String getFriendlyErrorMessage(dynamic error) {
    print("Error details: $error");

    if (error is FirebaseException) {
      switch (error.code) {
        case 'not-found':
          return 'Người dùng không tồn tại';
        case 'permission-denied':
          return 'Không có quyền truy cập. Kiểm tra Firestore Rules';
        case 'unavailable':
          return 'Dịch vụ tạm thời không khả dụng';
        default:
          return 'Lỗi Firebase: ${error.code}';
      }
    }

    return 'Có lỗi không xác định: ${error.toString()}';
  }

  // Dialog để thêm bạn bè
  static void _showAddFriendDialog(BuildContext context) {
    final TextEditingController friendController = TextEditingController();
    final ValueNotifier<bool> isSearching = ValueNotifier<bool>(false);
    final ValueNotifier<List<Map<String, dynamic>>> searchResults =
        ValueNotifier<List<Map<String, dynamic>>>([]);
    final ValueNotifier<String> errorMessage = ValueNotifier<String>('');

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.person_search, color: Colors.blue, size: 24),
              ),
              SizedBox(width: 12),
              Text(
                "Tìm kiếm bạn bè",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
            ],
          ),
          content: Container(
            width: double.maxFinite,
            constraints: BoxConstraints(maxHeight: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Nhập email hoặc tên người dùng để tìm kiếm",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),

                // Search field
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: friendController,
                    decoration: InputDecoration(
                      prefixIcon: Container(
                        padding: EdgeInsets.all(12),
                        child: Icon(Icons.search, color: Colors.blue),
                      ),
                      suffixIcon: ValueListenableBuilder<bool>(
                        valueListenable: isSearching,
                        builder: (context, searching, child) {
                          return searching
                              ? Container(
                                  padding: EdgeInsets.all(12),
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.blue,
                                      ),
                                    ),
                                  ),
                                )
                              : friendController.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.clear, color: Colors.grey),
                                  onPressed: () {
                                    friendController.clear();
                                    searchResults.value = [];
                                    errorMessage.value = '';
                                  },
                                )
                              : SizedBox.shrink();
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.blue, width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),
                    onChanged: (value) {
                      if (value.trim().length >= 2) {
                        _performSearch(
                          value.trim(),
                          isSearching,
                          searchResults,
                          errorMessage,
                        );
                      } else {
                        searchResults.value = [];
                        errorMessage.value = '';
                      }
                    },
                  ),
                ),

                SizedBox(height: 16),

                // Error display
                ValueListenableBuilder<String>(
                  valueListenable: errorMessage,
                  builder: (context, error, child) {
                    if (error.isEmpty) return SizedBox.shrink();
                    return Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              error,
                              style: TextStyle(
                                color: Colors.red[700],
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                // Search results
                ValueListenableBuilder<List<Map<String, dynamic>>>(
                  valueListenable: searchResults,
                  builder: (context, results, child) {
                    if (results.isEmpty) return SizedBox.shrink();

                    return Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 8),
                          Text(
                            "Kết quả tìm kiếm (${results.length})",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 8),
                          Expanded(
                            child: ListView.separated(
                              shrinkWrap: true,
                              itemCount: results.length,
                              separatorBuilder: (context, index) =>
                                  Divider(height: 1),
                              itemBuilder: (context, index) {
                                final userData = results[index];
                                final email = userData['email'] as String;
                                final username =
                                    userData['username'] as String? ??
                                    email.split('@').first;
                                final photoURL =
                                    userData['photoURL'] as String?;
                                final isOnline =
                                    userData['isOnline'] as bool? ?? false;
                                final userType =
                                    userData['userType'] as String? ?? '';

                                // Only show chat button if userType is "deaf"
                                final canChat = userType == 'deaf';

                                return Container(
                                  margin: EdgeInsets.symmetric(vertical: 4),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.grey.shade200,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    child: Column(
                                      verticalDirection: VerticalDirection.down,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Stack(
                                              children: [
                                                CircleAvatar(
                                                  radius: 25,
                                                  backgroundImage:
                                                      photoURL != null
                                                      ? NetworkImage(photoURL)
                                                      : null,
                                                  backgroundColor:
                                                      Colors.blue.shade100,
                                                  child: photoURL == null
                                                      ? Text(
                                                          username
                                                              .substring(0, 1)
                                                              .toUpperCase(),
                                                          style: TextStyle(
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors
                                                                .blue[800],
                                                          ),
                                                        )
                                                      : null,
                                                ),
                                                if (isOnline)
                                                  Positioned(
                                                    bottom: 0,
                                                    right: 0,
                                                    child: Container(
                                                      width: 14,
                                                      height: 14,
                                                      decoration: BoxDecoration(
                                                        color: Colors.green,
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                          color: Colors.white,
                                                          width: 2,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    username,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  Text(
                                                    email,
                                                    style: TextStyle(
                                                      color: Colors.grey[600],
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                  if (userType.isNotEmpty)
                                                    Text(
                                                      'Loại người dùng: $userType',
                                                      style: TextStyle(
                                                        color: Colors.grey[600],
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  if (isOnline)
                                                    Row(
                                                      children: [
                                                        Container(
                                                          width: 6,
                                                          height: 6,
                                                          decoration:
                                                              BoxDecoration(
                                                                color: Colors
                                                                    .green,
                                                                shape: BoxShape
                                                                    .circle,
                                                              ),
                                                        ),
                                                        SizedBox(width: 4),
                                                        Text(
                                                          "Đang hoạt động",
                                                          style: TextStyle(
                                                            color: Colors.green,
                                                            fontSize: 11,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 12),
                                        Center(
                                          child: GestureDetector(
                                            onTap: canChat
                                                ? () {
                                                    Navigator.pop(context);
                                                    _showUserFoundDialog(
                                                      context,
                                                      email,
                                                      userData['uid'] ?? '',
                                                      userData,
                                                    );
                                                  }
                                                : null,
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 8,
                                              ),
                                              decoration: BoxDecoration(
                                                gradient: canChat
                                                    ? LinearGradient(
                                                        colors: [
                                                          Colors.blue,
                                                          Colors.blue.shade600,
                                                        ],
                                                      )
                                                    : LinearGradient(
                                                        colors: [
                                                          Colors.grey,
                                                          Colors.grey.shade600,
                                                        ],
                                                      ),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color:
                                                        (canChat
                                                                ? Colors.blue
                                                                : Colors.grey)
                                                            .withOpacity(0.3),
                                                    spreadRadius: 1,
                                                    blurRadius: 4,
                                                    offset: Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: Text(
                                                canChat
                                                    ? "Nhắn tin"
                                                    : "Không thể nhắn tin",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[600],
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: Text(
                "Đóng",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Thực hiện tìm kiếm với debounce
  static Timer? _searchTimer;
  static Future<void> _performSearch(
    String searchText,
    ValueNotifier<bool> isSearching,
    ValueNotifier<List<Map<String, dynamic>>> searchResults,
    ValueNotifier<String> errorMessage,
  ) async {
    _searchTimer?.cancel();

    _searchTimer = Timer(Duration(milliseconds: 500), () async {
      if (searchText.trim().isEmpty) return;

      try {
        isSearching.value = true;
        errorMessage.value = '';

        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser == null) {
          errorMessage.value = "Vui lòng đăng nhập để tìm kiếm";
          return;
        }

        List<QueryDocumentSnapshot> allFoundUsers = [];

        // 1. Tìm kiếm theo EMAIL chính xác
        if (searchText.contains('@')) {
          final emailQuery = await FirebaseFirestore.instance
              .collection('Users')
              .where('email', isEqualTo: searchText.toLowerCase())
              .limit(5)
              .get();

          allFoundUsers.addAll(emailQuery.docs);
          print("Tìm theo email: ${emailQuery.docs.length} kết quả");
        }

        // 2. Tìm kiếm theo USERNAME (nếu có trường này)
        try {
          final usernameQuery = await FirebaseFirestore.instance
              .collection('Users')
              .where(
                'username',
                isGreaterThanOrEqualTo: searchText.toLowerCase(),
              )
              .where(
                'username',
                isLessThanOrEqualTo: '${searchText.toLowerCase()}\uf8ff',
              )
              .limit(10)
              .get();

          for (var doc in usernameQuery.docs) {
            if (!allFoundUsers.any((existing) => existing.id == doc.id)) {
              allFoundUsers.add(doc);
            }
          }
          print("Tìm theo username: ${usernameQuery.docs.length} kết quả");
        } catch (e) {
          print("Không thể tìm theo username: $e");
        }

        // 3. Tìm kiếm theo EMAIL PREFIX
        if (!searchText.contains('@')) {
          try {
            final emailPrefixQuery = await FirebaseFirestore.instance
                .collection('Users')
                .where(
                  'email',
                  isGreaterThanOrEqualTo: searchText.toLowerCase(),
                )
                .where(
                  'email',
                  isLessThanOrEqualTo: '${searchText.toLowerCase()}\uf8ff',
                )
                .limit(10)
                .get();

            for (var doc in emailPrefixQuery.docs) {
              if (!allFoundUsers.any((existing) => existing.id == doc.id)) {
                allFoundUsers.add(doc);
              }
            }
            print(
              "Tìm theo email prefix: ${emailPrefixQuery.docs.length} kết quả",
            );
          } catch (e) {
            print("Không thể tìm theo email prefix: $e");
          }
        }

        print("Tổng cộng tìm thấy: ${allFoundUsers.length} user(s)");

        if (allFoundUsers.isEmpty) {
          errorMessage.value =
              "Không tìm thấy người dùng với từ khóa: '$searchText'";
          searchResults.value = [];
          return;
        }

        // Filter out current user và format data
        final filteredUsers = allFoundUsers
            .where((doc) {
              final userData = doc.data() as Map<String, dynamic>;
              final userEmail = userData['email'] as String?;
              print(
                "Checking user: $userEmail vs current: ${currentUser.email}",
              );
              return userEmail != null && userEmail != currentUser.email;
            })
            .map((doc) {
              final userData = doc.data() as Map<String, dynamic>;
              final email = userData['email'] as String;

              return {
                'email': email,
                'username':
                    userData['username'] as String? ?? email.split('@').first,
                'photoURL': userData['photoURL'] as String?,
                'isOnline': userData['isOnline'] as bool? ?? false,
                'lastSeen': userData['lastSeen'] as Timestamp?,
                'uid': doc.id,
                'userType': userData['userType'] as String? ?? '',
              };
            })
            .toList();

        print("Sau khi filter: ${filteredUsers.length} user(s)");

        if (filteredUsers.isEmpty) {
          errorMessage.value = "Không thể nhắn tin với chính mình";
          searchResults.value = [];
        } else {
          searchResults.value = filteredUsers;
          print("Hiển thị ${filteredUsers.length} kết quả");
        }
      } catch (e) {
        print("Lỗi tìm kiếm: $e");
        errorMessage.value = getFriendlyErrorMessage(e);
        searchResults.value = [];
      } finally {
        isSearching.value = false;
      }
    });
  }

  // Dialog hiển thị kết quả tìm thấy người dùng
  static void _showUserFoundDialog(
    BuildContext context,
    String email,
    String userId,
    Map<String, dynamic> userData,
  ) {
    final username = userData['username'] as String? ?? email.split('@').first;
    final photoURL = userData['photoURL'] as String?;
    final isOnline = userData['isOnline'] as bool? ?? false;
    final userType = userData['userType'] as String? ?? '';
    final canChat = userType == 'deaf';

    String lastSeenText = "";

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        contentPadding: EdgeInsets.zero,
        content: Container(
          width: 300,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.blue.shade50, Colors.white],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.3),
                                spreadRadius: 5,
                                blurRadius: 15,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundImage: photoURL != null
                                ? NetworkImage(photoURL)
                                : null,
                            backgroundColor: Colors.blue.shade100,
                            child: photoURL == null
                                ? Text(
                                    username.substring(0, 1).toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue[800],
                                    ),
                                  )
                                : null,
                          ),
                        ),
                        if (isOnline)
                          Positioned(
                            bottom: 5,
                            right: 5,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Text(
                      username,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      email,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Loại người dùng: $userType',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    // Trạng thái online/offline
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isOnline
                            ? Colors.green.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isOnline
                              ? Colors.green.withOpacity(0.3)
                              : Colors.grey.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: isOnline ? Colors.green : Colors.grey,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 6),
                          Text(
                            isOnline ? "Đang hoạt động" : lastSeenText,
                            style: TextStyle(
                              color: isOnline
                                  ? Colors.green[700]
                                  : Colors.grey[700],
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Thông báo
              Container(
                margin: EdgeInsets.symmetric(horizontal: 24),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.blue.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      color: Colors.blue,
                      size: 24,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        canChat
                            ? "Bạn có muốn bắt đầu cuộc trò chuyện với $username?"
                            : "Bạn không thể nhắn tin với người dùng này vì họ không phải là người khiếm thính",
                        style: TextStyle(
                          fontSize: 14,
                          color: canChat ? Colors.blue[700] : Colors.red[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24),

              // Buttons
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey[600],
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                        child: Text(
                          "Hủy",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: canChat
                            ? () {
                                Navigator.pop(context);
                                _startConversation(context, email, userId);
                                _showMessage(
                                  context,
                                  "Đã bắt đầu cuộc trò chuyện với $username",
                                );
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: canChat ? Colors.blue : Colors.grey,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 3,
                          shadowColor: (canChat ? Colors.blue : Colors.grey)
                              .withOpacity(0.3),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.chat, size: 18),
                            SizedBox(width: 8),
                            Text(
                              "Trò chuyện",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Bắt đầu cuộc trò chuyện
  static void _startConversation(
    BuildContext context,
    String receiverEmail,
    String receiverId,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            Chatting(receiverEmail: receiverEmail, receiverID: receiverId),
      ),
    );
  }

  // Hiển thị thông báo
  static void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.only(bottom: 80.0),
      ),
    );
  }
}
