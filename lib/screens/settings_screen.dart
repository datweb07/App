// import 'package:demo_nckh/themes/change_theme.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:provider/provider.dart';

// class Settingssreen extends StatefulWidget {
//   const Settingssreen({super.key});

//   @override
//   State<Settingssreen> createState() => _SettingsScreenState();
// }

// class _SettingsScreenState extends State<Settingssreen> {
//   bool _highContrast = false;
//   bool _largeText = false;
//   bool _screenReader = true;
//   bool _vibration = true;
//   bool _soundEffects = true;
//   double _textSize = 1.0;
//   bool _voiceNavigation = false;

//   void _showAccessibilityDialog() {
//     showDialog(
//       context: context,
//       // accessibilityLabel: "Hộp thoại cài đặt hỗ trợ tiếp cận",
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         title: const Text(
//           'Hỗ trợ tiếp cận',
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         content: const Text(
//           'Các tùy chọn này giúp cải thiện trải nghiệm cho người khiếm thị và khiếm thính.',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Đã hiểu'),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSettingTile({
//     required String title,
//     required String subtitle,
//     required IconData icon,
//     Widget? trailing,
//     VoidCallback? onTap,
//     String? semanticLabel,
//   }) {
//     return Semantics(
//       label: semanticLabel ?? title,
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 12),
//         decoration: BoxDecoration(
//           color: Theme.of(context).cardColor,
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 10,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: ListTile(
//           contentPadding: const EdgeInsets.symmetric(
//             horizontal: 20,
//             vertical: 8,
//           ),
//           leading: Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: Theme.of(context).primaryColor.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Icon(icon, color: Theme.of(context).primaryColor, size: 24),
//           ),
//           title: Text(
//             title,
//             style: TextStyle(
//               fontWeight: FontWeight.w600,
//               fontSize: 16 * _textSize,
//               color: _highContrast ? Colors.black : null,
//             ),
//           ),
//           subtitle: subtitle.isNotEmpty
//               ? Text(
//                   subtitle,
//                   style: TextStyle(
//                     fontSize: 14 * _textSize,
//                     color: _highContrast ? Colors.grey[700] : Colors.grey[600],
//                   ),
//                 )
//               : null,
//           trailing: trailing,
//           onTap: onTap != null
//               ? () {
//                   if (_vibration) {
//                     HapticFeedback.lightImpact();
//                   }
//                   if (_soundEffects) {
//                     SystemSound.play(SystemSoundType.click);
//                   }
//                   onTap();
//                 }
//               : null,
//         ),
//       ),
//     );
//   }

//   Widget _buildSectionHeader(String title) {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
//       child: Text(
//         title,
//         style: TextStyle(
//           fontSize: 18 * _textSize,
//           fontWeight: FontWeight.bold,
//           color: Theme.of(context).primaryColor,
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final themeProvider = Provider.of<ChangeTheme>(context);

//     return Scaffold(
//       backgroundColor: _highContrast
//           ? Colors.white
//           : Theme.of(context).scaffoldBackgroundColor,
//       appBar: PreferredSize(
//         preferredSize: const Size.fromHeight(kToolbarHeight + 10),
//         child: Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: [
//                 Theme.of(context).primaryColor,
//                 Theme.of(context).primaryColor.withOpacity(0.8),
//               ],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//             borderRadius: const BorderRadius.only(
//               bottomLeft: Radius.circular(25),
//               bottomRight: Radius.circular(25),
//             ),
//           ),
//           child: AppBar(
//             backgroundColor: Colors.transparent,
//             elevation: 0,
//             leading: Semantics(
//               label: "Nút quay lại",
//               child: IconButton(
//                 icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
//                 onPressed: () {
//                   if (_vibration) HapticFeedback.lightImpact();
//                   Navigator.pop(context);
//                 },
//               ),
//             ),
//             title: Text(
//               'Cài đặt',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold,
//                 fontSize: 20 * _textSize,
//               ),
//             ),
//             actions: [
//               Semantics(
//                 label: "Thông tin về hỗ trợ tiếp cận",
//                 child: IconButton(
//                   icon: const Icon(Icons.info_outline, color: Colors.white),
//                   onPressed: _showAccessibilityDialog,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//       body: ListView(
//         children: [
//           _buildSectionHeader('Giao diện'),

//           _buildSettingTile(
//             title: 'Chế độ tối',
//             subtitle: 'Thay đổi giao diện sáng/tối',
//             icon: themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
//             semanticLabel:
//                 'Chuyển đổi chế độ tối, hiện tại ${themeProvider.isDarkMode ? "bật" : "tắt"}',
//             trailing: CupertinoSwitch(
//               value: themeProvider.isDarkMode,
//               onChanged: (value) {
//                 if (_vibration) HapticFeedback.selectionClick();
//                 themeProvider.toggleTheme(value);
//               },
//             ),
//           ),

//           _buildSettingTile(
//             title: 'Độ tương phản cao',
//             subtitle: 'Tăng độ tương phản cho người khiếm thị',
//             icon: Icons.contrast,
//             semanticLabel:
//                 'Độ tương phản cao, hiện tại ${_highContrast ? "bật" : "tắt"}',
//             trailing: CupertinoSwitch(
//               value: _highContrast,
//               onChanged: (value) {
//                 if (_vibration) HapticFeedback.selectionClick();
//                 setState(() => _highContrast = value);
//               },
//             ),
//           ),

//           _buildSettingTile(
//             title: 'Kích thước chữ',
//             subtitle: 'Điều chỉnh kích thước văn bản',
//             icon: Icons.text_fields,
//             semanticLabel:
//                 'Kích thước chữ hiện tại ${(_textSize * 100).round()}%',
//             trailing: SizedBox(
//               width: 120,
//               child: Slider(
//                 value: _textSize,
//                 min: 0.8,
//                 max: 1.5,
//                 divisions: 7,
//                 label: '${(_textSize * 100).round()}%',
//                 onChanged: (value) {
//                   if (_vibration) HapticFeedback.selectionClick();
//                   setState(() => _textSize = value);
//                 },
//               ),
//             ),
//           ),

//           _buildSectionHeader('Hỗ trợ người khiếm thị'),

//           _buildSettingTile(
//             title: 'Đọc màn hình',
//             subtitle: 'Kích hoạt tính năng đọc nội dung',
//             icon: Icons.record_voice_over,
//             semanticLabel:
//                 'Đọc màn hình, hiện tại ${_screenReader ? "bật" : "tắt"}',
//             trailing: CupertinoSwitch(
//               value: _screenReader,
//               onChanged: (value) {
//                 if (_vibration) HapticFeedback.selectionClick();
//                 setState(() => _screenReader = value);
//               },
//             ),
//           ),

//           _buildSettingTile(
//             title: 'Điều hướng bằng giọng nói',
//             subtitle: 'Sử dụng giọng nói để điều khiển',
//             icon: Icons.mic,
//             semanticLabel:
//                 'Điều hướng bằng giọng nói, hiện tại ${_voiceNavigation ? "bật" : "tắt"}',
//             trailing: CupertinoSwitch(
//               value: _voiceNavigation,
//               onChanged: (value) {
//                 if (_vibration) HapticFeedback.selectionClick();
//                 setState(() => _voiceNavigation = value);
//               },
//             ),
//           ),

//           _buildSectionHeader('Hỗ trợ người khiếm thính'),

//           _buildSettingTile(
//             title: 'Rung phản hồi',
//             subtitle: 'Rung khi tương tác với giao diện',
//             icon: Icons.vibration,
//             semanticLabel:
//                 'Rung phản hồi, hiện tại ${_vibration ? "bật" : "tắt"}',
//             trailing: CupertinoSwitch(
//               value: _vibration,
//               onChanged: (value) {
//                 setState(() => _vibration = value);
//                 if (value) HapticFeedback.mediumImpact();
//               },
//             ),
//           ),

//           _buildSettingTile(
//             title: 'Hiệu ứng âm thanh',
//             subtitle: 'Phát âm thanh khi tương tác',
//             icon: _soundEffects ? Icons.volume_up : Icons.volume_off,
//             semanticLabel:
//                 'Hiệu ứng âm thanh, hiện tại ${_soundEffects ? "bật" : "tắt"}',
//             trailing: CupertinoSwitch(
//               value: _soundEffects,
//               onChanged: (value) {
//                 if (_vibration) HapticFeedback.selectionClick();
//                 setState(() => _soundEffects = value);
//               },
//             ),
//           ),

//           _buildSettingTile(
//             title: 'Phụ đề trò chuyện',
//             subtitle: 'Hiển thị phụ đề cho tin nhắn thoại',
//             icon: Icons.closed_caption,
//             semanticLabel: 'Phụ đề trò chuyện',
//             onTap: () {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(
//                   content: const Text(
//                     'Tính năng sẽ có trong phiên bản tiếp theo',
//                   ),
//                   behavior: SnackBarBehavior.floating,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//               );
//             },
//           ),

//           _buildSectionHeader('Khác'),

//           _buildSettingTile(
//             title: 'Phím tắt',
//             subtitle: 'Cấu hình phím tắt bàn phím',
//             icon: Icons.keyboard,
//             semanticLabel: 'Cài đặt phím tắt',
//             onTap: () {
//               // Navigate to keyboard shortcuts settings
//             },
//           ),

//           _buildSettingTile(
//             title: 'Báo cáo lỗi tiếp cận',
//             subtitle: 'Gửi phản hồi về khả năng tiếp cận',
//             icon: Icons.bug_report,
//             semanticLabel: 'Báo cáo lỗi về khả năng tiếp cận',
//             onTap: () {
//               // Open feedback form
//             },
//           ),

//           const SizedBox(height: 20),
//         ],
//       ),
//       floatingActionButton: _voiceNavigation
//           ? Semantics(
//               label: "Nút kích hoạt điều khiển giọng nói",
//               child: FloatingActionButton(
//                 onPressed: () {
//                   if (_vibration) HapticFeedback.mediumImpact();
//                   // Implement voice control
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: const Text(
//                         '🎤 Nói "quay lại" để về trang trước',
//                       ),
//                       behavior: SnackBarBehavior.floating,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                   );
//                 },
//                 child: const Icon(Icons.mic),
//               ),
//             )
//           : null,
//     );
//   }
// }
// settings_screen.dart
import 'package:demo_nckh/themes/change_theme.dart';
import 'package:demo_nckh/accessibility_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class Settingssreen extends StatelessWidget {
  const Settingssreen({super.key});

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

  Widget _buildSettingTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    Widget? trailing,
    VoidCallback? onTap,
    String? semanticLabel,
  }) {
    final accessibilityProvider = Provider.of<AccessibilityProvider>(context);

    return Semantics(
      label: semanticLabel ?? title,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: accessibilityProvider.getBackgroundColor(context),
          borderRadius: BorderRadius.circular(16),
          border: accessibilityProvider.highContrast
              ? Border.all(color: Colors.grey, width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
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
              : null,
          trailing: trailing,
          onTap: onTap != null
              ? () {
                  if (accessibilityProvider.vibration) {
                    HapticFeedback.lightImpact();
                  }
                  if (accessibilityProvider.soundEffects) {
                    SystemSound.play(SystemSoundType.click);
                  }
                  onTap();
                }
              : null,
        ),
      ),
    );
  }

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

  @override
  Widget build(BuildContext context) {
    return Consumer2<ChangeTheme, AccessibilityProvider>(
      builder: (context, themeProvider, accessibilityProvider, child) {
        return Scaffold(
          backgroundColor: accessibilityProvider.getBackgroundColor(context),
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight + 10),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
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
                        HapticFeedback.lightImpact();
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
              _buildSectionHeader(context, 'Giao diện'),

              _buildSettingTile(
                context: context,
                title: 'Chế độ tối',
                subtitle: 'Thay đổi giao diện sáng/tối',
                icon: themeProvider.isDarkMode
                    ? Icons.dark_mode
                    : Icons.light_mode,
                semanticLabel:
                    'Chuyển đổi chế độ tối, hiện tại ${themeProvider.isDarkMode ? "bật" : "tắt"}',
                trailing: CupertinoSwitch(
                  value: themeProvider.isDarkMode,
                  onChanged: (value) {
                    if (accessibilityProvider.vibration) {
                      HapticFeedback.selectionClick();
                    }
                    themeProvider.toggleTheme(value);
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
                    accessibilityProvider.setHighContrast(value);
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
                    accessibilityProvider.setVoiceNavigation(value);
                  },
                ),
              ),

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
                    accessibilityProvider.setVibration(value);
                    if (value) HapticFeedback.mediumImpact();
                  },
                ),
              ),

              const SizedBox(height: 20),

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
                        HapticFeedback.mediumImpact();
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
                      );
                    },
                    child: const Icon(Icons.mic),
                  ),
                )
              : null,
        );
      },
    );
  }
}
