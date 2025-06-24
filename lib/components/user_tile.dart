import 'package:flutter/material.dart';

// UserTile để hiển thị thông tin người dùng
class UserTile extends StatelessWidget {
  final String email; // Email người dùng
  final String lastSeen; // Thời gian truy cập cuối cùng
  final bool isOnline; // Trạng thái trực tuyến
  final void Function()? onTap; // Hàm callback khi nhấn

  const UserTile({
    super.key,
    required this.email,
    required this.lastSeen,
    required this.isOnline,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 6,
        ), // Khoảng cách bên ngoài
        padding: const EdgeInsets.all(12), // Khoảng cách bên trong
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300, // Màu bóng
              blurRadius: 5, // Độ mờ bóng
              offset: const Offset(2, 2), // Vị trí bóng
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar với chấm trạng thái online
            Stack(
              children: [
                const CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: isOnline
                          ? Colors.green
                          : Colors.grey, // Màu xanh nếu online, xám nếu offline
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ), // Viền trắng
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(width: 16), // Khoảng cách giữa avatar và thông tin
            // Thông tin người dùng
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // Căn trái
                children: [
                  Text(
                    email,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isOnline
                        ? "Đang hoạt động"
                        : "Truy cập gần nhất: $lastSeen",
                    style: TextStyle(
                      fontSize: 13,
                      color: isOnline ? Colors.green : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
