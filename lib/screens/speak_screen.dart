// import 'dart:async';
// import 'package:demo_nckh/components/drawer.dart';
// import 'package:demo_nckh/components/user_tile.dart';
// import 'package:demo_nckh/screens/speaking.dart';
// import 'package:demo_nckh/services/authentication/auth_service.dart';
// import 'package:demo_nckh/services/authentication/speaking/speaking_service.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_tts/flutter_tts.dart';
// import 'package:demo_nckh/services/authentication/speaking/voice_controller.dart';

// class SpeakScreen extends StatefulWidget {
//   const SpeakScreen({super.key});

//   @override
//   State<SpeakScreen> createState() => _SpeakScreenState();
// }

// class _SpeakScreenState extends State<SpeakScreen> {
//   final SpeakingService speakingService = SpeakingService();
//   final AuthService authService = AuthService();
//   final FlutterTts flutterTts = FlutterTts();
//   final VoiceController voiceController = VoiceController();
//   Future<void> _speakUserName() async {
//     final user = FirebaseAuth.instance.currentUser;

//     if (user != null && user.email != null) {
//       final name = user.email!.split('@').first;
//       await flutterTts.speak("Tài khoản của bạn là $name");
//     } else {
//       await flutterTts.speak("Không tìm thấy thông tin người dùng");
//     }
//   }

//   String searchQuery = "";
//   final TextEditingController searchController = TextEditingController();
//   bool isSearching = false;
//   String? _lastCommand;
//   @override
//   void initState() {
//     super.initState();
//     _initializeVoiceControl();
//   }

//   void _initializeVoiceControl() async {
//     await voiceController.initSpeech();
//     await voiceController.startListening(_handleVoiceCommand);
//   }

//   void _handleVoiceCommand(String command) async {
//     // command = command.toLowerCase().trim();
//     // await flutterTts.awaitSpeakCompletion(true); // Đợi TTS nói xong
//     if (_lastCommand == command) {
//       print("Lệnh '$command' đã được thực hiện trước đó, bỏ qua");
//       return;
//     }
//     if (command.contains("tìm kiếm")) {
//       setState(() {
//         isSearching = true;
//       });
//       await flutterTts.speak("Bạn đã bật chế độ tìm kiếm");
//     } else if (command.contains("thoát") || command.contains("đóng ứng dụng")) {
//       await flutterTts.speak("Đang thoát ứng dụng");
//       SystemNavigator.pop();
//     } else if (command.contains("tạo đoạn chat") ||
//         command.contains("chat mới")) {
//       setState(() {
//         isSearching = true;
//       });
//       await flutterTts.speak("Bạn đang tạo đoạn chat mới");
//     } else if (command.contains("tắt micro") ||
//         command.contains("tắt lắng nghe")) {
//       await flutterTts.speak("Đã tắt micro, không lắng nghe nữa");
//       await voiceController.stopListening();
//     }
//     // else {
//     //   await flutterTts.speak("Không hiểu lệnh: $command");
//     // }
//     // 🔁 Sau khi thực hiện lệnh và TTS xong, tiếp tục lắng nghe nếu không tắt
//     // await voiceController.startListening(_handleVoiceCommand);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: PreferredSize(
//         preferredSize: const Size.fromHeight(kToolbarHeight),
//         child: ClipRRect(
//           borderRadius: const BorderRadius.only(
//             bottomLeft: Radius.circular(30),
//             bottomRight: Radius.circular(30),
//           ),
//           child: AppBar(
//             iconTheme: const IconThemeData(color: Colors.white),
//             backgroundColor: Colors.black,
//             title: isSearching
//                 ? TextField(
//                     controller: searchController,
//                     autofocus: true,
//                     decoration: const InputDecoration(
//                       hintText: "Tìm kiếm tên...",
//                       border: InputBorder.none,
//                       hintStyle: TextStyle(color: Colors.white70),
//                     ),
//                     style: const TextStyle(color: Colors.white, fontSize: 20),
//                     onChanged: (value) {
//                       setState(() {
//                         searchQuery = value.toLowerCase();
//                       });
//                     },
//                   )
//                 : const Text(
//                     'Giao diện nhắn tin',
//                     style: TextStyle(fontSize: 24, color: Colors.white),
//                   ),
//             actions: [
//               Tooltip(
//                 message: "Tìm người để nhắn tin",
//                 child: IconButton(
//                   icon: const Icon(Icons.search, color: Colors.white),
//                   onPressed: () {
//                     setState(() {
//                       isSearching = !isSearching;
//                       if (!isSearching) {
//                         searchController.clear();
//                         searchQuery = "";
//                       }
//                     });
//                   },
//                 ),
//               ),
//               Tooltip(
//                 message: "Thông tin người dùng",
//                 child: IconButton(
//                   icon: const Icon(Icons.more_vert, color: Colors.white),
//                   onPressed: () async {
//                     await flutterTts.awaitSpeakCompletion(true);
//                     await flutterTts.speak("Thông tin người dùng");
//                     await flutterTts.awaitSpeakCompletion(true);
//                     _speakUserName();
//                     _showUserInfoDialog(context);
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//       drawer: const MyDrawer(),
//       floatingActionButton: Padding(
//         padding: const EdgeInsets.only(bottom: 10),
//         child: Semantics(
//           label: "Tạo đoạn chat mới",
//           child: FloatingActionButton(
//             backgroundColor: Colors.blue,
//             onPressed: () {
//               flutterTts.speak("Tạo đoạn chat mới");
//               // Chuyển sang chế độ hiển thị danh sách người dùng
//               setState(() {
//                 isSearching = true;
//               });
//             },
//             child: const Icon(Icons.add_comment_rounded),
//           ),
//         ),
//       ),
//       body: isSearching ? userList() : messageList(),
//     );
//   }

//   Widget userList() {
//     return StreamBuilder(
//       stream: speakingService.getUserStream(),
//       builder: (context, snapshot) {
//         if (snapshot.hasError) {
//           return const Center(
//             child: Text("Lỗi dữ liệu", style: TextStyle(color: Colors.white)),
//           );
//         }

//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(
//             child: Text("Đang tải...", style: TextStyle(color: Colors.white)),
//           );
//         }

//         final filteredUsers = snapshot.data!.where((userData) {
//           final email = userData["email"]?.toLowerCase() ?? "";
//           final name = email.split("@").first;
//           return name.contains(searchQuery);
//         }).toList();

//         return ListView(
//           children: filteredUsers
//               .map<Widget>((userData) => userListItem(userData, context))
//               .toList(),
//         );
//       },
//     );
//   }

//   Widget messageList() {
//     final currentUserID = FirebaseAuth.instance.currentUser!.uid;
//     return StreamBuilder(
//       stream: speakingService.getUserStream(),
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         final otherUsers = snapshot.data!
//             .where((user) => user['uid'] != currentUserID)
//             .toList();

//         return ListView.builder(
//           itemCount: otherUsers.length,
//           itemBuilder: (context, index) {
//             final otherUser = otherUsers[index];
//             final otherUserID = otherUser['uid'];
//             final otherEmail = otherUser['email'];

//             return StreamBuilder<QuerySnapshot>(
//               stream: speakingService.getMessages(currentUserID, otherUserID),
//               builder: (context, msgSnapshot) {
//                 if (!msgSnapshot.hasData || msgSnapshot.data!.docs.isEmpty) {
//                   return const SizedBox();
//                 }

//                 // Tin nhắn đã được sắp xếp từ Firestore (mới nhất trước)
//                 final lastMsg =
//                     msgSnapshot.data!.docs.first.data() as Map<String, dynamic>;
//                 final lastMsgId =
//                     msgSnapshot.data!.docs.first.id; // ID của tin nhắn mới nhất
//                 final timestamp = (lastMsg['timestamp'] as Timestamp).toDate();
//                 final sender = lastMsg['senderEmail'];
//                 final content = lastMsg['message'];

//                 bool confirmDelete = false;
//                 Timer? deleteTimer;

//                 return GestureDetector(
//                   onTap: () async {
//                     await flutterTts.speak(
//                       "Tin nhắn từ $sender: $content, gửi lúc ${timestamp.hour} giờ ${timestamp.minute} phút vào ngày ${timestamp.day}/${timestamp.month}/${timestamp.year}",
//                     );
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => Speaking(
//                           receiverEmail: otherEmail,
//                           receiverID: otherUserID,
//                         ),
//                       ),
//                     );
//                   },
//                   onDoubleTap: () async {
//                     if (!confirmDelete) {
//                       confirmDelete = true;
//                       await flutterTts.speak(
//                         "Bạn đã chọn xóa tin nhắn từ $sender. Nhấn đúp lại trong 3 giây để xác nhận.",
//                       );

//                       deleteTimer?.cancel();
//                       deleteTimer = Timer(const Duration(seconds: 3), () {
//                         confirmDelete = false;
//                       });
//                     } else {
//                       // Xóa tin nhắn mới nhất
//                       await speakingService.deleteMessage(
//                         userID: currentUserID,
//                         otherUserID: otherUserID,
//                         messageId: lastMsgId,
//                       );

//                       await flutterTts.speak("Đã xóa tin nhắn");
//                       confirmDelete = false;
//                       deleteTimer?.cancel();
//                     }
//                   },
//                   child: Card(
//                     color: Colors.grey[900],
//                     margin: const EdgeInsets.symmetric(
//                       horizontal: 15,
//                       vertical: 8,
//                     ),
//                     child: ListTile(
//                       title: Text(
//                         sender,
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       subtitle: Text(
//                         content,
//                         style: const TextStyle(color: Colors.white70),
//                       ),
//                       trailing: Text(
//                         "${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')} - "
//                         "${timestamp.day.toString().padLeft(2, '0')}/"
//                         "${timestamp.month.toString().padLeft(2, '0')}/"
//                         "${timestamp.year}",
//                         style: const TextStyle(
//                           color: Colors.white38,
//                           fontSize: 12,
//                         ),
//                         textAlign: TextAlign.right,
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             );
//           },
//         );
//       },
//     );
//   }

//   Widget userListItem(Map<String, dynamic> userData, BuildContext context) {
//     final currentUserEmail = FirebaseAuth.instance.currentUser?.email;
//     if (userData["email"] == currentUserEmail) return const SizedBox.shrink();

//     final email = userData["email"] ?? "Không rõ";
//     final isOnline = userData["isOnline"] ?? false;

//     return Semantics(
//       label:
//           "Người dùng $email, trạng thái ${isOnline ? "đang hoạt động" : "ngoại tuyến"}",
//       child: Tooltip(
//         message: "Nhấn để nhắn tin với $email",
//         child: GestureDetector(
//           onTap: () async {
//             await flutterTts.speak("Đang mở trò chuyện với $email");
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => Speaking(
//                   receiverEmail: userData["email"],
//                   receiverID: userData["uid"],
//                 ),
//               ),
//             );
//           },
//           child: UserTile(
//             email: email,
//             isOnline: isOnline,
//             lastSeen: (userData["lastSeen"] != null)
//                 ? (userData["lastSeen"] as Timestamp).toDate().toString()
//                 : "Không rõ",
//             onTap: () async {
//               await flutterTts.speak("Đây là cuộc trò chuyện với $email");
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => Speaking(
//                     receiverEmail: userData["email"],
//                     receiverID: userData["uid"],
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }

//   void _showUserInfoDialog(BuildContext context) {
//     final user = FirebaseAuth.instance.currentUser;

//     showDialog(
//       context: context,
//       builder: (_) => Dialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         child: Padding(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               CircleAvatar(
//                 radius: 40,
//                 backgroundImage: user?.photoURL != null
//                     ? NetworkImage(user!.photoURL!)
//                     : null,
//                 child: user?.photoURL == null
//                     ? const Icon(Icons.person, size: 40)
//                     : null,
//               ),
//               const SizedBox(height: 10),
//               Text(
//                 user?.email ?? "Không có email",
//                 style: const TextStyle(fontSize: 18),
//               ),
//               const SizedBox(height: 10),
//               ElevatedButton.icon(
//                 onPressed: () => Navigator.pop(context),
//                 icon: const Icon(Icons.close),
//                 label: const Text("Đóng"),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.black,
//                   foregroundColor: Colors.white,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'dart:async';
import 'package:demo_nckh/components/drawer.dart';
import 'package:demo_nckh/screens/speaking.dart';
import 'package:demo_nckh/services/authentication/auth_service.dart';
import 'package:demo_nckh/services/speaking/speaking_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:demo_nckh/services/speaking/voice_controller.dart';

class SpeakScreen extends StatefulWidget {
  const SpeakScreen({super.key});

  @override
  State<SpeakScreen> createState() => _SpeakScreenState();
}

class _SpeakScreenState extends State<SpeakScreen>
    with TickerProviderStateMixin {
  final SpeakingService speakingService = SpeakingService();
  final AuthService authService = AuthService();
  final FlutterTts flutterTts = FlutterTts();
  final VoiceController voiceController = VoiceController();

  late AnimationController _searchAnimationController;
  late Animation<double> _searchAnimation;

  String searchQuery = "";
  final TextEditingController searchController = TextEditingController();
  bool isSearching = false;
  bool isVoiceListening = false;
  String? _lastCommand;

  @override
  void initState() {
    super.initState();
    _initializeVoiceControl();
    _initializeAnimations();
    _configureTTS();
  }

  void _initializeAnimations() {
    _searchAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _searchAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _searchAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  void _configureTTS() async {
    await flutterTts.setLanguage("vi-VN");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(0.8);
    await flutterTts.setPitch(1.0);
  }

  void _initializeVoiceControl() async {
    await voiceController.initSpeech();
    setState(() {
      isVoiceListening = true;
    });
    await voiceController.startListening(_handleVoiceCommand);
  }

  Future<void> _speakUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.email != null) {
      final name = user.email!.split('@').first;
      await flutterTts.speak("Tài khoản của bạn là $name");
    } else {
      await flutterTts.speak("Không tìm thấy thông tin người dùng");
    }
  }

  void _handleVoiceCommand(String command) async {
    if (_lastCommand == command) {
      print("Lệnh '$command' đã được thực hiện trước đó, bỏ qua");
      return;
    }
    _lastCommand = command;

    if (command.contains("tìm kiếm") || command.contains("tìm người")) {
      _toggleSearch(true);
      await flutterTts.speak("Đã bật chế độ tìm kiếm người dùng");
    } else if (command.contains("thoát tìm kiếm")) {
      _toggleSearch(false);
      await flutterTts.speak("Đã thoát chế độ tìm kiếm");
    } else if (command.contains("thoát ứng dụng") ||
        command.contains("đóng ứng dụng")) {
      await flutterTts.speak("Đang thoát ứng dụng");
      SystemNavigator.pop();
    } else if (command.contains("chat mới") || command.contains("tạo chat")) {
      _toggleSearch(true);
      await flutterTts.speak("Đang mở danh sách để tạo chat mới");
    } else if (command.contains("tắt micro") ||
        command.contains("ngừng nghe")) {
      await _toggleVoiceListening();
      await flutterTts.speak("Đã tắt chế độ nghe giọng nói");
    } else if (command.contains("bật micro") || command.contains("nghe lại")) {
      await _toggleVoiceListening();
      await flutterTts.speak("Đã bật chế độ nghe giọng nói");
    } else if (command.contains("đọc tin nhắn") ||
        command.contains("đọc danh sách")) {
      await _readMessageList();
    } else if (command.contains("thông tin tài khoản") ||
        command.contains("tài khoản của tôi")) {
      await flutterTts.speak("Mở thông tin tài khoản");
      _speakUserName();
      _showUserInfoDialog(context);
    } else if (command.contains("Đóng thông tin tài khoản") ||
        command.contains("đóng tài khoản")) {
      await flutterTts.speak("Đã đóng thông tin tài khoản");
      Navigator.pop(context);
    }
  }

  Future<void> _toggleVoiceListening() async {
    if (isVoiceListening) {
      await voiceController.stopListening();
      setState(() {
        isVoiceListening = false;
      });
    } else {
      await voiceController.startListening(_handleVoiceCommand);
      setState(() {
        isVoiceListening = true;
      });
    }
  }

  void _toggleSearch([bool? forceState]) {
    setState(() {
      isSearching = forceState ?? !isSearching;
      if (isSearching) {
        _searchAnimationController.forward();
      } else {
        _searchAnimationController.reverse();
        searchController.clear();
        searchQuery = "";
      }
    });
  }

  Future<void> _readMessageList() async {
    await flutterTts.speak("Đang đọc danh sách tin nhắn gần đây");
  }

  @override
  void dispose() {
    _searchAnimationController.dispose();
    searchController.dispose();
    voiceController.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0084FF).withOpacity(0.05),
      drawer: MyDrawer(),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(102),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
          child: _buildAppBar(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: isSearching ? _buildUserList() : _buildMessageList(),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Row(
            children: [
              if (isSearching)
                Semantics(
                  label: "Quay lại danh sách tin nhắn",
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFF0084FF),
                    ),
                    onPressed: () {
                      _toggleSearch(false);
                      flutterTts.speak("Đã quay lại danh sách tin nhắn");
                    },
                  ),
                ),
              Expanded(
                child: AnimatedBuilder(
                  animation: _searchAnimation,
                  builder: (context, child) {
                    return isSearching
                        ? TextField(
                            controller: searchController,
                            autofocus: true,
                            decoration: InputDecoration(
                              hintText: "Tìm kiếm người dùng...",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.grey[200],
                              prefixIcon: const Icon(
                                Icons.search,
                                color: Color(0xFF0084FF),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                            ),
                            style: const TextStyle(fontSize: 16),
                            onChanged: (value) {
                              setState(() {
                                searchQuery = value.toLowerCase();
                              });
                            },
                          )
                        : GestureDetector(
                            onTap: () =>
                                Scaffold.of(context).openDrawer(), // Mở Drawer
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.menu,
                                  color: Color(0xFF0084FF),
                                  size: 28,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Speaking',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          );
                  },
                ),
              ),
              if (!isSearching) ...[
                Semantics(
                  label: "Tìm kiếm người dùng",
                  child: IconButton(
                    icon: const Icon(
                      Icons.search,
                      color: Color(0xFF0084FF),
                      size: 28,
                    ),
                    onPressed: () {
                      _toggleSearch(true);
                      flutterTts.speak("Đã mở chế độ tìm kiếm");
                    },
                  ),
                ),
                Semantics(
                  label: isVoiceListening
                      ? "Tắt chế độ nghe giọng nói"
                      : "Bật chế độ nghe giọng nói",
                  child: IconButton(
                    icon: Icon(
                      isVoiceListening ? Icons.mic : Icons.mic_off,
                      color: isVoiceListening ? Colors.red : Colors.grey,
                      size: 28,
                    ),
                    onPressed: () async {
                      await _toggleVoiceListening();
                    },
                  ),
                ),
                Semantics(
                  label: "Thông tin tài khoản",
                  child: IconButton(
                    icon: const Icon(
                      Icons.account_circle,
                      color: Color(0xFF0084FF),
                      size: 28,
                    ),
                    onPressed: () {
                      // await flutterTts.speak("Mở thông tin tài khoản");
                      // _speakUserName();
                      // _showUserInfoDialog(context);
                    },
                  ),
                ),
              ],
            ],
          ),
          if (isVoiceListening)
            Container(
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Đang nghe...",
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Semantics(
      label: "Tạo tin nhắn mới",
      child: FloatingActionButton(
        backgroundColor: const Color(0xFF0084FF),
        elevation: 4,
        onPressed: () {
          flutterTts.speak("Mở danh sách để tạo tin nhắn mới");
          // _toggleSearch(true);
          // _showAddFriendDialog();
        },
        child: const Icon(Icons.person_search, color: Colors.white, size: 24),
      ),
    );
  }

  Widget _buildUserList() {
    return StreamBuilder(
      stream: speakingService.getUserStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red),
                SizedBox(height: 16),
                Text("Lỗi tải dữ liệu", style: TextStyle(fontSize: 18)),
              ],
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Color(0xFF0084FF)),
                SizedBox(height: 16),
                Text(
                  "Đang tải danh sách người dùng...",
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          );
        }

        final filteredUsers = snapshot.data!.where((userData) {
          final email = userData["email"]?.toLowerCase() ?? "";
          final name = email.split("@").first;
          return name.contains(searchQuery) &&
              userData["email"] != FirebaseAuth.instance.currentUser?.email;
        }).toList();

        if (filteredUsers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  searchQuery.isEmpty
                      ? "Không có người dùng nào"
                      : "Không tìm thấy '$searchQuery'",
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: filteredUsers.length,
          itemBuilder: (context, index) {
            return _buildUserListItem(filteredUsers[index], context);
          },
        );
      },
    );
  }

  Widget _buildUserListItem(
    Map<String, dynamic> userData,
    BuildContext context,
  ) {
    final email = userData["email"] ?? "Không rõ";
    final name = email.split("@").first;
    final isOnline = userData["isOnline"] ?? false;

    return Semantics(
      label:
          "Người dùng $name, ${isOnline ? "đang trực tuyến" : "ngoại tuyến"}",
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          elevation: 1,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () async {
              await flutterTts.speak("Mở cuộc trò chuyện với $name");
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Speaking(
                    receiverEmail: userData["email"],
                    receiverID: userData["uid"],
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: const Color(0xFF0084FF),
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : "?",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isOnline ? "Đang hoạt động" : "Ngoại tuyến",
                          style: TextStyle(
                            fontSize: 14,
                            color: isOnline ? Colors.green : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageList() {
    final currentUserID = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder(
      stream: speakingService.getUserStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF0084FF)),
          );
        }

        final otherUsers = snapshot.data!
            .where((user) => user['uid'] != currentUserID)
            .toList();

        if (otherUsers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                const Text(
                  "Chưa có cuộc trò chuyện nào",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Nhấn + để bắt đầu chat mới",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: otherUsers.length,
          itemBuilder: (context, index) {
            return _buildMessageListItem(otherUsers[index], currentUserID);
          },
        );
      },
    );
  }

  Widget _buildMessageListItem(
    Map<String, dynamic> otherUser,
    String currentUserID,
  ) {
    final otherUserID = otherUser['uid'];
    final otherEmail = otherUser['email'];
    final otherName = otherEmail.split('@').first;
    final isOnline = otherUser['isOnline'] ?? false;

    return StreamBuilder<QuerySnapshot>(
      stream: speakingService.getMessages(currentUserID, otherUserID),
      builder: (context, msgSnapshot) {
        if (!msgSnapshot.hasData || msgSnapshot.data!.docs.isEmpty) {
          return const SizedBox();
        }

        final lastMsg =
            msgSnapshot.data!.docs.last.data() as Map<String, dynamic>;
        final lastMsgId = msgSnapshot.data!.docs.last.id;
        final timestamp = (lastMsg['timestamp'] as Timestamp).toDate();
        final sender = lastMsg['senderEmail'];
        final content = lastMsg['message'];
        final isFromMe = sender == FirebaseAuth.instance.currentUser?.email;

        return Semantics(
          label: "Cuộc trò chuyện với $otherName. Tin nhắn cuối: $content",
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              elevation: 1,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () async {
                  await flutterTts.speak("Mở cuộc trò chuyện với $otherName");
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Speaking(
                        receiverEmail: otherEmail,
                        receiverID: otherUserID,
                      ),
                    ),
                  );
                },
                onLongPress: () async {
                  await flutterTts.speak(
                    "Tin nhắn cuối từ ${isFromMe ? 'bạn' : otherName}: $content, gửi lúc ${_formatTime(timestamp)}",
                  );
                  _showMessageOptions(
                    context,
                    lastMsgId,
                    currentUserID,
                    otherUserID,
                    otherName,
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: const Color(0xFF0084FF),
                            child: Text(
                              otherName.isNotEmpty
                                  ? otherName[0].toUpperCase()
                                  : "?",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  otherName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  _formatTime(timestamp),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                if (isFromMe)
                                  Icon(
                                    Icons.done_all,
                                    size: 16,
                                    color: Colors.blue[600],
                                  ),
                                if (isFromMe) const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    content,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showMessageOptions(
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
      builder: (context) => Container(
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
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text("Xóa tin nhắn cuối"),
              onTap: () async {
                Navigator.pop(context);
                await speakingService.deleteMessage(
                  userID: currentUserID,
                  otherUserID: otherUserID,
                  messageId: messageId,
                );
                await flutterTts.speak("Đã xóa tin nhắn");
              },
            ),
            ListTile(
              leading: const Icon(Icons.volume_up, color: Color(0xFF0084FF)),
              title: const Text("Đọc tin nhắn cuối"),
              onTap: () async {
                Navigator.pop(context);
                // Thực hiện đọc tin nhắn cuối
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return "${timestamp.day}/${timestamp.month}";
    } else if (difference.inHours > 0) {
      return "${difference.inHours}h";
    } else if (difference.inMinutes > 0) {
      return "${difference.inMinutes}m";
    } else {
      return "Vừa xong";
    }
  }

  void _showUserInfoDialog(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: const Color(0xFF0084FF),
                backgroundImage: user?.photoURL != null
                    ? NetworkImage(user!.photoURL!)
                    : null,
                child: user?.photoURL == null
                    ? Text(
                        user?.email?.split('@').first[0].toUpperCase() ?? "?",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      )
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
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
