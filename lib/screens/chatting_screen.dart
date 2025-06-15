import 'package:demo_nckh/components/drawer.dart';
import 'package:demo_nckh/screens/chatting.dart';
import 'package:demo_nckh/services/authentication/auth_service.dart';
import 'package:demo_nckh/services/chatting/chatting_service.dart';
import 'package:demo_nckh/services/search_friend_chatting.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChattingScreen extends StatefulWidget {
  const ChattingScreen({super.key});

  @override
  State<ChattingScreen> createState() => _ChattingScreenState();
}

class _ChattingScreenState extends State<ChattingScreen> {
  final ChattingService chattingService = ChattingService();
  final AuthService authService = AuthService();

  String searchQuery = "";
  final TextEditingController searchController = TextEditingController();
  bool isSearching = false;

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
                              user?.email?.split('@').first ?? "Không có tên",
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
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => Navigator.pop(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0084FF),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
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
          onPressed: () => SearchFriend.showAddFriendDialog(context),
          backgroundColor: Colors.blue,
          child: Icon(Icons.person_search),
        ),
      ),
      body: conversationList(),
    );
  }

  Widget conversationList() {
    return StreamBuilder(
      stream: chattingService.getConversationsStream(),
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

        final filteredConversations = snapshot.data!.where((conversation) {
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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Chatting(
                receiverEmail: conversationData["email"],
                receiverID: conversationData["uid"],
              ),
            ),
          );
        },
      ),
    );
  }
}
