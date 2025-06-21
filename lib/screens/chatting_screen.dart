import 'package:demo_nckh/components/drawer.dart';
import 'package:demo_nckh/screens/chatting.dart';
import 'package:demo_nckh/services/authentication/auth_service.dart';
import 'package:demo_nckh/services/deaf/deaf_service.dart';
import 'package:demo_nckh/services/search_friend_chatting.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class ChattingScreen extends StatefulWidget {
  const ChattingScreen({super.key});

  @override
  State<ChattingScreen> createState() => _ChattingScreenState();
}

class _ChattingScreenState extends State<ChattingScreen> {
  final DeafService deafService = DeafService();
  final AuthService authService = AuthService();

  String searchQuery = "";
  final TextEditingController searchController = TextEditingController();
  bool isSearching = false;

  void _optionMessage(
    BuildContext context,
    String messageId,
    String currentUserID,
    String otherUserID,
    String otherName,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.6, // 60% chiều cao màn hình
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Tùy chọn cho cuộc trò chuyện với $otherName",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text("Xóa tin nhắn"),
                onTap: () async {
                  Navigator.pop(context);
                  _confirmDeleteMessage(messageId, otherUserID);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDeleteMessage(String messageId, String otherUserID) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(16),
        ),
        title: Text('Xóa tin nhắn'),
        content: Text('Bạn có chắc chắn muốn xóa tin nhắn này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              deafService.deleteMessage(
                messageId,
                authService.getCurrentUser()!.uid,
                otherUserID,
              );
            },
            child: Text(
              'Xóa',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
          child: AppBar(
            iconTheme: IconThemeData(color: Colors.white),
            backgroundColor: Colors.blue,
            title: isSearching
                ? TextField(
                    controller: searchController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: "Tìm kiếm cuộc trò chuyện...",
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Colors.white70),
                    ),
                    style: TextStyle(color: Colors.white),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value.toLowerCase();
                      });
                    },
                  )
                : const Text('Chatting', style: TextStyle(color: Colors.white)),
            actions: [
              IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  setState(() {
                    isSearching = !isSearching;
                    if (!isSearching) {
                      searchController.clear();
                      searchQuery = "";
                    }
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.account_circle, color: Colors.white),
                onPressed: () {
                  final user = FirebaseAuth.instance.currentUser;

                  // Get current user's userType from Firestore
                  FirebaseFirestore.instance
                      .collection('Users')
                      .doc(user?.uid)
                      .get()
                      .then((doc) {
                        String userType = "Không xác định";
                        if (doc.exists) {
                          userType =
                              doc.data()?['userType'] ?? "Không xác định";
                        }

                        showDialog(
                          context: context,
                          builder: (_) => Dialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Stack(
                                    children: [
                                      CircleAvatar(
                                        radius: 40,
                                        backgroundImage: user?.photoURL != null
                                            ? NetworkImage(user!.photoURL!)
                                            : null,
                                        child: user?.photoURL == null
                                            ? Icon(Icons.person, size: 40)
                                            : null,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    user?.email?.split('@').first ??
                                        "Không có tên",
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    user?.email ?? "Không có email",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(height: 8),
                                  // Display userType with styling
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: userType == "deaf"
                                          ? Colors.blue.withOpacity(0.1)
                                          : Colors.grey.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: userType == "deaf"
                                            ? Colors.blue
                                            : Colors.grey,
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          userType == "deaf"
                                              ? Icons.hearing_disabled
                                              : Icons.person,
                                          size: 16,
                                          color: userType == "deaf"
                                              ? Colors.blue
                                              : Colors.grey,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          userType == "deaf"
                                              ? "Khiếm thính"
                                              : userType == "normal"
                                              ? "Người bình thường"
                                              : "Không xác định",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: userType == "deaf"
                                                ? Colors.blue
                                                : Colors.grey,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () => Navigator.pop(context),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF0084FF,
                                        ),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      child: const Text(
                                        "Đóng",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      })
                      .catchError((error) {
                        // Handle error case
                        showDialog(
                          context: context,
                          builder: (_) => Dialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircleAvatar(
                                    radius: 40,
                                    backgroundImage: user?.photoURL != null
                                        ? NetworkImage(user!.photoURL!)
                                        : null,
                                    child: user?.photoURL == null
                                        ? Icon(Icons.person, size: 40)
                                        : null,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    user?.email?.split('@').first ??
                                        "Không có tên",
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    user?.email ?? "Không có email",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.red,
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.error,
                                          size: 16,
                                          color: Colors.red,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          "Không thể tải thông tin",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.red,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () => Navigator.pop(context),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF0084FF,
                                        ),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      child: const Text(
                                        "Đóng",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      });
                },
              ),
            ],
          ),
        ),
      ),
      drawer: MyDrawer(),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: FloatingActionButton(
          onPressed: () {
            SearchFriendChatting.showAddFriendDialog(context);
          },
          backgroundColor: Colors.blue,
          child: Icon(Icons.person_search),
        ),
      ),
      body: conversationList(),
    );
  }

  Widget conversationList() {
    return StreamBuilder(
      stream: deafService.getConversationsStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text("Có lỗi xảy ra", style: TextStyle(fontSize: 16)),
              ],
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text("Đang tải cuộc trò chuyện..."),
              ],
            ),
          );
        }

        if (snapshot.data == null || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  "Chưa có cuộc trò chuyện nào",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  "Nhấn nút + để kết bạn và bắt đầu trò chuyện",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        // Lọc cuộc trò chuyện: chỉ hiển thị những người có userType = "deaf"
        final filteredConversations = snapshot.data!.where((conversation) {
          // Kiểm tra userType trước
          final userType = conversation["userType"] ?? "";
          if (userType != "deaf") {
            return false; // Không hiển thị nếu không phải "deaf"
          }

          // Sau đó áp dụng bộ lọc tìm kiếm
          final email = conversation["email"]?.toLowerCase() ?? "";
          final lastMessage = conversation["lastMessage"]?.toLowerCase() ?? "";
          final name = email.split("@").first.toLowerCase();
          return name.contains(searchQuery) ||
              lastMessage.contains(searchQuery);
        }).toList();

        if (filteredConversations.isEmpty && searchQuery.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  "Không tìm thấy cuộc trò chuyện",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        if (filteredConversations.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.hearing_disabled, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  "Chưa có cuộc trò chuyện với người khiếm thính",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  "Nhấn nút + để kết bạn với người khiếm thính",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          itemCount: filteredConversations.length,
          separatorBuilder: (context, index) => Divider(
            height: 1,
            indent: 70,
            endIndent: 16,
            color: Colors.grey[200],
          ),
          itemBuilder: (context, index) {
            return conversationListItem(filteredConversations[index], context);
          },
        );
      },
    );
  }

  Widget conversationListItem(
    Map<String, dynamic> conversationData,
    BuildContext context,
  ) {
    final currentUserEmail = FirebaseAuth.instance.currentUser?.email;
    if (conversationData["email"] == currentUserEmail) {
      return const SizedBox.shrink();
    }

    // Kiểm tra userType - chỉ cho phép hiển thị nếu là "deaf"
    final userType = conversationData["userType"] ?? "";
    if (userType != "deaf") {
      return const SizedBox.shrink(); // Không hiển thị nếu không phải "deaf"
    }

    // Lấy thông tin tin nhắn cuối
    final lastMessage = conversationData["lastMessage"] ?? "";
    final lastMessageTime = conversationData["lastMessageTime"] as Timestamp?;
    final unreadCount = conversationData["unreadCount"] ?? 0;
    final isOnline = conversationData["isOnline"] ?? false;

    // Format thời gian
    String timeString = "";
    if (lastMessageTime != null) {
      final now = DateTime.now();
      final messageTime = lastMessageTime.toDate();
      final difference = now.difference(messageTime);
      if (difference.inDays > 365) {
        timeString = "${(difference.inDays / 365).floor()} năm trước";
      } else if (difference.inDays > 30) {
        timeString = "${(difference.inDays / 30).floor()} tháng trước";
      } else if (difference.inDays > 0) {
        timeString = "${difference.inDays} ngày trước";
      } else if (difference.inHours > 0) {
        timeString = "${difference.inHours} giờ trước";
      } else if (difference.inMinutes > 0) {
        timeString = "${difference.inMinutes} phút trước";
      } else {
        timeString = "Vừa xong";
      }
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundImage: conversationData["photoURL"] != null
                  ? NetworkImage(conversationData["photoURL"])
                  : null,
              child: conversationData["photoURL"] == null
                  ? Text(
                      conversationData["email"]
                              ?.substring(0, 1)
                              .toUpperCase() ??
                          "U",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            if (isOnline)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            // Thêm icon nhỏ để chỉ ra người dùng khiếm thính
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1),
                ),
                child: Icon(
                  Icons.hearing_disabled,
                  size: 12,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        title: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Text(
                    conversationData["email"]?.split("@").first ?? "Unknown",
                    style: TextStyle(
                      fontWeight: unreadCount > 0
                          ? FontWeight.bold
                          : FontWeight.w500,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(width: 4),
                  // Thêm nhãn "Khiếm thính" nhỏ
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "Khiếm thính",
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (timeString.isNotEmpty)
              Text(
                timeString,
                style: TextStyle(
                  color: unreadCount > 0 ? Colors.blue : Colors.grey,
                  fontSize: 12,
                  fontWeight: unreadCount > 0
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
          ],
        ),
        subtitle: Row(
          children: [
            Expanded(
              child: Text(
                lastMessage.isNotEmpty ? lastMessage : "Chưa có tin nhắn",
                style: TextStyle(
                  color: unreadCount > 0 ? Colors.black87 : Colors.grey,
                  fontWeight: unreadCount > 0
                      ? FontWeight.w500
                      : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            if (unreadCount > 0)
              Container(
                margin: EdgeInsets.only(left: 8),
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  unreadCount > 99 ? "99+" : unreadCount.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        onTap: () {
          // Kiểm tra một lần nữa trước khi chuyển trang
          if (userType == "deaf") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Chatting(
                  receiverEmail: conversationData["email"],
                  receiverID: conversationData["uid"],
                ),
              ),
            );
          } else {
            // Hiển thị thông báo nếu cố gắng nhắn tin với người không phải "deaf"
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Bạn chỉ có thể nhắn tin với người khiếm thính"),
                backgroundColor: Colors.red,
              ),
            );
          }
        },

        onLongPress: () {
          HapticFeedback.heavyImpact();
          _optionMessage(
            context,
            conversationData["lastMessageId"] ?? "",
            authService.getCurrentUser()!.uid,
            conversationData["uid"] ?? "",
            conversationData["email"]?.split("@").first ?? "Unknown",
          );
        },
      ),
    );
  }
}
