// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:demo_nckh/components/user_tile.dart';
// import 'package:demo_nckh/screens/chatting.dart';
// import 'package:demo_nckh/services/authentication/chatting/chatting_service.dart';
// import 'package:flutter/material.dart';

// class UserSearchDelegate extends SearchDelegate {
//   final ChattingService chattingService;

//   UserSearchDelegate(this.chattingService);

//   @override
//   List<Widget>? buildActions(BuildContext context) {
//     return [IconButton(onPressed: () => query = '', icon: Icon(Icons.clear))];
//   }

//   @override
//   Widget? buildLeading(BuildContext context) {
//     return IconButton(
//       onPressed: () => close(context, null),
//       icon: Icon(Icons.arrow_back),
//     );
//   }

//   @override
//   Widget buildResults(BuildContext context) {
//     return StreamBuilder(
//       stream: chattingService.getUserStream(),
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) {
//           return Center(child: CircularProgressIndicator());
//         }

//         final users = (snapshot.data! as List).where((userData) {
//           final username = userData["email"]
//               .toString()
//               .split("@")
//               .first
//               .toLowerCase();
//           return username.contains(query.toLowerCase());
//         }).toList();

//         return ListView(
//           children: users
//               .map(
//                 (userData) => UserTile(
//                   email: userData["email"],
//                   isOnline: userData["isOnline"],
//                   lastSeen: (userData["lastSeen"] as Timestamp)
//                       .toDate()
//                       .toString(),
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => Chatting(
//                           receiverEmail: userData["email"],
//                           receiverID: userData["uid"],
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               )
//               .toList(),
//         );
//       },
//     );
//   }

//   @override
//   Widget buildSuggestions(BuildContext context) {
//     return buildResults(context);
//   }
// }
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:demo_nckh/components/user_tile.dart';
import 'package:demo_nckh/screens/chatting.dart';
import 'package:flutter/material.dart';

class UserSearchDelegate extends SearchDelegate {
  Timer? _searchTimer;
  final ValueNotifier<bool> _isSearching = ValueNotifier(false);
  final ValueNotifier<List<Map<String, dynamic>>> _searchResults =
      ValueNotifier([]);
  final ValueNotifier<String> _errorMessage = ValueNotifier('');

  @override
  String get searchFieldLabel => 'Tìm kiếm theo email hoặc username...';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      ValueListenableBuilder<bool>(
        valueListenable: _isSearching,
        builder: (context, isSearching, child) {
          if (isSearching) {
            return Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }
          return IconButton(
            onPressed: () {
              query = '';
              _searchResults.value = [];
              _errorMessage.value = '';
            },
            icon: Icon(Icons.clear),
            tooltip: 'Clear search',
          );
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        _searchTimer?.cancel();
        close(context, null);
      },
      icon: Icon(Icons.arrow_back),
      tooltip: 'Back',
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.trim().isEmpty) {
      return _buildEmptyState('Nhập email hoặc username để tìm kiếm');
    }

    // Trigger search when query changes
    _performSearch(query);

    return ValueListenableBuilder<bool>(
      valueListenable: _isSearching,
      builder: (context, isSearching, child) {
        if (isSearching) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Đang tìm kiếm...'),
              ],
            ),
          );
        }

        return ValueListenableBuilder<String>(
          valueListenable: _errorMessage,
          builder: (context, errorMessage, child) {
            if (errorMessage.isNotEmpty) {
              return _buildEmptyState(errorMessage);
            }

            return ValueListenableBuilder<List<Map<String, dynamic>>>(
              valueListenable: _searchResults,
              builder: (context, searchResults, child) {
                if (searchResults.isEmpty) {
                  return _buildEmptyState('Không tìm thấy người dùng nào');
                }

                return ListView.builder(
                  itemCount: searchResults.length,
                  itemBuilder: (context, index) {
                    final userData = searchResults[index];
                    return UserTile(
                      email: userData["email"],
                      isOnline: userData["isOnline"] ?? false,
                      lastSeen: userData["lastSeen"] != null
                          ? (userData["lastSeen"] as Timestamp)
                                .toDate()
                                .toString()
                          : 'Chưa xác định',
                      onTap: () => _navigateToChat(context, userData),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.trim().isEmpty) {
      return _buildEmptyState('Nhập email hoặc username để tìm kiếm');
    }

    return buildResults(context);
  }

  Future<void> _performSearch(String searchText) async {
    // Cancel previous search
    _searchTimer?.cancel();

    _searchTimer = Timer(Duration(milliseconds: 500), () async {
      if (searchText.trim().isEmpty) return;

      try {
        _isSearching.value = true;
        _errorMessage.value = '';

        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser == null) {
          _errorMessage.value = "Vui lòng đăng nhập để tìm kiếm";
          return;
        }

        List<QueryDocumentSnapshot> allFoundUsers = [];

        // 1. Tìm kiếm theo EMAIL chính xác
        if (searchText.contains('@')) {
          final emailQuery = await FirebaseFirestore.instance
              .collection('users')
              .where('email', isEqualTo: searchText.toLowerCase())
              .limit(5)
              .get();

          allFoundUsers.addAll(emailQuery.docs);
          print("Tìm theo email: ${emailQuery.docs.length} kết quả");
        }

        // 2. Tìm kiếm theo USERNAME (nếu có trường này)
        try {
          final usernameQuery = await FirebaseFirestore.instance
              .collection('users')
              .where(
                'username',
                isGreaterThanOrEqualTo: searchText.toLowerCase(),
              )
              .where(
                'username',
                isLessThanOrEqualTo: '${searchText.toLowerCase()}\uf8ff',
              )
              .limit(10)
              .get();

          // Thêm vào danh sách nếu chưa có
          for (var doc in usernameQuery.docs) {
            if (!allFoundUsers.any((existing) => existing.id == doc.id)) {
              allFoundUsers.add(doc);
            }
          }
          print("Tìm theo username: ${usernameQuery.docs.length} kết quả");
        } catch (e) {
          print("Không thể tìm theo username: $e");
        }

        // 3. Tìm kiếm theo EMAIL PREFIX (tìm email bắt đầu bằng searchText)
        if (!searchText.contains('@')) {
          try {
            final emailPrefixQuery = await FirebaseFirestore.instance
                .collection('users')
                .where(
                  'email',
                  isGreaterThanOrEqualTo: searchText.toLowerCase(),
                )
                .where(
                  'email',
                  isLessThanOrEqualTo: '${searchText.toLowerCase()}\uf8ff',
                )
                .limit(10)
                .get();

            // Thêm vào danh sách nếu chưa có
            for (var doc in emailPrefixQuery.docs) {
              if (!allFoundUsers.any((existing) => existing.id == doc.id)) {
                allFoundUsers.add(doc);
              }
            }
            print(
              "Tìm theo email prefix: ${emailPrefixQuery.docs.length} kết quả",
            );
          } catch (e) {
            print("Không thể tìm theo email prefix: $e");
          }
        }

        print("Tổng cộng tìm thấy: ${allFoundUsers.length} user(s)");

        if (allFoundUsers.isEmpty) {
          _errorMessage.value =
              "Không tìm thấy người dùng với từ khóa: '$searchText'";
          _searchResults.value = [];
          return;
        }

        // Filter out current user và format data
        final filteredUsers = allFoundUsers
            .where((doc) {
              final userData = doc.data() as Map<String, dynamic>;
              final userEmail = userData['email'] as String?;
              print(
                "Checking user: $userEmail vs current: ${currentUser.email}",
              );
              return userEmail != null && userEmail != currentUser.email;
            })
            .map((doc) {
              final userData = doc.data() as Map<String, dynamic>;
              final email = userData['email'] as String;

              return {
                'email': email,
                'username':
                    userData['username'] as String? ?? email.split('@').first,
                'photoURL': userData['photoURL'] as String?,
                'isOnline': userData['isOnline'] as bool? ?? false,
                'lastSeen': userData['lastSeen'] as Timestamp?,
                'uid': doc.id,
              };
            })
            .toList();

        print("Sau khi filter: ${filteredUsers.length} user(s)");

        if (filteredUsers.isEmpty) {
          _errorMessage.value = "Không thể kết bạn với chính mình";
          _searchResults.value = [];
        } else {
          _searchResults.value = filteredUsers;
          print("Hiển thị ${filteredUsers.length} kết quả");
        }
      } catch (e) {
        print("Lỗi tìm kiếm: $e");
        _errorMessage.value = _getFriendlyErrorMessage(e);
        _searchResults.value = [];
      } finally {
        _isSearching.value = false;
      }
    });
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _navigateToChat(BuildContext context, Map<String, dynamic> userData) {
    close(context, null);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Chatting(
          receiverEmail: userData["email"],
          receiverID: userData["uid"],
        ),
      ),
    );
  }

  String _getFriendlyErrorMessage(dynamic error) {
    // Implement your error message logic here
    if (error.toString().contains('permission-denied')) {
      return 'Không có quyền truy cập dữ liệu';
    } else if (error.toString().contains('network')) {
      return 'Lỗi kết nối mạng';
    }
    return 'Đã xảy ra lỗi không xác định';
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    _isSearching.dispose();
    _searchResults.dispose();
    _errorMessage.dispose();
    super.dispose();
  }
}
