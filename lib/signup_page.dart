import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'custom_button.dart';
import 'custom_form.dart';
import 'custom_pagelayout.dart';
import 'login_page.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _errorMessage = '';

  Future<void> _signUp() async {
    _errorMessage = '';
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(), // .text 入力フィールドの文字列を取得
        password: passwordController.text.trim(), // trim() 前後の空白を削除
      );

      String uid = userCredential.user!.uid; // user! nullではないことを保証
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'username': usernameController.text.trim(),
        'email': emailController.text.trim(),
        'uid': uid,
        'createdAt': Timestamp.now(),
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
      print("アカウントの作成に成功, UID:${userCredential.user?.uid}");
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        _errorMessage = "このメールアドレスはすでに使用されています。";
      } else {
        _errorMessage = e.message ?? "アカウントの作成に失敗しました。";
      }
      print("エラー: $_errorMessage");
    } catch (e) {
      _errorMessage = "予期しないエラーが発生しました: $e";
      print("エラー: $_errorMessage");
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomPage(
      children: [
        Text(
          '新規登録',
          style: TextStyle(
            fontSize: 24,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 30),
        CustomForm(
          controller: usernameController,
          labelText: 'username',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'ユーザー名を入力してください';
            }
            if (RegExp(r'[^a-zA-Z0-9_]+').hasMatch(value)) {
              return 'ユーザー名は半角英数字と_のみ使用できます';
            }
            return null;
          },
        ),
        SizedBox(height: 20),
        CustomForm(
          controller: emailController,
          labelText: 'E-mail',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'メールアドレスを入力してください';
            }
            if (RegExp(r"[^a-zA-z0-9_@.-]").hasMatch(value)) {
              return '正しいメールアドレスを入力してください';
            }
          },
        ),
        SizedBox(height: 20),
        CustomForm(
          controller: passwordController,
          labelText: 'Password',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'パスワードを入力してください';
            }
          },
        ),
        SizedBox(height: 20),
        CustomElevatedButton(text: '新規登録', onPressed: _signUp),
      ],
    );
  }
}
