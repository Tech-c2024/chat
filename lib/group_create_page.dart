import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'custom_button.dart';
import 'custom_form.dart';
import 'custom_pagelayout.dart';
import 'group_list_page.dart';

class GroupCreatePage extends StatefulWidget {
  @override
  _GroupCreatePageState createState() => _GroupCreatePageState();
}

class _GroupCreatePageState extends State<GroupCreatePage> {
  final TextEditingController groupNameController = TextEditingController();
  final TextEditingController passPhraseController = TextEditingController();
  final TextEditingController maxMembersController = TextEditingController();
  final TextEditingController goalCountController = TextEditingController();
  final TextEditingController deadLineController = TextEditingController();

  String _message = '';

  Future<void> createGroup() async {
    try {
      String groupName = groupNameController.text.trim();
      String passphrase = passPhraseController.text.trim();
      int maxMembers = int.parse(maxMembersController.text.trim());
      int goalCount = int.parse(goalCountController.text.trim());
      DateTime deadLine = DateTime.parse(deadLineController.text.trim());

      // 現在のユーザーUIDを取得
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception("ログインしているユーザーがいません");
      }
      String uid = currentUser.uid;

      // グループIDを生成
      DocumentReference groupRef =
          FirebaseFirestore.instance.collection('groups').doc();

      // Firestoreにデータ保存
      await groupRef.set({
        'groupName': groupName,
        'passphrase': passphrase,
        'createdAt': FieldValue.serverTimestamp(),
        'groupId': groupRef.id,
        'members': [uid],
        'maxMembers': maxMembers,
        'goalCount': goalCount,
        'deadLine': deadLine,
      });

      await groupRef.collection('rooms').doc('defaultRoom').set({
        'roomName': 'General',
        'createdAt': FieldValue.serverTimestamp(),
        'users': [uid],
      });

      _message = 'グループの作成に成功しました';

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => GroupListPage()),
      );
    } catch (e) {
      _message = 'エラー: ${e.toString()}';
    }
    print(_message);
  }

  Widget build(BuildContext context) {
    return CustomPage(
      children: [
        Text(
          'グループ作成',
          style: TextStyle(
            fontSize: 24,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 30),
        CustomForm(controller: groupNameController, labelText: 'グループ名'),
        SizedBox(height: 20),
        CustomForm(controller: passPhraseController, labelText: 'あいことば'),
        SizedBox(height: 20),
        CustomForm(controller: maxMembersController, labelText: '人数'),
        SizedBox(height: 20),
        CustomForm(controller: goalCountController, labelText: '目標個数'),
        SizedBox(height: 20),
        CustomForm(controller: deadLineController, labelText: '期限'),
        SizedBox(height: 20),
        CustomElevatedButton(text: '作成', onPressed: createGroup)
      ],
    );
  }
}
