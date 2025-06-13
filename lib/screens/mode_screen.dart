// import 'package:demo_nckh/services/authentication/auth_service.dart';
// import 'package:demo_nckh/screens/chatting_screen.dart';
// import 'package:demo_nckh/services/authentication/chatting/chatting_service.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart'; // thêm dòng này
// import '../animation/animation.dart';
// import '../services/authentication/auth_gate.dart'; // đảm bảo có file này để quay lại sau khi sign out
// import 'speak_screen.dart';
// import 'package:flutter_tts/flutter_tts.dart';

// class ModeScreen extends StatefulWidget {
//   const ModeScreen({super.key});

//   @override
//   State<ModeScreen> createState() => _ModeScreenState();
// }

// class _ModeScreenState extends State<ModeScreen> {
//   final FlutterTts flutterTts = FlutterTts();
//   final ChattingService chattingService = ChattingService();
//   final AuthService authService = AuthService();
//   void logout() {
//     // Get auth service
//     final auth = AuthService();
//     auth.signOut();
//   }

//   void _confirmLogout() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Đăng xuất tài khoản'),
//         content: Text('Bạn có chắc chắn muốn đăng xuất không?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text('Hủy', style: TextStyle(fontWeight: FontWeight.bold)),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               authService.signOut();
//             },
//             child: Text(
//               'Đăng xuất',
//               style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final Size s = MediaQuery.of(context).size;
//     return Scaffold(
//       backgroundColor: const Color.fromARGB(255, 255, 255, 255),
//       appBar: PreferredSize(
//         preferredSize: const Size.fromHeight(kToolbarHeight),
//         child: ClipRRect(
//           borderRadius: const BorderRadius.only(
//             bottomLeft: Radius.circular(30),
//             bottomRight: Radius.circular(30),
//           ),
//           child: AppBar(
//             iconTheme: const IconThemeData(color: Colors.white),
//             centerTitle: true,
//             elevation: 4,
//             backgroundColor: Colors.blue,
//             title: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//               decoration: BoxDecoration(
//                 color: Colors.blue[100],
//                 borderRadius: BorderRadius.circular(8),
//                 boxShadow: [
//                   const BoxShadow(
//                     color: Colors.grey,
//                     offset: Offset(2, 2),
//                     blurRadius: 4,
//                     spreadRadius: 1,
//                   ),
//                 ],
//               ),
//               child: const Text(
//                 "WELCOME TO CHATTING",
//                 style: TextStyle(
//                   color: Colors.blue,
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//             // Logout button
//             actions: [
//               IconButton(
//                 icon: const Icon(Icons.logout, color: Colors.white),
//                 tooltip: 'Sign out',
//                 onPressed: () async {
//                   _confirmLogout(); // Hiển thị hộp thoại xác nhận đăng xuất
//                   // await FirebaseAuth.instance.signOut();
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//       body: Stack(
//         children: [
//           Positioned(
//             top: s.height * .15,
//             width: s.width,
//             child: const LogoAnimation(),
//           ),
//           Positioned(
//             bottom: s.height * 0.10,
//             width: s.width * 0.9,
//             height: s.height * 0.06,
//             left: s.width * 0.05,
//             child: ElevatedButton.icon(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.lightBlue.shade300,
//                 shape: const StadiumBorder(),
//                 elevation: 1,
//               ),
//               onPressed: () async {
//                 await flutterTts.awaitSpeakCompletion(
//                   true,
//                 ); // Kích hoạt chờ nói xong
//                 await flutterTts.speak("Đang vào chế độ cho người khiếm thị");
//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(builder: (_) => const SpeakScreen()),
//                 );
//               },
//               icon: Image.asset('images/eyes.png', height: s.height * 0.05),
//               label: const Text(
//                 'Visually Impaired People',
//                 style: TextStyle(
//                   color: Colors.black,
//                   fontSize: 19,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),
//           ),
//           Positioned(
//             bottom: s.height * 0.20,
//             width: s.width * 0.9,
//             height: s.height * 0.06,
//             left: s.width * 0.05,
//             child: ElevatedButton.icon(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.lightBlue.shade300,
//                 shape: const StadiumBorder(),
//                 elevation: 1,
//               ),
//               onPressed: () async {
//                 await flutterTts.awaitSpeakCompletion(
//                   true,
//                 ); // Kích hoạt chờ nói xong
//                 await flutterTts.speak("Đang vào chế độ cho người khiếm thính");
//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(builder: (_) => ChattingScreen()),
//                 );
//               },
//               icon: Image.asset('images/ear.png', height: s.height * 0.05),
//               label: const Text(
//                 'Hearing Impaired People',
//                 style: TextStyle(
//                   color: Colors.black,
//                   fontSize: 19,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:demo_nckh/services/authentication/auth_service.dart';
import 'package:demo_nckh/screens/chatting_screen.dart';
import 'package:demo_nckh/services/authentication/chatting/chatting_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../animation/animation.dart';
import '../services/authentication/auth_gate.dart';
import 'speak_screen.dart';
import 'package:flutter_tts/flutter_tts.dart';

class ModeScreen extends StatefulWidget {
  const ModeScreen({super.key});

  @override
  State<ModeScreen> createState() => _ModeScreenState();
}

class _ModeScreenState extends State<ModeScreen> with TickerProviderStateMixin {
  final FlutterTts flutterTts = FlutterTts();
  final ChattingService chattingService = ChattingService();
  final AuthService authService = AuthService();
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.logout, color: Colors.red.shade400, size: 24),
            ),
            const SizedBox(width: 12),
            const Text(
              'Đăng xuất',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        content: const Text(
          'Bạn có chắc chắn muốn đăng xuất khỏi ứng dụng không?',
          style: TextStyle(fontSize: 16, color: Colors.black54, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Hủy',
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const AuthGate()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Đăng xuất',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeCard({
    required String title,
    required String description,
    required String iconPath,
    required VoidCallback onTap,
    required Color primaryColor,
    required Color lightColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(24),
        shadowColor: primaryColor.withOpacity(0.3),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, lightColor.withOpacity(0.1)],
              ),
              border: Border.all(color: lightColor.withOpacity(0.3), width: 1),
            ),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [primaryColor, primaryColor.withOpacity(0.8)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Image.asset(
                      iconPath,
                      height: 32,
                      width: 32,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 20, height: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: lightColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: primaryColor,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size s = MediaQuery.of(context).size;

    // return Scaffold(
    //   backgroundColor: const Color(0xFFF8FAFC),
    //   body: SafeArea(
    //     child: Column(
    //       children: [
    //         // Header
    //         Container(
    //           padding: const EdgeInsets.all(20),
    //           decoration: BoxDecoration(
    //             gradient: const LinearGradient(
    //               begin: Alignment.topLeft,
    //               end: Alignment.bottomRight,
    //               colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
    //             ),
    //             boxShadow: [
    //               BoxShadow(
    //                 color: const Color(0xFF667EEA).withOpacity(0.3),
    //                 blurRadius: 20,
    //                 offset: const Offset(0, 10),
    //               ),
    //             ],
    //           ),
    //           child: Column(
    //             children: [
    //               Row(
    //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                 children: [
    //                   const Text(
    //                     'Chào mừng!',
    //                     style: TextStyle(
    //                       color: Colors.white,
    //                       fontSize: 28,
    //                       fontWeight: FontWeight.bold,
    //                       letterSpacing: 0.5,
    //                     ),
    //                   ),
    //                   Material(
    //                     color: Colors.white.withOpacity(0.2),
    //                     borderRadius: BorderRadius.circular(12),
    //                     child: InkWell(
    //                       onTap: _confirmLogout,
    //                       borderRadius: BorderRadius.circular(12),
    //                       child: Container(
    //                         padding: const EdgeInsets.all(12),
    //                         child: const Icon(
    //                           Icons.logout_rounded,
    //                           color: Colors.white,
    //                           size: 24,
    //                         ),
    //                       ),
    //                     ),
    //                   ),
    //                 ],
    //               ),
    //               const SizedBox(height: 12),
    //               Container(
    //                 alignment: Alignment.centerLeft,
    //                 child: Text(
    //                   'Chọn chế độ phù hợp với bạn',
    //                   style: TextStyle(
    //                     color: Colors.white.withOpacity(0.9),
    //                     fontSize: 16,
    //                     fontWeight: FontWeight.w400,
    //                   ),
    //                 ),
    //               ),
    //             ],
    //           ),
    //         ),

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                ),
                borderRadius: BorderRadius.circular(20), // Bo 4 góc
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF667EEA).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              margin: const EdgeInsets.all(
                16,
              ), // Thêm margin để tạo khoảng cách
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Chào mừng!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Material(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          onTap: _confirmLogout,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            child: const Icon(
                              Icons.logout_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Chọn chế độ phù hợp với bạn',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Logo Animation
            Expanded(
              flex: 2,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: const Center(child: LogoAnimation()),
              ),
            ),

            // Mode Selection Cards
            Expanded(
              flex: 3,
              child: SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildModeCard(
                        title: 'Người khiếm thính',
                        description: 'Giao tiếp bằng văn bản và hình ảnh',
                        iconPath: 'images/ear.png',
                        primaryColor: const Color(0xFF4F46E5),
                        lightColor: const Color(0xFF818CF8),
                        onTap: () async {
                          await flutterTts.awaitSpeakCompletion(true);
                          await flutterTts.speak(
                            "Đang vào chế độ cho người khiếm thính",
                          );
                          Navigator.pushReplacement(
                            context,
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      ChattingScreen(),
                              transitionsBuilder:
                                  (
                                    context,
                                    animation,
                                    secondaryAnimation,
                                    child,
                                  ) {
                                    return SlideTransition(
                                      position: animation.drive(
                                        Tween(
                                          begin: const Offset(1.0, 0.0),
                                          end: Offset.zero,
                                        ).chain(
                                          CurveTween(curve: Curves.easeInOut),
                                        ),
                                      ),
                                      child: child,
                                    );
                                  },
                              transitionDuration: const Duration(
                                milliseconds: 300,
                              ),
                            ),
                          );
                        },
                      ),

                      _buildModeCard(
                        title: 'Người khiếm thị',
                        description: 'Giao tiếp bằng giọng nói và âm thanh',
                        iconPath: 'images/eyes.png',
                        primaryColor: const Color(0xFF059669),
                        lightColor: const Color(0xFF34D399),
                        onTap: () async {
                          await flutterTts.awaitSpeakCompletion(true);
                          await flutterTts.speak(
                            "Đang vào chế độ cho người khiếm thị",
                          );
                          Navigator.pushReplacement(
                            context,
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      const SpeakScreen(),
                              transitionsBuilder:
                                  (
                                    context,
                                    animation,
                                    secondaryAnimation,
                                    child,
                                  ) {
                                    return SlideTransition(
                                      position: animation.drive(
                                        Tween(
                                          begin: const Offset(1.0, 0.0),
                                          end: Offset.zero,
                                        ).chain(
                                          CurveTween(curve: Curves.easeInOut),
                                        ),
                                      ),
                                      child: child,
                                    );
                                  },
                              transitionDuration: const Duration(
                                milliseconds: 300,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
