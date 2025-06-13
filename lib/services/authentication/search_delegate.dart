import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_nckh/components/user_tile.dart';
import 'package:demo_nckh/screens/chatting.dart';
import 'package:demo_nckh/services/authentication/chatting/chatting_service.dart';
import 'package:flutter/material.dart';

class UserSearchDelegate extends SearchDelegate {
  final ChattingService chattingService;

  UserSearchDelegate(this.chattingService);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [IconButton(onPressed: () => query = '', icon: Icon(Icons.clear))];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () => close(context, null),
      icon: Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return StreamBuilder(
      stream: chattingService.getUserStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final users = (snapshot.data! as List).where((userData) {
          final username = userData["email"]
              .toString()
              .split("@")
              .first
              .toLowerCase();
          return username.contains(query.toLowerCase());
        }).toList();

        return ListView(
          children: users
              .map(
                (userData) => UserTile(
                  email: userData["email"],
                  isOnline: userData["isOnline"],
                  lastSeen: (userData["lastSeen"] as Timestamp)
                      .toDate()
                      .toString(),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => Chatting(
                          receiverEmail: userData["email"],
                          receiverID: userData["uid"],
                        ),
                      ),
                    );
                  },
                ),
              )
              .toList(),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildResults(context);
  }
}
