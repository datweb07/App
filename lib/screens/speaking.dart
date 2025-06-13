// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:demo_nckh/components/chat_bubble.dart';
// import 'package:demo_nckh/components/textfield.dart';
// import 'package:demo_nckh/services/authentication/auth_service.dart';
// import 'package:demo_nckh/services/authentication/speaking/speaking_service.dart';
// import 'package:flutter/material.dart';

// class Speaking extends StatefulWidget {
//   final String receiverEmail;
//   final String receiverID;
//   const Speaking({
//     super.key,
//     required this.receiverEmail,
//     required this.receiverID,
//   });

//   @override
//   State<Speaking> createState() => _SpeakingState();
// }

// class _SpeakingState extends State<Speaking> {
//   // Text controller
//   final TextEditingController messageController = TextEditingController();
//   final ScrollController _scrollController = ScrollController(); // NEW
//   // Chatting and authentication services
//   final SpeakingService chattingService = SpeakingService();
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
//       await chattingService.sendMessage(
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
//       stream: chattingService.getMessages(widget.receiverID, senderID),
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
//               icon: const Icon(Icons.mic),
//               color: Colors.white,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:demo_nckh/components/chat_bubble.dart';
// import 'package:demo_nckh/components/textfield.dart';
// import 'package:demo_nckh/services/authentication/auth_service.dart';
// import 'package:demo_nckh/services/authentication/speaking/speaking_service.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// class Speaking extends StatefulWidget {
//   final String receiverEmail;
//   final String receiverID;
//   const Speaking({
//     super.key,
//     required this.receiverEmail,
//     required this.receiverID,
//   });

//   @override
//   State<Speaking> createState() => _SpeakingState();
// }

// class _SpeakingState extends State<Speaking> {
//   // Text controller
//   final TextEditingController messageController = TextEditingController();
//   final ScrollController _scrollController = ScrollController();
//   final FocusNode _messageFocusNode = FocusNode();

//   // Chatting and authentication services
//   final SpeakingService chattingService = SpeakingService();
//   final AuthService authService = AuthService();

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     _messageFocusNode.dispose();
//     messageController.dispose();
//     super.dispose();
//   }

//   // Send message
//   void senMessage() async {
//     if (messageController.text.isNotEmpty) {
//       String messageText = messageController.text;

//       // Send message
//       await chattingService.sendMessage(widget.receiverID, messageText);

//       // Clear message
//       messageController.clear();

//       // Announce message sent for screen readers
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Tin nhắn đã được gửi: $messageText'),
//           duration: const Duration(seconds: 1),
//         ),
//       );

//       // Auto scroll to bottom
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
//       backgroundColor: Colors.grey[50],
//       appBar: PreferredSize(
//         preferredSize: const Size.fromHeight(70),
//         child: Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: [Colors.blue[600]!, Colors.blue[400]!],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//             borderRadius: const BorderRadius.only(
//               bottomLeft: Radius.circular(25),
//               bottomRight: Radius.circular(25),
//             ),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.blue.withOpacity(0.3),
//                 blurRadius: 10,
//                 offset: const Offset(0, 3),
//               ),
//             ],
//           ),
//           child: AppBar(
//             backgroundColor: Colors.transparent,
//             elevation: 0,
//             centerTitle: false,
//             leading: Semantics(
//               label: 'Quay lại',
//               child: IconButton(
//                 icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
//                 onPressed: () => Navigator.pop(context),
//               ),
//             ),
//             title: Row(
//               children: [
//                 // Avatar placeholder
//                 Container(
//                   width: 40,
//                   height: 40,
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     shape: BoxShape.circle,
//                     border: Border.all(color: Colors.white, width: 2),
//                   ),
//                   child: Icon(Icons.person, color: Colors.blue[600], size: 24),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         widget.receiverEmail.split(
//                           '@',
//                         )[0], // Display name without @domain
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 18,
//                           fontWeight: FontWeight.w600,
//                         ),
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                       const Text(
//                         'Đang hoạt động',
//                         style: TextStyle(color: Colors.white70, fontSize: 12),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             actions: [
//               Semantics(
//                 label: 'Gọi thoại',
//                 child: IconButton(
//                   icon: const Icon(Icons.call, color: Colors.white),
//                   onPressed: () {
//                     // Voice call functionality
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(content: Text('Tính năng gọi thoại')),
//                     );
//                   },
//                 ),
//               ),
//               Semantics(
//                 label: 'Tùy chọn thêm',
//                 child: IconButton(
//                   icon: const Icon(Icons.more_vert, color: Colors.white),
//                   onPressed: () {
//                     // More options
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//       body: Column(
//         children: [
//           // Display all messages
//           Expanded(child: messageList()),

//           // Typing indicator placeholder
//           Container(
//             height: 20,
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: const Text(
//               '', // Could show "Đang nhập..." when other user is typing
//               style: TextStyle(
//                 color: Colors.grey,
//                 fontSize: 12,
//                 fontStyle: FontStyle.italic,
//               ),
//             ),
//           ),

//           // User input
//           messageInput(),
//         ],
//       ),
//     );
//   }

//   // Message List with better accessibility
//   Widget messageList() {
//     String senderID = authService.getCurrentUser()!.uid;
//     return StreamBuilder(
//       stream: chattingService.getMessages(widget.receiverID, senderID),
//       builder: (context, snapshot) {
//         // Display errors with better accessibility
//         if (snapshot.hasError) {
//           return Center(
//             child: Semantics(
//               label: 'Có lỗi xảy ra khi tải tin nhắn',
//               child: const Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.error_outline, size: 48, color: Colors.red),
//                   SizedBox(height: 16),
//                   Text(
//                     "Không thể tải tin nhắn",
//                     style: TextStyle(fontSize: 16, color: Colors.red),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         }

//         // Loading state with accessibility
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Center(
//             child: Semantics(
//               label: 'Đang tải tin nhắn',
//               child: const Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   CircularProgressIndicator(),
//                   SizedBox(height: 16),
//                   Text("Đang tải tin nhắn..."),
//                 ],
//               ),
//             ),
//           );
//         }

//         // Message list
//         return ListView.builder(
//           controller: _scrollController,
//           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
//           itemCount: snapshot.data!.docs.length,
//           itemBuilder: (context, index) {
//             return messageItem(snapshot.data!.docs[index], index);
//           },
//         );
//       },
//     );
//   }

//   // Enhanced Message Item with Messenger-like design
//   Widget messageItem(DocumentSnapshot doc, int index) {
//     Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
//     bool isCurrentUser = data['senderID'] == authService.getCurrentUser()!.uid;

//     // Format timestamp
//     String timeString = '';
//     if (data['timestamp'] != null) {
//       DateTime timestamp = (data['timestamp'] as Timestamp).toDate();
//       timeString = DateFormat('HH:mm').format(timestamp);
//     }

//     return Semantics(
//       label: isCurrentUser
//           ? 'Tin nhắn của bạn: ${data["message"]}, thời gian $timeString'
//           : 'Tin nhắn từ ${widget.receiverEmail}: ${data["message"]}, thời gian $timeString',
//       child: Container(
//         margin: const EdgeInsets.symmetric(vertical: 2),
//         child: Row(
//           mainAxisAlignment: isCurrentUser
//               ? MainAxisAlignment.end
//               : MainAxisAlignment.start,
//           crossAxisAlignment: CrossAxisAlignment.end,
//           children: [
//             // Avatar for received messages
//             if (!isCurrentUser) ...[
//               Container(
//                 width: 28,
//                 height: 28,
//                 margin: const EdgeInsets.only(right: 8, bottom: 4),
//                 decoration: BoxDecoration(
//                   color: Colors.blue[100],
//                   shape: BoxShape.circle,
//                 ),
//                 child: Icon(Icons.person, size: 16, color: Colors.blue[600]),
//               ),
//             ],

//             // Message bubble
//             Flexible(
//               child: Container(
//                 constraints: BoxConstraints(
//                   maxWidth: MediaQuery.of(context).size.width * 0.75,
//                 ),
//                 margin: EdgeInsets.only(
//                   left: isCurrentUser ? 40 : 0,
//                   right: isCurrentUser ? 0 : 40,
//                   bottom: 4,
//                 ),
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 12,
//                 ),
//                 decoration: BoxDecoration(
//                   gradient: isCurrentUser
//                       ? LinearGradient(
//                           colors: [Colors.blue[600]!, Colors.blue[500]!],
//                           begin: Alignment.topLeft,
//                           end: Alignment.bottomRight,
//                         )
//                       : null,
//                   color: isCurrentUser ? null : Colors.grey[200],
//                   borderRadius: BorderRadius.only(
//                     topLeft: const Radius.circular(20),
//                     topRight: const Radius.circular(20),
//                     bottomLeft: Radius.circular(isCurrentUser ? 20 : 4),
//                     bottomRight: Radius.circular(isCurrentUser ? 4 : 20),
//                   ),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.1),
//                       blurRadius: 4,
//                       offset: const Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       data["message"],
//                       style: TextStyle(
//                         color: isCurrentUser ? Colors.white : Colors.black87,
//                         fontSize: 16,
//                         height: 1.4,
//                       ),
//                     ),
//                     if (timeString.isNotEmpty) ...[
//                       const SizedBox(height: 4),
//                       Text(
//                         timeString,
//                         style: TextStyle(
//                           color: isCurrentUser
//                               ? Colors.white70
//                               : Colors.grey[600],
//                           fontSize: 11,
//                         ),
//                       ),
//                     ],
//                   ],
//                 ),
//               ),
//             ),

//             // Avatar for sent messages
//             if (isCurrentUser) ...[
//               Container(
//                 width: 28,
//                 height: 28,
//                 margin: const EdgeInsets.only(left: 8, bottom: 4),
//                 decoration: BoxDecoration(
//                   color: Colors.blue[600],
//                   shape: BoxShape.circle,
//                 ),
//                 child: const Icon(Icons.person, size: 16, color: Colors.white),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }

//   // Enhanced message input with accessibility
//   Widget messageInput() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 10,
//             offset: const Offset(0, -2),
//           ),
//         ],
//       ),
//       child: SafeArea(
//         child: Row(
//           children: [
//             // Additional options button
//             Semantics(
//               label: 'Tùy chọn thêm',
//               child: Container(
//                 width: 40,
//                 height: 40,
//                 margin: const EdgeInsets.only(right: 12),
//                 decoration: BoxDecoration(
//                   color: Colors.grey[100],
//                   shape: BoxShape.circle,
//                 ),
//                 child: IconButton(
//                   icon: Icon(Icons.add, color: Colors.grey[600]),
//                   onPressed: () {
//                     // Show attachment options
//                     _showAttachmentOptions();
//                   },
//                 ),
//               ),
//             ),

//             // Text input field
//             Expanded(
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: Colors.grey[100],
//                   borderRadius: BorderRadius.circular(25),
//                   border: Border.all(color: Colors.grey[300]!),
//                 ),
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: Semantics(
//                         label: 'Nhập tin nhắn',
//                         textField: true,
//                         child: TextField(
//                           controller: messageController,
//                           focusNode: _messageFocusNode,
//                           decoration: const InputDecoration(
//                             hintText: "Nhập tin nhắn...",
//                             border: InputBorder.none,
//                             contentPadding: EdgeInsets.symmetric(
//                               horizontal: 20,
//                               vertical: 12,
//                             ),
//                           ),
//                           style: const TextStyle(fontSize: 16),
//                           maxLines: null,
//                           textCapitalization: TextCapitalization.sentences,
//                           onSubmitted: (_) => senMessage(),
//                         ),
//                       ),
//                     ),

//                     // Emoji button
//                     Semantics(
//                       label: 'Chọn emoji',
//                       child: IconButton(
//                         icon: Icon(
//                           Icons.emoji_emotions_outlined,
//                           color: Colors.grey[600],
//                         ),
//                         onPressed: () {
//                           // Show emoji picker
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             const SnackBar(content: Text('Tính năng emoji')),
//                           );
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             const SizedBox(width: 12),

//             // Send/Voice button
//             Semantics(
//               label: messageController.text.isEmpty
//                   ? 'Ghi âm tin nhắn thoại'
//                   : 'Gửi tin nhắn',
//               child: Container(
//                 width: 48,
//                 height: 48,
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [Colors.blue[600]!, Colors.blue[500]!],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                   shape: BoxShape.circle,
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.blue.withOpacity(0.3),
//                       blurRadius: 8,
//                       offset: const Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: IconButton(
//                   onPressed: () {
//                     if (messageController.text.isNotEmpty) {
//                       senMessage();
//                     } else {
//                       // Voice message functionality
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(
//                           content: Text('Tính năng tin nhắn thoại'),
//                         ),
//                       );
//                     }
//                   },
//                   icon: Icon(
//                     messageController.text.isEmpty ? Icons.mic : Icons.send,
//                     color: Colors.white,
//                     size: 20,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Show attachment options
//   void _showAttachmentOptions() {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       builder: (context) => Container(
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               width: 40,
//               height: 4,
//               margin: const EdgeInsets.symmetric(vertical: 12),
//               decoration: BoxDecoration(
//                 color: Colors.grey[300],
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),
//             const Text(
//               'Chọn tệp đính kèm',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
//             ),
//             const SizedBox(height: 20),
//             GridView.count(
//               shrinkWrap: true,
//               crossAxisCount: 3,
//               padding: const EdgeInsets.all(20),
//               children: [
//                 _buildAttachmentOption(
//                   Icons.photo_library,
//                   'Thư viện ảnh',
//                   Colors.purple,
//                   () => Navigator.pop(context),
//                 ),
//                 _buildAttachmentOption(
//                   Icons.camera_alt,
//                   'Máy ảnh',
//                   Colors.red,
//                   () => Navigator.pop(context),
//                 ),
//                 _buildAttachmentOption(
//                   Icons.insert_drive_file,
//                   'Tài liệu',
//                   Colors.blue,
//                   () => Navigator.pop(context),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildAttachmentOption(
//     IconData icon,
//     String label,
//     Color color,
//     VoidCallback onTap,
//   ) {
//     return Semantics(
//       label: label,
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(12),
//         child: Container(
//           decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Container(
//                 width: 50,
//                 height: 50,
//                 decoration: BoxDecoration(
//                   color: color.withOpacity(0.1),
//                   shape: BoxShape.circle,
//                 ),
//                 child: Icon(icon, color: color, size: 24),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 label,
//                 style: const TextStyle(fontSize: 12),
//                 textAlign: TextAlign.center,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:demo_nckh/components/chat_bubble.dart';
// import 'package:demo_nckh/components/textfield.dart';
// import 'package:demo_nckh/services/authentication/auth_service.dart';
// import 'package:demo_nckh/services/authentication/speaking/speaking_service.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// class Speaking extends StatefulWidget {
//   final String receiverEmail;
//   final String receiverID;
//   const Speaking({
//     super.key,
//     required this.receiverEmail,
//     required this.receiverID,
//   });

//   @override
//   State<Speaking> createState() => _SpeakingState();
// }

// class _SpeakingState extends State<Speaking> {
//   // Text controller
//   final TextEditingController messageController = TextEditingController();
//   final ScrollController _scrollController = ScrollController();
//   final FocusNode _messageFocusNode = FocusNode();

//   // Chatting and authentication services
//   final SpeakingService chattingService = SpeakingService();
//   final AuthService authService = AuthService();

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     _messageFocusNode.dispose();
//     messageController.dispose();
//     super.dispose();
//   }

//   // Send message
//   void senMessage() async {
//     if (messageController.text.isNotEmpty) {
//       String messageText = messageController.text;

//       // Send message
//       await chattingService.sendMessage(widget.receiverID, messageText);

//       // Clear message
//       messageController.clear();

//       // Announce message sent for screen readers
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Tin nhắn đã được gửi: $messageText'),
//           duration: const Duration(seconds: 1),
//         ),
//       );

//       // Auto scroll to bottom
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
//       backgroundColor: Colors.grey[50],
//       appBar: PreferredSize(
//         preferredSize: const Size.fromHeight(70),
//         child: Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: [Colors.blue[600]!, Colors.blue[400]!],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//             borderRadius: const BorderRadius.only(
//               bottomLeft: Radius.circular(25),
//               bottomRight: Radius.circular(25),
//             ),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.blue.withOpacity(0.3),
//                 blurRadius: 10,
//                 offset: const Offset(0, 3),
//               ),
//             ],
//           ),
//           child: AppBar(
//             backgroundColor: Colors.transparent,
//             elevation: 0,
//             centerTitle: false,
//             leading: Semantics(
//               label: 'Quay lại',
//               child: IconButton(
//                 icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
//                 onPressed: () => Navigator.pop(context),
//               ),
//             ),
//             title: Row(
//               children: [
//                 // Avatar placeholder
//                 Container(
//                   width: 40,
//                   height: 40,
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     shape: BoxShape.circle,
//                     border: Border.all(color: Colors.white, width: 2),
//                   ),
//                   child: Icon(Icons.person, color: Colors.blue[600], size: 24),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         widget.receiverEmail.split(
//                           '@',
//                         )[0], // Display name without @domain
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 18,
//                           fontWeight: FontWeight.w600,
//                         ),
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                       const Text(
//                         'Đang hoạt động',
//                         style: TextStyle(color: Colors.white70, fontSize: 12),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             actions: [
//               Semantics(
//                 label: 'Gọi thoại',
//                 child: IconButton(
//                   icon: const Icon(Icons.call, color: Colors.white),
//                   onPressed: () {
//                     // Voice call functionality
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(content: Text('Tính năng gọi thoại')),
//                     );
//                   },
//                 ),
//               ),
//               Semantics(
//                 label: 'Tùy chọn thêm',
//                 child: IconButton(
//                   icon: const Icon(Icons.more_vert, color: Colors.white),
//                   onPressed: () {
//                     // More options
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//       body: Column(
//         children: [
//           // Display all messages
//           Expanded(child: messageList()),

//           // Typing indicator placeholder
//           Container(
//             height: 20,
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: const Text(
//               '', // Could show "Đang nhập..." when other user is typing
//               style: TextStyle(
//                 color: Colors.grey,
//                 fontSize: 12,
//                 fontStyle: FontStyle.italic,
//               ),
//             ),
//           ),

//           // User input
//           messageInput(),
//         ],
//       ),
//     );
//   }

//   // Message List with better accessibility and error handling
//   Widget messageList() {
//     String senderID = authService.getCurrentUser()!.uid;
//     return StreamBuilder<QuerySnapshot>(
//       stream: chattingService.getMessages(widget.receiverID, senderID),
//       builder: (context, snapshot) {
//         // Debug information
//         print('StreamBuilder state: ${snapshot.connectionState}');
//         print('Has error: ${snapshot.hasError}');
//         if (snapshot.hasError) {
//           print('Error: ${snapshot.error}');
//         }
//         print('Has data: ${snapshot.hasData}');
//         if (snapshot.hasData) {
//           print('Docs count: ${snapshot.data!.docs.length}');
//         }

//         // Display errors with better accessibility
//         if (snapshot.hasError) {
//           return Center(
//             child: Semantics(
//               label: 'Có lỗi xảy ra khi tải tin nhắn',
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Icon(Icons.error_outline, size: 48, color: Colors.red),
//                   const SizedBox(height: 16),
//                   const Text(
//                     "Không thể tải tin nhắn",
//                     style: TextStyle(fontSize: 16, color: Colors.red),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     "Lỗi: ${snapshot.error}",
//                     style: const TextStyle(fontSize: 12, color: Colors.grey),
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 16),
//                   ElevatedButton(
//                     onPressed: () {
//                       setState(() {}); // Reload the stream
//                     },
//                     child: const Text('Thử lại'),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         }

//         // Loading state with accessibility
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Center(
//             child: Semantics(
//               label: 'Đang tải tin nhắn',
//               child: const Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   CircularProgressIndicator(),
//                   SizedBox(height: 16),
//                   Text("Đang tải tin nhắn..."),
//                 ],
//               ),
//             ),
//           );
//         }

//         // Check if data is null or empty
//         if (!snapshot.hasData || snapshot.data == null) {
//           return Center(
//             child: Semantics(
//               label: 'Không có dữ liệu tin nhắn',
//               child: const Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.chat_bubble_outline, size: 48, color: Colors.grey),
//                   SizedBox(height: 16),
//                   Text(
//                     "Không có tin nhắn nào",
//                     style: TextStyle(fontSize: 16, color: Colors.grey),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         }

//         // Check if docs is empty
//         if (snapshot.data!.docs.isEmpty) {
//           return Center(
//             child: Semantics(
//               label: 'Chưa có tin nhắn nào',
//               child: const Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.chat_bubble_outline, size: 48, color: Colors.grey),
//                   SizedBox(height: 16),
//                   Text(
//                     "Chưa có tin nhắn nào",
//                     style: TextStyle(fontSize: 16, color: Colors.grey),
//                   ),
//                   SizedBox(height: 8),
//                   Text(
//                     "Hãy gửi tin nhắn đầu tiên!",
//                     style: TextStyle(fontSize: 14, color: Colors.grey),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         }

//         // Message list
//         return ListView.builder(
//           controller: _scrollController,
//           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
//           itemCount: snapshot.data!.docs.length,
//           itemBuilder: (context, index) {
//             return messageItem(snapshot.data!.docs[index], index);
//           },
//         );
//       },
//     );
//   }

//   // Enhanced Message Item with Messenger-like design
//   Widget messageItem(DocumentSnapshot doc, int index) {
//     Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

//     // Check if data is null
//     if (data == null) {
//       return const SizedBox.shrink();
//     }

//     // Check required fields
//     if (!data.containsKey('senderID') || !data.containsKey('message')) {
//       print('Missing required fields in document: $data');
//       return const SizedBox.shrink();
//     }

//     bool isCurrentUser = data['senderID'] == authService.getCurrentUser()!.uid;

//     // Format timestamp safely
//     String timeString = '';
//     try {
//       if (data['timestamp'] != null) {
//         DateTime timestamp = (data['timestamp'] as Timestamp).toDate();
//         timeString = DateFormat('HH:mm').format(timestamp);
//       }
//     } catch (e) {
//       print('Error formatting timestamp: $e');
//       timeString = '';
//     }

//     return Semantics(
//       label: isCurrentUser
//           ? 'Tin nhắn của bạn: ${data["message"]}, thời gian $timeString'
//           : 'Tin nhắn từ ${widget.receiverEmail}: ${data["message"]}, thời gian $timeString',
//       child: Container(
//         margin: const EdgeInsets.symmetric(vertical: 2),
//         child: Row(
//           mainAxisAlignment: isCurrentUser
//               ? MainAxisAlignment.end
//               : MainAxisAlignment.start,
//           crossAxisAlignment: CrossAxisAlignment.end,
//           children: [
//             // Avatar for received messages
//             if (!isCurrentUser) ...[
//               Container(
//                 width: 28,
//                 height: 28,
//                 margin: const EdgeInsets.only(right: 8, bottom: 4),
//                 decoration: BoxDecoration(
//                   color: Colors.blue[100],
//                   shape: BoxShape.circle,
//                 ),
//                 child: Icon(Icons.person, size: 16, color: Colors.blue[600]),
//               ),
//             ],

//             // Message bubble
//             Flexible(
//               child: Container(
//                 constraints: BoxConstraints(
//                   maxWidth: MediaQuery.of(context).size.width * 0.75,
//                 ),
//                 margin: EdgeInsets.only(
//                   left: isCurrentUser ? 40 : 0,
//                   right: isCurrentUser ? 0 : 40,
//                   bottom: 4,
//                 ),
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 12,
//                 ),
//                 decoration: BoxDecoration(
//                   gradient: isCurrentUser
//                       ? LinearGradient(
//                           colors: [Colors.blue[600]!, Colors.blue[500]!],
//                           begin: Alignment.topLeft,
//                           end: Alignment.bottomRight,
//                         )
//                       : null,
//                   color: isCurrentUser ? null : Colors.grey[200],
//                   borderRadius: BorderRadius.only(
//                     topLeft: const Radius.circular(20),
//                     topRight: const Radius.circular(20),
//                     bottomLeft: Radius.circular(isCurrentUser ? 20 : 4),
//                     bottomRight: Radius.circular(isCurrentUser ? 4 : 20),
//                   ),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.1),
//                       blurRadius: 4,
//                       offset: const Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       data["message"],
//                       style: TextStyle(
//                         color: isCurrentUser ? Colors.white : Colors.black87,
//                         fontSize: 16,
//                         height: 1.4,
//                       ),
//                     ),
//                     if (timeString.isNotEmpty) ...[
//                       const SizedBox(height: 4),
//                       Text(
//                         timeString,
//                         style: TextStyle(
//                           color: isCurrentUser
//                               ? Colors.white70
//                               : Colors.grey[600],
//                           fontSize: 11,
//                         ),
//                       ),
//                     ],
//                   ],
//                 ),
//               ),
//             ),

//             // Avatar for sent messages
//             if (isCurrentUser) ...[
//               Container(
//                 width: 28,
//                 height: 28,
//                 margin: const EdgeInsets.only(left: 8, bottom: 4),
//                 decoration: BoxDecoration(
//                   color: Colors.blue[600],
//                   shape: BoxShape.circle,
//                 ),
//                 child: const Icon(Icons.person, size: 16, color: Colors.white),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }

//   // Enhanced message input with accessibility
//   Widget messageInput() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 10,
//             offset: const Offset(0, -2),
//           ),
//         ],
//       ),
//       child: SafeArea(
//         child: Row(
//           children: [
//             // Additional options button
//             Semantics(
//               label: 'Tùy chọn thêm',
//               child: Container(
//                 width: 40,
//                 height: 40,
//                 margin: const EdgeInsets.only(right: 12),
//                 decoration: BoxDecoration(
//                   color: Colors.grey[100],
//                   shape: BoxShape.circle,
//                 ),
//                 child: IconButton(
//                   icon: Icon(Icons.add, color: Colors.grey[600]),
//                   onPressed: () {
//                     // Show attachment options
//                     _showAttachmentOptions();
//                   },
//                 ),
//               ),
//             ),

//             // Text input field
//             Expanded(
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: Colors.grey[100],
//                   borderRadius: BorderRadius.circular(25),
//                   border: Border.all(color: Colors.grey[300]!),
//                 ),
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: Semantics(
//                         label: 'Nhập tin nhắn',
//                         textField: true,
//                         child: TextField(
//                           controller: messageController,
//                           focusNode: _messageFocusNode,
//                           decoration: const InputDecoration(
//                             hintText: "Nhập tin nhắn...",
//                             border: InputBorder.none,
//                             contentPadding: EdgeInsets.symmetric(
//                               horizontal: 20,
//                               vertical: 12,
//                             ),
//                           ),
//                           style: const TextStyle(fontSize: 16),
//                           maxLines: null,
//                           textCapitalization: TextCapitalization.sentences,
//                           onSubmitted: (_) => senMessage(),
//                         ),
//                       ),
//                     ),

//                     // Emoji button
//                     Semantics(
//                       label: 'Chọn emoji',
//                       child: IconButton(
//                         icon: Icon(
//                           Icons.emoji_emotions_outlined,
//                           color: Colors.grey[600],
//                         ),
//                         onPressed: () {
//                           // Show emoji picker
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             const SnackBar(content: Text('Tính năng emoji')),
//                           );
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             const SizedBox(width: 12),

//             // Send/Voice button
//             Semantics(
//               label: messageController.text.isEmpty
//                   ? 'Ghi âm tin nhắn thoại'
//                   : 'Gửi tin nhắn',
//               child: Container(
//                 width: 48,
//                 height: 48,
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [Colors.blue[600]!, Colors.blue[500]!],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                   shape: BoxShape.circle,
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.blue.withOpacity(0.3),
//                       blurRadius: 8,
//                       offset: const Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: IconButton(
//                   onPressed: () {
//                     if (messageController.text.isNotEmpty) {
//                       senMessage();
//                     } else {
//                       // Voice message functionality
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(
//                           content: Text('Tính năng tin nhắn thoại'),
//                         ),
//                       );
//                     }
//                   },
//                   icon: Icon(
//                     messageController.text.isEmpty ? Icons.mic : Icons.send,
//                     color: Colors.white,
//                     size: 20,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Show attachment options
//   void _showAttachmentOptions() {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       builder: (context) => Container(
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               width: 40,
//               height: 4,
//               margin: const EdgeInsets.symmetric(vertical: 12),
//               decoration: BoxDecoration(
//                 color: Colors.grey[300],
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),
//             const Text(
//               'Chọn tệp đính kèm',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
//             ),
//             const SizedBox(height: 20),
//             GridView.count(
//               shrinkWrap: true,
//               crossAxisCount: 3,
//               padding: const EdgeInsets.all(20),
//               children: [
//                 _buildAttachmentOption(
//                   Icons.photo_library,
//                   'Thư viện ảnh',
//                   Colors.purple,
//                   () => Navigator.pop(context),
//                 ),
//                 _buildAttachmentOption(
//                   Icons.camera_alt,
//                   'Máy ảnh',
//                   Colors.red,
//                   () => Navigator.pop(context),
//                 ),
//                 _buildAttachmentOption(
//                   Icons.insert_drive_file,
//                   'Tài liệu',
//                   Colors.blue,
//                   () => Navigator.pop(context),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildAttachmentOption(
//     IconData icon,
//     String label,
//     Color color,
//     VoidCallback onTap,
//   ) {
//     return Semantics(
//       label: label,
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(12),
//         child: Container(
//           decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Container(
//                 width: 50,
//                 height: 50,
//                 decoration: BoxDecoration(
//                   color: color.withOpacity(0.1),
//                   shape: BoxShape.circle,
//                 ),
//                 child: Icon(icon, color: color, size: 24),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 label,
//                 style: const TextStyle(fontSize: 12),
//                 textAlign: TextAlign.center,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_nckh/components/chat_bubble.dart';
import 'package:demo_nckh/components/textfield.dart';
import 'package:demo_nckh/services/authentication/auth_service.dart';
import 'package:demo_nckh/services/authentication/speaking/speaking_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Speaking extends StatefulWidget {
  final String receiverEmail;
  final String receiverID;
  const Speaking({
    super.key,
    required this.receiverEmail,
    required this.receiverID,
  });

  @override
  State<Speaking> createState() => _SpeakingState();
}

class _SpeakingState extends State<Speaking> {
  // Text controller
  final TextEditingController messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _messageFocusNode = FocusNode();

  // Chatting and authentication services
  final SpeakingService chattingService = SpeakingService();
  final AuthService authService = AuthService();

  @override
  void dispose() {
    _scrollController.dispose();
    _messageFocusNode.dispose();
    messageController.dispose();
    super.dispose();
  }

  // Send message
  void senMessage() async {
    if (messageController.text.isNotEmpty) {
      String messageText = messageController.text;

      // Send message
      await chattingService.sendMessage(widget.receiverID, messageText);

      // Clear message
      messageController.clear();

      // Announce message sent for screen readers
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tin nhắn đã được gửi: $messageText'),
          duration: const Duration(seconds: 1),
        ),
      );

      // Auto scroll to bottom
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[600]!, Colors.blue[400]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(25),
              bottomRight: Radius.circular(25),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: false,
            leading: Semantics(
              label: 'Quay lại',
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            title: Row(
              children: [
                // Avatar placeholder
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Icon(Icons.person, color: Colors.blue[600], size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.receiverEmail.split(
                          '@',
                        )[0], // Display name without @domain
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Text(
                        'Đang hoạt động',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              Semantics(
                label: 'Gọi thoại',
                child: IconButton(
                  icon: const Icon(Icons.call, color: Colors.white),
                  onPressed: () {
                    // Voice call functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Tính năng gọi thoại')),
                    );
                  },
                ),
              ),
              Semantics(
                label: 'Tùy chọn thêm',
                child: IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  onPressed: () {
                    // More options
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // Display all messages
          Expanded(child: messageList()),

          // Typing indicator placeholder
          Container(
            height: 20,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: const Text(
              '', // Could show "Đang nhập..." when other user is typing
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),

          // User input
          messageInput(),
        ],
      ),
    );
  }

  // Message List with better accessibility and error handling
  Widget messageList() {
    String senderID = authService.getCurrentUser()!.uid;
    return StreamBuilder<QuerySnapshot>(
      stream: chattingService.getMessages(senderID, widget.receiverID),
      builder: (context, snapshot) {
        // Debug information
        print('StreamBuilder state: ${snapshot.connectionState}');
        print('Has error: ${snapshot.hasError}');
        if (snapshot.hasError) {
          print('Error: ${snapshot.error}');
        }
        print('Has data: ${snapshot.hasData}');
        if (snapshot.hasData) {
          print('Docs count: ${snapshot.data!.docs.length}');
        }

        // Display errors with better accessibility
        if (snapshot.hasError) {
          return Center(
            child: Semantics(
              label: 'Có lỗi xảy ra khi tải tin nhắn',
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text(
                    "Không thể tải tin nhắn",
                    style: TextStyle(fontSize: 16, color: Colors.red),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Lỗi: ${snapshot.error}",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {}); // Reload the stream
                    },
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            ),
          );
        }

        // Loading state with accessibility
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Semantics(
              label: 'Đang tải tin nhắn',
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text("Đang tải tin nhắn..."),
                ],
              ),
            ),
          );
        }

        // Check if data is null or empty
        if (!snapshot.hasData || snapshot.data == null) {
          return Center(
            child: Semantics(
              label: 'Không có dữ liệu tin nhắn',
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 48, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    "Không có tin nhắn nào",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }

        // Check if docs is empty
        if (snapshot.data!.docs.isEmpty) {
          return Center(
            child: Semantics(
              label: 'Chưa có tin nhắn nào',
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 48, color: Colors.grey),
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
            ),
          );
        }

        // Message list
        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            return messageItem(snapshot.data!.docs[index], index);
          },
        );
      },
    );
  }

  // Enhanced Message Item with Messenger-like design
  Widget messageItem(DocumentSnapshot doc, int index) {
    Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

    // Check if data is null
    if (data == null) {
      return const SizedBox.shrink();
    }

    // Check required fields
    if (!data.containsKey('senderID') || !data.containsKey('message')) {
      print('Missing required fields in document: $data');
      return const SizedBox.shrink();
    }

    bool isCurrentUser = data['senderID'] == authService.getCurrentUser()!.uid;

    // Format timestamp safely
    String timeString = '';
    try {
      if (data['timestamp'] != null) {
        DateTime timestamp = (data['timestamp'] as Timestamp).toDate();
        timeString = DateFormat('HH:mm').format(timestamp);
      }
    } catch (e) {
      print('Error formatting timestamp: $e');
      timeString = '';
    }

    return Semantics(
      label: isCurrentUser
          ? 'Tin nhắn của bạn: ${data["message"]}, thời gian $timeString'
          : 'Tin nhắn từ ${widget.receiverEmail}: ${data["message"]}, thời gian $timeString',
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisAlignment: isCurrentUser
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Avatar for received messages
            if (!isCurrentUser) ...[
              Container(
                width: 28,
                height: 28,
                margin: const EdgeInsets.only(right: 8, bottom: 4),
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.person, size: 16, color: Colors.blue[600]),
              ),
            ],

            // Message bubble
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
                      timeString,
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

            // Avatar for sent messages
            if (isCurrentUser) ...[
              Container(
                width: 28,
                height: 28,
                margin: const EdgeInsets.only(left: 8, bottom: 4),
                decoration: BoxDecoration(
                  color: Colors.blue[600],
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, size: 16, color: Colors.white),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Enhanced message input with accessibility
  Widget messageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Additional options button
            Semantics(
              label: 'Tùy chọn thêm',
              child: Container(
                width: 40,
                height: 40,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(Icons.add, color: Colors.grey[600]),
                  onPressed: () {
                    // Show attachment options
                    _showAttachmentOptions();
                  },
                ),
              ),
            ),

            // Text input field
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Semantics(
                        label: 'Nhập tin nhắn',
                        textField: true,
                        child: TextField(
                          controller: messageController,
                          focusNode: _messageFocusNode,
                          decoration: const InputDecoration(
                            hintText: "Nhập tin nhắn...",
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
                          style: const TextStyle(fontSize: 16),
                          maxLines: null,
                          textCapitalization: TextCapitalization.sentences,
                          onSubmitted: (_) => senMessage(),
                        ),
                      ),
                    ),

                    // Emoji button
                    Semantics(
                      label: 'Chọn emoji',
                      child: IconButton(
                        icon: Icon(
                          Icons.emoji_emotions_outlined,
                          color: Colors.grey[600],
                        ),
                        onPressed: () {
                          // Show emoji picker
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Tính năng emoji')),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Send/Voice button
            Semantics(
              label: messageController.text.isEmpty
                  ? 'Ghi âm tin nhắn thoại'
                  : 'Gửi tin nhắn',
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue[600]!, Colors.blue[500]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: () {
                    if (messageController.text.isNotEmpty) {
                      senMessage();
                    } else {
                      // Voice message functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tính năng tin nhắn thoại'),
                        ),
                      );
                    }
                  },
                  icon: Icon(
                    messageController.text.isEmpty ? Icons.mic : Icons.send,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Show attachment options
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
                  () => Navigator.pop(context),
                ),
                _buildAttachmentOption(
                  Icons.camera_alt,
                  'Máy ảnh',
                  Colors.red,
                  () => Navigator.pop(context),
                ),
                _buildAttachmentOption(
                  Icons.insert_drive_file,
                  'Tài liệu',
                  Colors.blue,
                  () => Navigator.pop(context),
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
}
