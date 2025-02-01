import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'custom_button.dart';
import 'custom_pagelayout.dart';
import 'group_chat_page.dart';
import 'group_create_page.dart';
import 'group_join_page.dart';

class GroupListPage extends StatefulWidget {
  @override
  _GroupListPageState createState() => _GroupListPageState();
}

class _GroupListPageState extends State<GroupListPage> {
  List<Map<String, String>> groups = [];

  @override
  void initState() {
    super.initState();
    _fetchUserGroups();
  }

  Future<void> _fetchUserGroups() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception("ログインしているユーザーがいません");
      }
      String uid = currentUser.uid;

      QuerySnapshot groupQuery = await FirebaseFirestore.instance
          .collection('groups')
          .where('members', arrayContains: uid)
          .get();

      List<Map<String, String>> fetchedGroups = [];

      for (var doc in groupQuery.docs) {
        String groupId = doc.id;
        // グループ名を取得
        DocumentSnapshot groupDoc = await FirebaseFirestore.instance
            .collection('groups')
            .doc(groupId)
            .get();
        String groupName = groupDoc['groupName'] ?? '未設定';

        var roomSnapshot = await FirebaseFirestore.instance
            .collection('groups')
            .doc(groupId)
            .collection('rooms')
            .limit(1)
            .get();

        if (roomSnapshot.docs.isNotEmpty) {
          fetchedGroups.add({
            'groupId': groupId,
            'roomId': roomSnapshot.docs.first.id,
            'groupName': groupName,
          });
        }
      }

      setState(() {
        groups = fetchedGroups;
      });
    } catch (e) {
      print("エラー: ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomPage(
      children: [
        Text(
          'グループ一覧',
          style: TextStyle(
            fontSize: 24,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomElevatedButton(
                text: '作成',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => GroupCreatePage()),
                  );
                }),
            SizedBox(width: 10),
            CustomElevatedButton(
                text: '参加',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => GroupJoinPage()),
                  );
                }),
          ],
        ),
        SizedBox(height: 20),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            groups.isEmpty
                ? Center(child: CircularProgressIndicator())
                : Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: groups.length,
                      itemBuilder: (context, index) {
                        String groupId = groups[index]['groupId']!;
                        String? roomId = groups[index]['roomId'];
                        String groupName = groups[index]['groupName']!;

                        return Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 5, horizontal: 10),
                            child: CustomElevatedButton(
                                text: groupName,
                                onPressed: roomId != null
                                    ? () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => GroupChatPage(
                                                groupId: groupId,
                                                roomId: roomId,
                                                groupName: groupName),
                                          ),
                                        );
                                      }
                                    : () {},
                                backgroundColor: Colors.white,
                                textColor: Colors.black,
                                borderColor: Colors.black,
                                width: 80,
                                height: 50));
                      },
                    ),
                  ),
          ],
        )
      ],
    );
  }
}
