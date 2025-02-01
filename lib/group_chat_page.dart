import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:temp_project/group_settings_page.dart';
import 'package:temp_project/group_todo_page.dart';

class GroupChatPage extends StatefulWidget {
  final String groupId;
  final String roomId;
  final String groupName;

  const GroupChatPage(
      {Key? key,
      required this.groupId,
      required this.roomId,
      required this.groupName})
      : super(key: key);

  @override
  _GroupChatPageState createState() => _GroupChatPageState();
}

class _GroupChatPageState extends State<GroupChatPage> {
  bool _isAttachmentUploading = false;

  // メッセージ送信処理
  void _handleSendPressed(types.PartialText message) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      Map<String, dynamic> messageData = {
        'senderId': currentUser.uid,
        'timestamp': FieldValue.serverTimestamp(),
      };

      if (message.text.isNotEmpty) {
        messageData['messageText'] = message.text;
      }

      await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .collection('rooms')
          .doc(widget.roomId)
          .collection('messages')
          .add(messageData);
    } catch (e) {
      print("エラー: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('メッセージ送信中にエラーが発生しました')),
      );
    }
  }

  // 添付ファイル処理
  void _handleAttachmentPressed() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null) {
      File file = File(result.files.single.path ?? '');

      setState(() {
        _isAttachmentUploading = true;
      });

      try {
        String fileName = result.files.single.name;
        Reference ref =
            FirebaseStorage.instance.ref().child('chat_images/$fileName');
        UploadTask uploadTask = ref.putFile(file);

        TaskSnapshot snapshot = await uploadTask;

        String downloadUrl = await snapshot.ref.getDownloadURL();
        print('画像URL: $downloadUrl');

        _sendMessageWithImage(downloadUrl);
      } catch (e) {
        print('アップロード失敗: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('画像アップロード中にエラーが発生しました')),
        );
      } finally {
        setState(() {
          _isAttachmentUploading = false;
        });
      }
    }
  }

  // 画像メッセージ送信処理
  void _sendMessageWithImage(String imageUrl) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .collection('rooms')
          .doc(widget.roomId)
          .collection('messages')
          .add({
        'senderId': currentUser.uid,
        'imageUrl': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("エラー: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('画像メッセージ送信中にエラーが発生しました')),
      );
    }
  }

  // メッセージストリーム
  Stream<List<types.Message>> _getMessageStream() {
    return FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupId)
        .collection('rooms')
        .doc(widget.roomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      List<types.Message> messages = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final senderId = data['senderId'] as String?;

        String username = "Unknown";
        String? profileImageUrl;

        if (senderId != null) {
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(senderId)
              .get();

          if (userDoc.exists) {
            final userData = userDoc.data();
            username = userData?['username'] ?? "Unknown";
            profileImageUrl = userData?['profileImageUrl'];
          }
        }

        final author = types.User(
          id: senderId ?? '',
          firstName: username,
          imageUrl: profileImageUrl,
        );

        types.Message message;
        if (data.containsKey('imageUrl')) {
          // 画像メッセージ
          message = types.ImageMessage(
            id: doc.id,
            author: author,
            createdAt:
                (data['timestamp'] as Timestamp?)?.millisecondsSinceEpoch,
            uri: data['imageUrl'],
            size: 0,
            name: '',
          );
        } else {
          // テキストメッセージ
          message = types.TextMessage(
            id: doc.id,
            author: author,
            createdAt:
                (data['timestamp'] as Timestamp?)?.millisecondsSinceEpoch,
            text: data['messageText'] ?? '',
          );
        }

        messages.add(message);
      }
      return messages;
    });
  }

  // appBar残り日数を計算
  int? _remainingDays; // 残り日数を保持

  @override
  void initState() {
    super.initState();
    _fetchDeadline();
  }

  Future<void> _fetchDeadline() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .get();

      if (doc.exists) {
        String? deadlineString = doc['deadline']; // Firestore の日付データ

        if (deadlineString != null) {
          DateTime deadline = DateTime.parse(deadlineString); // 文字列をDateTimeに変換
          DateTime now = DateTime.now();
          int remainingDays = deadline.difference(now).inDays; // 差分を計算

          setState(() {
            _remainingDays = remainingDays;
          });
        }
      }
    } catch (e) {
      print('エラー: $e');
    }
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
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center, // 中央配置
              children: [
                Text(
                  widget.groupName,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 20),
                Text('期限まで残り${_remainingDays ?? '--'}日',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
              ],
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.notifications),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          GroupGoalPage(groupId: widget.groupId),
                    ),
                  );
                  print('通知ボタンが押されました');
                },
              ),
              SizedBox(
                width: 1,
              ),
              IconButton(
                  icon: Icon(Icons.settings),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            GroupSettingsPage(groupId: widget.groupId),
                      ),
                    );
                    print('設定ボタンが押されました');
                  }),
            ],
          ),
        ),
      ),
      body: StreamBuilder<List<types.Message>>(
        stream: _getMessageStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('エラーが発生しました'));
          }

          return Chat(
            messages: snapshot.data ?? [],
            onSendPressed: _handleSendPressed,
            onAttachmentPressed: _handleAttachmentPressed,
            user: types.User.fromJson(
                {'id': FirebaseAuth.instance.currentUser?.uid ?? ''}),
          );
        },
      ),
    );
  }
}
