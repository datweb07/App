import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_nckh/services/authentication/auth_service.dart';
import 'package:demo_nckh/services/deaf/deaf_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';

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
  final DeafService deafService = DeafService();
  final AuthService authService = AuthService();
  final ImagePicker _imagePicker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  bool _isTyping = false;
  bool _showEmojiPicker = false;
  String _userStatus = "";
  String _receiverUserType = "";
  bool _canSendMessage = false;
  bool _isLoadingUserType = true;

  @override
  void initState() {
    super.initState();
    _getUserStatus();
    _checkReceiverUserType();
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
    final status = await deafService.getLastSeenTime(widget.receiverID);
    setState(() {
      _userStatus = status;
    });
  }

  void _checkReceiverUserType() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.receiverID)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        final userType = userData['userType'] ?? '';

        setState(() {
          _receiverUserType = userType;
          _canSendMessage = userType == 'deaf';
          _isLoadingUserType = false;
        });
      } else {
        setState(() {
          _canSendMessage = false;
          _isLoadingUserType = false;
        });
      }
    } catch (e) {
      setState(() {
        _canSendMessage = false;
        _isLoadingUserType = false;
      });
    }
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

  // Xử lý emoji
  void _onEmojiSelected(Emoji emoji) {
    final text = messageController.text;
    final selection = messageController.selection;

    // Ensure selection is valid
    if (selection.start < 0 || selection.end < 0) {
      messageController.text += emoji.emoji;
      messageController.selection = TextSelection.fromPosition(
        TextPosition(offset: text.length + emoji.emoji.length),
      );
      return;
    }
    // if (selection.start < 0) return;

    final newText = text.replaceRange(
      selection.start,
      selection.end,
      emoji.emoji,
    );

    messageController.text = newText;
    messageController.selection = TextSelection.fromPosition(
      TextPosition(offset: selection.start + emoji.emoji.length),
    );
  }

  void senMessage() async {
    if (!_canSendMessage) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Bạn chỉ có thể nhắn tin với người khiếm thính"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    String message = messageController.text.trim();

    // Nếu không có text, gửi emoji like
    if (message.isEmpty) {
      message = "👍"; // Emoji like
    }

    if (message.isNotEmpty) {
      messageController.clear();
      setState(() {
        _isTyping = false;
      });

      await deafService.sendMessage(widget.receiverID, message);

      // Mark messages as read when sending
      await deafService.markMessagesAsRead(
        authService.getCurrentUser()!.uid,
        widget.receiverID,
      );

      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollToBottom();
      });
    }
  }

  // Các phương thức xử lý camera và image
  Future<void> _getImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        await _sendImageMessage(image);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi chọn ảnh: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _sendImageMessage(XFile imageFile) async {
    try {
      // Hiển thị loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 16),
              Text('Đang gửi ảnh...'),
            ],
          ),
          duration: Duration(seconds: 3),
        ),
      );

      // Gửi ảnh qua service (cần implement trong DeafService)
      await deafService.sendImageMessage(widget.receiverID, imageFile.path);

      // Mark messages as read
      await deafService.markMessagesAsRead(
        authService.getCurrentUser()!.uid,
        widget.receiverID,
      );

      // Scroll to bottom
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollToBottom();
      });

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã gửi ảnh thành công'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi gửi ảnh: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Chọn tài liệu
  Future<void> _pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
    );

    if (result != null && result.files.single.path != null) {
      final filePath = result.files.single.path!;
      print("Tài liệu đã chọn: $filePath");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: Column(
        children: [
          if (_isLoadingUserType)
            Container(
              padding: EdgeInsets.all(8),
              color: Colors.orange[100],
              child: Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text("Đang kiểm tra quyền truy cập..."),
                ],
              ),
            ),
          if (!_isLoadingUserType && !_canSendMessage)
            Container(
              padding: EdgeInsets.all(12),
              color: Colors.red[100],
              child: Row(
                children: [
                  Icon(Icons.block, color: Colors.red),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Bạn chỉ có thể nhắn tin với người dùng khiếm thính",
                      style: TextStyle(color: Colors.red[800]),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(child: messageList()),
          _buildMessageInput(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: Size.fromHeight(kToolbarHeight + 16),
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
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.blue),
                    onPressed: () => Navigator.pop(context),
                    constraints: BoxConstraints(minWidth: 40),
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
                        Row(
                          children: [
                            Text(
                              widget.receiverEmail.split('@').first,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            if (_receiverUserType == 'deaf')
                              Container(
                                margin: EdgeInsets.only(left: 8),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Khiếm thính',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
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
                  if (_canSendMessage) ...[
                    IconButton(
                      icon: Icon(Icons.videocam, color: Colors.blue),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Tính năng video call đang phát triển",
                            ),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.call, color: Colors.blue),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Tính năng gọi điện đang phát triển"),
                          ),
                        );
                      },
                    ),
                  ],
                  IconButton(
                    icon: Icon(Icons.info_outline, color: Colors.blue),
                    onPressed: _showUserInfo,
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
    if (!_canSendMessage && !_isLoadingUserType) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.block, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(
              "Không thể xem tin nhắn",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "Bạn chỉ có thể nhắn tin với người dùng khiếm thính",
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    String senderID = authService.getCurrentUser()!.uid;
    return StreamBuilder(
      stream: deafService.getMessages(widget.receiverID, senderID),
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
          deafService.markMessagesAsRead(senderID, widget.receiverID);
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
    String messageType = data['messageType'] ?? 'text';

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
                  padding: EdgeInsets.symmetric(
                    horizontal: messageType == 'image' ? 4 : 16,
                    vertical: messageType == 'image' ? 4 : 12,
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
                      // Hiển thị nội dung tin nhắn
                      if (messageType == 'image')
                        _buildImageMessage(data["message"])
                      else
                        Text(
                          data["message"],
                          style: TextStyle(
                            color: isCurrentUser
                                ? Colors.white
                                : Colors.black87,
                            fontSize: 16,
                            height: 1.4,
                          ),
                        ),
                      const SizedBox(height: 4),

                      // TimeStamp
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

  // Xây dựng việc hiển thị ảnh
  Widget _buildImageMessage(String imageUrl) {
    return GestureDetector(
      onTap: () {
        // Hiển thị ảnh full screen
        showDialog(
          context: context,
          builder: (context) => Dialog(
            backgroundColor: Colors.black,
            child: Stack(
              children: [
                Center(
                  child: InteractiveViewer(
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.error, color: Colors.red, size: 48),
                              SizedBox(height: 8),
                              Text(
                                'Không thể tải ảnh',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Positioned(
                  top: 40,
                  right: 20,
                  child: IconButton(
                    icon: Icon(Icons.close, color: Colors.white, size: 30),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          imageUrl,
          width: 200,
          height: 200,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return SizedBox(
              width: 200,
              height: 200,
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 200,
              height: 200,
              color: Colors.grey[300],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, color: Colors.red),
                  SizedBox(height: 4),
                  Text('Lỗi tải ảnh', style: TextStyle(fontSize: 12)),
                ],
              ),
            );
          },
        ),
      ),
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
    return Column(
      children: [
        // Emoji picker
        if (_showEmojiPicker)
          SizedBox(
            height: 250,
            child: EmojiPicker(
              onEmojiSelected: (Category? category, Emoji emoji) {
                _onEmojiSelected(emoji);
              },
              config: Config(
                height: 250,
                checkPlatformCompatibility: true,
                emojiViewConfig: EmojiViewConfig(
                  columns: 7,
                  emojiSizeMax: 32.0,
                  verticalSpacing: 0,
                  horizontalSpacing: 0,
                  gridPadding: EdgeInsets.zero,
                  buttonMode: ButtonMode.MATERIAL,
                ),
              ),
            ),
          ),
        Container(
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
                // Add button
                IconButton(
                  icon: Icon(Icons.add, color: Colors.blue),
                  onPressed: () {
                    _showAttachmentOptions();
                  },
                ),

                // Text input
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: _canSendMessage
                          ? Colors.grey[100]
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: messageController,
                            focusNode: _focusNode,
                            enabled: _canSendMessage,
                            maxLines: 5,
                            minLines: 1,
                            decoration: InputDecoration(
                              hintText: _canSendMessage
                                  ? "Nhắn tin..."
                                  : "Không thể nhắn tin...",
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                            ),
                            textCapitalization: TextCapitalization.sentences,
                            onTap: () {
                              // Ẩn emoji picker khi nhấn vào ô nhập
                              if (_showEmojiPicker) {
                                setState(() {
                                  _showEmojiPicker = false;
                                });
                              }
                            },
                          ),
                        ),

                        // Emoji button
                        IconButton(
                          icon: Icon(
                            _showEmojiPicker
                                ? Icons.keyboard
                                : Icons.emoji_emotions_outlined,
                          ),
                          color: _canSendMessage
                              ? (_showEmojiPicker
                                    ? Colors.blue
                                    : Colors.grey[600])
                              : Colors.grey[400],
                          onPressed: _canSendMessage
                              ? () {
                                  setState(() {
                                    _showEmojiPicker = !_showEmojiPicker;
                                  });

                                  // Ẩn hiện keyboard khi nhấn vào emoji
                                  if (_showEmojiPicker) {
                                    _focusNode.unfocus();
                                  } else {
                                    _focusNode.requestFocus();
                                  }
                                }
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(width: 8),

                // Send button or Like button
                GestureDetector(
                  onTap: _canSendMessage ? senMessage : null,
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _isTyping
                          ? Colors.white
                          : (_canSendMessage ? Colors.white : Colors.grey[400]),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isTyping ? Icons.send : Icons.thumb_up,
                      color: Colors.blue, // Luôn màu trắng bên trong
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              'Chọn tệp đính kèm',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 3,
              padding: const EdgeInsets.all(20),
              children: [
                _buildAttachmentOption(
                  Icons.photo_library,
                  'Thư viện ảnh',
                  Colors.purple,
                  () {
                    Navigator.pop(context);
                    _getImage(ImageSource.gallery);
                  },
                ),
                _buildAttachmentOption(
                  Icons.camera_alt,
                  'Máy ảnh',
                  Colors.red,
                  () {
                    Navigator.pop(context);
                    _getImage(ImageSource.camera);
                  },
                ),
                _buildAttachmentOption(
                  Icons.insert_drive_file,
                  'Tài liệu',
                  Colors.blue,
                  () {
                    Navigator.pop(context);
                    _pickDocument();
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentOption(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return Semantics(
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  
  void _showUserInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(16),
        ),
        title: Text('Thông tin người dùng', textAlign: TextAlign.center),
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
            if (_receiverUserType.isNotEmpty) ...[
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _receiverUserType == 'deaf'
                      ? Colors.blue
                      : Colors.grey,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _receiverUserType == 'deaf' ? 'Khiếm thính' : 'Khiếm thị',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
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
}
