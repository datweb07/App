import 'package:flutter/material.dart';

// LogoAnimation tạo hiệu ứng di chuyển logo
class LogoAnimation extends StatefulWidget {
  const LogoAnimation({super.key});

  @override
  State<LogoAnimation> createState() => _LogoAnimationState();
}

// Lớp quản lý hiệu ứng
class _LogoAnimationState extends State<LogoAnimation>
    with TickerProviderStateMixin {
  // AnimationController quản lý thời gian và trạng thái của animation
  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 2), // Thời gian mỗi chu kỳ
    vsync: this, // Đồng bộ với widget
  )..repeat(reverse: true); // Lặp lại animation

  // Animation chuyển động từ trái sang phải
  late final Animation<AlignmentGeometry> _animation = Tween<AlignmentGeometry>(
    begin: Alignment.bottomLeft,
    end: Alignment.bottomRight,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.decelerate));

  // Giải phóng tài nguyên khi widget bị hủy
  @override
  void dispose() {
    _controller.dispose(); // Hủy controller
    super.dispose();
  }

  // Tạo giao diện animation
  @override
  Widget build(BuildContext context) {
    return AlignTransition(
      alignment: _animation,
      child: Padding(
        padding: const EdgeInsets.all(8.0), // Khoảng cách xung quanh logo
        child: Image.asset('images/smiley-face.png', width: 150),
      ),
    );
  }
}
