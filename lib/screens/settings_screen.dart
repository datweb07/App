import 'package:demo_nckh/themes/change_theme.dart';
import 'package:demo_nckh/accessibility_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

// SettingScreen hiển thị màn hình cài đặt
class Settingssreen extends StatelessWidget {
  const Settingssreen({super.key});

  // Hộp thoại giải thích về hỗ trợ tiếp cận
  void _showAccessibilityDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Accessibility support',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Những cài đặt này giúp hỗ trợ phần nào cho người khiếm thính và khiếm thị. Các tùy chọn khác có thể được phát triển trong tương lai.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đã hiểu'),
          ),
        ],
      ),
    );
  }

  // Tạo widget cho mỗi chức năng
  Widget _buildSettingTile({
    required BuildContext context,
    required String title,
    required String subtitle, // Mô tả
    required IconData icon,
    Widget? trailing, // Nút chuyển đổi, thanh trượt,...
    VoidCallback? onTap,
    String? semanticLabel,
  }) {
    final accessibilityProvider = Provider.of<AccessibilityProvider>(context);

    return Semantics(
      label: semanticLabel ?? title,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12), // Khoảng cách dưới
        decoration: BoxDecoration(
          color: accessibilityProvider.getBackgroundColor(context),
          borderRadius: BorderRadius.circular(16),
          border: accessibilityProvider.highContrast
              ? Border.all(color: Colors.grey, width: 2)
              : null, // Viền nếu bật độ tương phản cao
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05), // Đổ bóng
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 8,
          ),
          // Khoảng cách nội dung
          leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Theme.of(context).primaryColor, size: 24),
          ),
          title: Text(
            title,
            style: accessibilityProvider.getTextStyle(
              context,
              baseStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ),
          subtitle: subtitle.isNotEmpty
              ? Text(
                  subtitle,
                  style: accessibilityProvider.getTextStyle(
                    context,
                    baseStyle: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                )
              : null, // Hiển thị mô tả (nếu có)
          trailing: trailing, // Widget bên phải
          onTap: onTap != null
              ? () {
                  if (accessibilityProvider.vibration) {
                    HapticFeedback.lightImpact(); // Rung nhẹ nếu bật
                  }
                  if (accessibilityProvider.soundEffects) {
                    SystemSound.play(SystemSoundType.click); // Âm thanh nếu bật
                  }
                  onTap();
                }
              : null,
        ),
      ),
    );
  }

  // Tiên đề cho các chức năng
  Widget _buildSectionHeader(BuildContext context, String title) {
    final accessibilityProvider = Provider.of<AccessibilityProvider>(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Text(
        title,
        style: accessibilityProvider.getTextStyle(
          context,
          baseStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ),
    );
  }

  // Tạo giao diện
  @override
  Widget build(BuildContext context) {
    return Consumer2<ChangeTheme, AccessibilityProvider>(
      builder: (context, themeProvider, accessibilityProvider, child) {
        return Scaffold(
          backgroundColor: accessibilityProvider.getBackgroundColor(
            context,
          ), // Màu nền
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight + 10),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withOpacity(0.8),
                  ], // Gradient cho AppBar
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ), // Bo góc dưới AppBar
              ),
              child: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: Semantics(
                  label: "Nút quay lại",
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      if (accessibilityProvider.vibration) {
                        HapticFeedback.lightImpact(); // Rung khi nhấn
                      }
                      Navigator.pop(context);
                    },
                  ),
                ),
                title: Text(
                  'Cài đặt',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20 * accessibilityProvider.textSize,
                  ),
                ),
                actions: [
                  Semantics(
                    label: "Thông tin về hỗ trợ tiếp cận",
                    child: IconButton(
                      icon: const Icon(Icons.info_outline, color: Colors.white),
                      onPressed: () => _showAccessibilityDialog(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
          body: ListView(
            children: [
              // Phần giao diện
              _buildSectionHeader(context, 'Giao diện'),

              _buildSettingTile(
                context: context,
                title: 'Chế độ tối',
                subtitle: 'Thay đổi giao diện sáng/tối',
                icon: themeProvider.isDarkMode
                    ? Icons.dark_mode
                    : Icons.light_mode, // Biểu tượng theo chế độ
                semanticLabel:
                    'Chuyển đổi chế độ tối, hiện tại ${themeProvider.isDarkMode ? "bật" : "tắt"}',
                trailing: CupertinoSwitch(
                  value: themeProvider.isDarkMode,
                  onChanged: (value) {
                    if (accessibilityProvider.vibration) {
                      HapticFeedback.selectionClick(); // Rung khi chuyển đổi
                    }
                    themeProvider.toggleTheme(value); // Chuyển sang dark mode
                  },
                ),
              ),

              _buildSettingTile(
                context: context,
                title: 'Độ tương phản cao',
                subtitle: 'Tăng độ tương phản cho người khiếm thị',
                icon: Icons.contrast,
                semanticLabel:
                    'Độ tương phản cao, hiện tại ${accessibilityProvider.highContrast ? "bật" : "tắt"}',
                trailing: CupertinoSwitch(
                  value: accessibilityProvider.highContrast,
                  onChanged: (value) {
                    if (accessibilityProvider.vibration) {
                      HapticFeedback.selectionClick();
                    }
                    accessibilityProvider.setHighContrast(
                      value,
                    ); // Bật/tắt độ tương phản
                  },
                ),
              ),

              _buildSettingTile(
                context: context,
                title: 'Kích thước chữ',
                subtitle: 'Điều chỉnh kích thước văn bản',
                icon: Icons.text_fields,
                semanticLabel:
                    'Kích thước chữ hiện tại ${(accessibilityProvider.textSize * 100).round()}%',
                trailing: SizedBox(
                  width: 120,
                  child: Slider(
                    value: accessibilityProvider.textSize,
                    min: 0.8,
                    max: 1.5,
                    divisions: 7,
                    label: '${(accessibilityProvider.textSize * 100).round()}%',
                    onChanged: (value) {
                      if (accessibilityProvider.vibration) {
                        HapticFeedback.selectionClick();
                      }
                      accessibilityProvider.setTextSize(value);
                    },
                  ),
                ),
              ),

              // Phần hỗ trợ người khiếm thị
              _buildSectionHeader(context, 'Hỗ trợ người khiếm thị'),

              _buildSettingTile(
                context: context,
                title: 'Điều hướng bằng giọng nói',
                subtitle: 'Sử dụng giọng nói để điều khiển',
                icon: Icons.mic,
                semanticLabel:
                    'Điều hướng bằng giọng nói, hiện tại ${accessibilityProvider.voiceNavigation ? "bật" : "tắt"}',
                trailing: CupertinoSwitch(
                  value: accessibilityProvider.voiceNavigation,
                  onChanged: (value) {
                    if (accessibilityProvider.vibration) {
                      HapticFeedback.selectionClick();
                    }
                    accessibilityProvider.setVoiceNavigation(
                      value,
                    ); // Bật/tắt điều hướng
                  },
                ),
              ),

              // Phần hỗ trợ người khiếm thị
              _buildSectionHeader(context, 'Hỗ trợ người khiếm thính'),

              _buildSettingTile(
                context: context,
                title: 'Rung phản hồi',
                subtitle: 'Rung khi tương tác với giao diện',
                icon: Icons.vibration,
                semanticLabel:
                    'Rung phản hồi, hiện tại ${accessibilityProvider.vibration ? "bật" : "tắt"}',
                trailing: CupertinoSwitch(
                  value: accessibilityProvider.vibration,
                  onChanged: (value) {
                    accessibilityProvider.setVibration(value); // Bật/tắt rung
                    if (value) HapticFeedback.mediumImpact(); // Rung khi bật
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Phần phát triển trong tương lai
              _buildSectionHeader(context, 'Phát triển trong tương lai'),

              _buildSettingTile(
                context: context,
                title: 'Đọc màn hình',
                subtitle: 'Kích hoạt tính năng đọc nội dung',
                icon: Icons.record_voice_over,
                // semanticLabel:
                //     'Đọc màn hình, hiện tại ${accessibilityProvider.screenReader ? "bật" : "tắt"}',
                // trailing: CupertinoSwitch(
                //   value: accessibilityProvider.screenReader,
                //   onChanged: (value) {
                //     if (accessibilityProvider.vibration) {
                //       HapticFeedback.selectionClick();
                //     }
                //     accessibilityProvider.setScreenReader(value);
                //   },
                // ),
              ),
              _buildSettingTile(
                context: context,
                title: 'Hiệu ứng âm thanh',
                subtitle: 'Phát âm thanh khi tương tác',
                icon: accessibilityProvider.soundEffects
                    ? Icons.volume_up
                    : Icons.volume_off,
                // semanticLabel:
                //     'Hiệu ứng âm thanh, hiện tại ${accessibilityProvider.soundEffects ? "bật" : "tắt"}',
                // trailing: CupertinoSwitch(
                //   value: accessibilityProvider.soundEffects,
                //   onChanged: (value) {
                //     if (accessibilityProvider.vibration) {
                //       HapticFeedback.selectionClick();
                //     }
                //     accessibilityProvider.setSoundEffects(value);
                //   },
                // ),
              ),
            ],
          ),
          floatingActionButton: accessibilityProvider.voiceNavigation
              ? Semantics(
                  label: "Nút kích hoạt điều khiển giọng nói",
                  child: FloatingActionButton(
                    onPressed: () {
                      if (accessibilityProvider.vibration) {
                        HapticFeedback.mediumImpact(); // Rung khi nhấn
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                            '🎤 Nói "quay lại" để về trang trước',
                          ),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ); // Hiển thị thông báo hướng dẫn
                    },
                    child: const Icon(Icons.mic),
                  ),
                )
              : null, // Hiển thị nút mic nếu bật điều hướng giọng nói
        );
      },
    );
  }
}
