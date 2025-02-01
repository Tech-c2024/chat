import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MemberListPage extends StatelessWidget {
  final String groupId;

  const MemberListPage({Key? key, required this.groupId}) : super(key: key);

  Future<List<String>> _getGroupMembers() async {
    try {
      // グループのメンバーを取得
      DocumentSnapshot groupDoc = await FirebaseFirestore.instance
          .collection('groups')
          .doc(groupId)
          .get();

      if (groupDoc.exists && groupDoc['members'] != null) {
        // メンバーのIDリスト
        List<String> memberIds = List<String>.from(groupDoc['members']);
        return await _getUserNamesFromIds(memberIds);
      }
      return [];
    } catch (e) {
      print('エラー: $e');
      return [];
    }
  }

  // メンバーIDからユーザー名を取得する関数
  Future<List<String>> _getUserNamesFromIds(List<String> memberIds) async {
    List<String> memberNames = [];

    try {
      for (String userId in memberIds) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        if (userDoc.exists && userDoc['username'] != null) {
          memberNames.add(userDoc['username']);
        }
      }
    } catch (e) {
      print('エラー: $e');
    }

    return memberNames;
  }

  @override
  Widget build(BuildContext context) {
    double systemBarHeight = MediaQuery.of(context).padding.top;
    double appBarHeight =
        (MediaQuery.of(context).size.height - systemBarHeight) * 0.05;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(appBarHeight),
        child: Container(
          color: Colors.white,
          child: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: Text(
              'メンバーリスト',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
        ),
      ),
      body: FutureBuilder<List<String>>(
        future: _getGroupMembers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('メンバーがいません'));
          }

          List<String> members = snapshot.data!;

          return ListView.builder(
            itemCount: members.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(members[index]),
              );
            },
          );
        },
      ),
    );
  }
}
