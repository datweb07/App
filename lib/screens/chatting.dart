// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:demo_nckh/components/chat_bubble.dart';
// import 'package:demo_nckh/components/textfield.dart';
// import 'package:demo_nckh/services/authentication/auth_service.dart';
// import 'package:demo_nckh/services/authentication/chatting/chatting_service.dart';
// import 'package:flutter/material.dart';

// class Chatting extends StatefulWidget {
//   final String receiverEmail;
//   final String receiverID;
//   const Chatting({
//     super.key,
//     required this.receiverEmail,
//     required this.receiverID,
//   });

//   @override
//   State<Chatting> createState() => _ChattingState();
// }

// class _ChattingState extends State<Chatting> {
//   // Text controller
//   final TextEditingController messageController = TextEditingController();
//   final ScrollController _scrollController = ScrollController(); // NEW
//   // Chatting and authentication services
//   final ChattingService chattingService = ChattingService();
//   final AuthService authService = AuthService();

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     super.dispose();
//   }

//   // Send message
//   void senMessage() async {
//     if (messageController.text.isNotEmpty) {
//       // Send message
//       await chattingService.senMessage(
//         widget.receiverID,
//         messageController.text,
//       );

//       // Clear message
//       messageController.clear();
//       // Delay để đợi message render xong, rồi mới scroll
//       Future.delayed(const Duration(milliseconds: 100), () {
//         if (_scrollController.hasClients) {
//           _scrollController.animateTo(
//             _scrollController.position.maxScrollExtent,
//             duration: const Duration(milliseconds: 300),
//             curve: Curves.easeOut,
//           );
//         }
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: PreferredSize(
//         preferredSize: const Size.fromHeight(kToolbarHeight),
//         child: ClipRRect(
//           borderRadius: const BorderRadius.only(
//             bottomLeft: Radius.circular(30),
//             bottomRight: Radius.circular(30),
//           ),
//           child: AppBar(
//             title: Text(widget.receiverEmail),
//             iconTheme: IconThemeData(color: Colors.white),
//           ),
//         ),
//       ),
//       body: Column(
//         children: [
//           // Display all message
//           Expanded(child: messageList()),

//           // User input
//           messageInput(),
//         ],
//       ),
//     );
//   }

//   // Message List
//   Widget messageList() {
//     String senderID = authService.getCurrentUser()!.uid;
//     return StreamBuilder(
//       stream: chattingService.getMessage(widget.receiverID, senderID),
//       builder: (context, snapshot) {
//         // Display some errors
//         if (snapshot.hasError) {
//           return const Text("Error");
//         }

//         // Loading
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Text("Loading...");
//         }

//         // List view
//         return ListView(
//           children: snapshot.data!.docs.map((doc) => messageItem(doc)).toList(),
//         );
//       },
//     );
//   }

//   // Message Item
//   Widget messageItem(DocumentSnapshot doc) {
//     Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

//     // Current user
//     bool isCurrentUser = data['senderID'] == authService.getCurrentUser()!.uid;

//     // align message to the right if sender is current user, otherwise left
//     var alignment = isCurrentUser
//         ? Alignment.centerRight
//         : Alignment.centerLeft;
//     return Container(
//       alignment: alignment,
//       child: Column(
//         crossAxisAlignment: isCurrentUser
//             ? CrossAxisAlignment.end
//             : CrossAxisAlignment.start,
//         children: [
//           ChatBubble(message: data["message"], isCurrentUser: isCurrentUser),
//         ],
//       ),
//     );
//   }

//   // Message input
//   Widget messageInput() {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 50.0),
//       child: Row(
//         children: [
//           Expanded(
//             child: Textfield(
//               hinText: "Type a message",
//               obscureText: false,
//               controller: messageController,
//             ),
//           ),

//           // Send button
//           Container(
//             decoration: const BoxDecoration(
//               color: Colors.green,
//               shape: BoxShape.circle,
//             ),
//             margin: const EdgeInsets.only(right: 25),
//             child: IconButton(
//               onPressed: senMessage,
//               icon: const Icon(Icons.arrow_upward),
//               color: Colors.white,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_nckh/services/authentication/auth_service.dart';
import 'package:demo_nckh/services/chatting/chatting_service.dart';
import 'package:flutter/material.dart';

class Chatting extends StatefulWidget {
  final String receiverEmail;
  final String receiverID;
  const Chatting({
    super.key,
    required this.receiverEmail,
    required this.receiverID,
  });

  @override
  State<Chatting> createState() => _ChattingState();
}

class _ChattingState extends State<Chatting> with TickerProviderStateMixin {
  final TextEditingController messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  final ChattingService chattingService = ChattingService();
  final AuthService authService = AuthService();

  bool _isTyping = false;
  bool _showEmojiPicker = false;
  String _userStatus = "";

  @override
  void initState() {
    super.initState();
    _getUserStatus();
    messageController.addListener(_onTypingChanged);

    // Auto scroll to bottom when keyboard appears
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        Future.delayed(Duration(milliseconds: 300), () {
          _scrollToBottom();
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    messageController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTypingChanged() {
    final isTyping = messageController.text.isNotEmpty;
    if (isTyping != _isTyping) {
      setState(() {
        _isTyping = isTyping;
      });
    }
  }

  void _getUserStatus() async {
    final status = await chattingService.getLastSeenTime(widget.receiverID);
    setState(() {
      _userStatus = status;
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void senMessage() async {
    if (messageController.text.trim().isNotEmpty) {
      final message = messageController.text.trim();
      messageController.clear();

      await chattingService.senMessage(widget.receiverID, message);

      // // Mark messages as read when sending
      await chattingService.markMessagesAsRead(
        authService.getCurrentUser()!.uid,
        widget.receiverID,
      );

      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollToBottom();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(child: messageList()),
          _buildMessageInput(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      // preferredSize: const Size.fromHeight(70),
      preferredSize: Size.fromHeight(kToolbarHeight),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.blue),
                    onPressed: () => Navigator.pop(context),
                  ),
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.blue,
                    child: Text(
                      widget.receiverEmail.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.receiverEmail.split('@').first,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          _userStatus,
                          style: TextStyle(
                            fontSize: 12,
                            color: _userStatus.contains("Đang hoạt động")
                                ? Colors.green
                                : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.videocam, color: Colors.blue),
                    onPressed: () {
                      // Video call feature
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Tính năng video call đang phát triển"),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.call, color: Colors.blue),
                    onPressed: () {
                      // Voice call feature
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Tính năng gọi điện đang phát triển"),
                        ),
                      );
                    },
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.info_outline, color: Colors.blue),
                    onSelected: (value) {
                      switch (value) {
                        case 'info':
                          _showUserInfo();
                          break;
                        case 'search':
                          _showSearchInChat();
                          break;
                        case 'clear':
                          _showClearChatDialog();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(value: 'info', child: Text('Thông tin')),
                      PopupMenuItem(value: 'search', child: Text('Tìm kiếm')),
                      PopupMenuItem(
                        value: 'clear',
                        child: Text('Xóa cuộc trò chuyện'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget messageList() {
    String senderID = authService.getCurrentUser()!.uid;
    return StreamBuilder(
      stream: chattingService.getMessage(widget.receiverID, senderID),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red),
                SizedBox(height: 16),
                Text("Có lỗi xảy ra khi tải tin nhắn"),
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
                Text("Đang tải tin nhắn..."),
              ],
            ),
          );
        }

        if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  "Chưa có tin nhắn nào",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  "Hãy gửi tin nhắn đầu tiên!",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        // Mark messages as read when viewing
        WidgetsBinding.instance.addPostFrameCallback((_) {
          chattingService.markMessagesAsRead(senderID, widget.receiverID);
        });

        return ListView.builder(
          controller: _scrollController,
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final isLast = index == snapshot.data!.docs.length - 1;

            // Auto scroll to bottom for new messages
            if (isLast) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _scrollToBottom();
              });
            }

            return _buildMessageItem(doc, index, snapshot.data!.docs);
          },
        );
      },
    );
  }

  Widget _buildMessageItem(
    DocumentSnapshot doc,
    int index,
    List<DocumentSnapshot> allDocs,
  ) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    bool isCurrentUser = data['senderID'] == authService.getCurrentUser()!.uid;

    // Check if we need to show timestamp
    bool showTime = false;
    if (index == 0) {
      showTime = true;
    } else {
      final prevData = allDocs[index - 1].data() as Map<String, dynamic>;
      final currentTime = (data['timestamp'] as Timestamp).toDate();
      final prevTime = (prevData['timestamp'] as Timestamp).toDate();

      // Show time if more than 5 minutes difference
      if (currentTime.difference(prevTime).inMinutes > 5) {
        showTime = true;
      }
    }

    // Check if messages are consecutive from same sender
    bool showAvatar = true;
    bool isConsecutive = false;

    String formatTime(DateTime time) {
      return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
    }

    if (index < allDocs.length - 1) {
      final nextData = allDocs[index + 1].data() as Map<String, dynamic>;
      if (nextData['senderID'] == data['senderID']) {
        showAvatar = false;
        isConsecutive = true;
      }
    }

    return Column(
      children: [
        if (showTime) _buildTimeStamp(data['timestamp'] as Timestamp),
        Container(
          margin: EdgeInsets.only(
            top: isConsecutive ? 2 : 8,
            bottom: 2,
            left: isCurrentUser ? 50 : 0,
            right: isCurrentUser ? 0 : 50,
          ),
          child: Row(
            mainAxisAlignment: isCurrentUser
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isCurrentUser && showAvatar)
                CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.grey[300],
                  child: Text(
                    widget.receiverEmail.substring(0, 1).toUpperCase(),
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                )
              else if (!isCurrentUser)
                SizedBox(width: 24),

              SizedBox(width: 8),

              Flexible(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  margin: EdgeInsets.only(
                    left: isCurrentUser ? 40 : 0,
                    right: isCurrentUser ? 0 : 40,
                    bottom: 4,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: isCurrentUser
                        ? LinearGradient(
                            colors: [Colors.blue[600]!, Colors.blue[500]!],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: isCurrentUser ? null : Colors.grey[200],
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(isCurrentUser ? 20 : 4),
                      bottomRight: Radius.circular(isCurrentUser ? 4 : 20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: isCurrentUser
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Text(
                        data["message"],
                        style: TextStyle(
                          color: isCurrentUser ? Colors.white : Colors.black87,
                          fontSize: 16,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatTime((data['timestamp'] as Timestamp).toDate()),
                        style: TextStyle(
                          color: isCurrentUser
                              ? Colors.white70
                              : Colors.grey[600],
                          fontSize: 11,
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
    );
  }

  Widget _buildTimeStamp(Timestamp timestamp) {
    final time = timestamp.toDate();
    final now = DateTime.now();
    String timeString;

    if (now.difference(time).inDays == 0) {
      timeString =
          "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
    } else if (now.difference(time).inDays == 1) {
      timeString =
          "Hôm qua ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
    } else {
      timeString = "${time.day}/${time.month}/${time.year}";
    }

    return Container(
      margin: EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            timeString,
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: SafeArea(
        child: Row(
          children: [
            // Camera button
            IconButton(
              icon: Icon(Icons.camera_alt, color: Colors.blue),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Tính năng camera đang phát triển")),
                );
              },
            ),

            // Text input
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: messageController,
                        focusNode: _focusNode,
                        maxLines: 5,
                        minLines: 1,
                        decoration: InputDecoration(
                          hintText: "Nhắn tin...",
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        ),
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ),

                    // Emoji button
                    IconButton(
                      icon: Icon(
                        Icons.emoji_emotions_outlined,
                        color: Colors.grey[600],
                      ),
                      onPressed: () {
                        setState(() {
                          _showEmojiPicker = !_showEmojiPicker;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(width: 8),

            // Send button
            GestureDetector(
              onTap: senMessage,
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _isTyping ? Colors.blue : Colors.grey[300],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isTyping ? Icons.send : Icons.thumb_up,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMessageOptions(
    String messageId,
    String message,
    bool isCurrentUser,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.copy),
              title: Text('Sao chép'),
              onTap: () {
                Navigator.pop(context);
                // Copy to clipboard
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text("Đã sao chép tin nhắn")));
              },
            ),
            if (isCurrentUser)
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text(
                  'Xóa tin nhắn',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDeleteMessage(messageId);
                },
              ),
            ListTile(
              leading: Icon(Icons.reply),
              title: Text('Trả lời'),
              onTap: () {
                Navigator.pop(context);
                // Reply functionality
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteMessage(String messageId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xóa tin nhắn'),
        content: Text('Bạn có chắc chắn muốn xóa tin nhắn này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              chattingService.deleteMessage(
                messageId,
                authService.getCurrentUser()!.uid,
                widget.receiverID,
              );
            },
            child: Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showUserInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Thông tin người dùng'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.blue,
              child: Text(
                widget.receiverEmail.substring(0, 1).toUpperCase(),
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            SizedBox(height: 16),
            Text(widget.receiverEmail, style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text(_userStatus, style: TextStyle(color: Colors.grey)),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0084FF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Đóng",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showSearchInChat() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Tính năng tìm kiếm trong chat đang phát triển")),
    );
  }

  void _showClearChatDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xóa cuộc trò chuyện'),
        content: Text('Bạn có chắc chắn muốn xóa toàn bộ cuộc trò chuyện này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Clear chat functionality
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "Tính năng xóa cuộc trò chuyện đang phát triển",
                  ),
                ),
              );
            },
            child: Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
