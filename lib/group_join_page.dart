import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'custom_button.dart';
import 'custom_form.dart';
import 'custom_pagelayout.dart';
import 'group_list_page.dart';

class GroupJoinPage extends StatefulWidget {
  @override
  _GroupJoinPageState createState() => _GroupJoinPageState();
}

class _GroupJoinPageState extends State<GroupJoinPage> {
  final TextEditingController groupNameController = TextEditingController();
  final TextEditingController passPhraseController = TextEditingController();

  Future<void> joinGroup(String groupName, String passphrase) async {
    try {
      // 現在のユーザーUIDを取得
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception("エラー: ログインしているユーザーがいません");
      }
      String uid = currentUser.uid;

      // グループ名で検索して、対応するgroupIdを取得
      QuerySnapshot groupQuery = await FirebaseFirestore.instance
          .collection('groups')
          .where('groupName', isEqualTo: groupName)
          .get();

      if (groupQuery.docs.isEmpty) {
        throw Exception("グループが見つかりません");
      }

      // 同じ名前のグループが複製ある場合、それぞれをチェック
      for (var groupDoc in groupQuery.docs) {
        String storedPassphrase = groupDoc['passphrase'];
        String groupId = groupDoc['groupId'];

        if (storedPassphrase == passphrase) {
          List<dynamic> members = List.from(groupDoc['members']);
          String uid = FirebaseAuth.instance.currentUser!.uid;

          if (!members.contains(uid)) {
            members.add(uid);

            await FirebaseFirestore.instance
                .collection('groups')
                .doc(groupId)
                .update({'members': members});
            print("グループに参加しました");

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => GroupListPage()),
            );
            return;
          } else {
            print("すでにグループに参加しています");
            return;
          }
        }
      }

      throw Exception("あいことばが間違っています");
    } catch (e) {
      print("エラー: ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomPage(
      children: [
        Text('グループ参加',
            style: TextStyle(
              fontSize: 24,
              color: Colors.black,
            )),
        SizedBox(height: 30),
        CustomForm(
          controller: groupNameController,
          labelText: 'グループ名',
        ),
        SizedBox(height: 20),
        CustomForm(
          controller: passPhraseController,
          labelText: 'あいことば',
        ),
        SizedBox(height: 20),
        CustomElevatedButton(
            text: '参加',
            onPressed: () {
              String groupName = groupNameController.text.trim();
              String passphrase = passPhraseController.text.trim();
              joinGroup(groupName, passphrase);
            }),
      ],
    );
  }
}
