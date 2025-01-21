import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'custom_button.dart';
import 'custom_form.dart';
import 'custom_pagelayout.dart';
import 'group_main_page.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailOrUsernameController =
      TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _errorMessage = '';

  Future<void> _login() async {
    setState(() {
      _errorMessage = '';
    });
    try {
      String input = emailOrUsernameController.text.trim();
      String password = passwordController.text.trim();

      String email;
      if (input.contains('@')) {
        email = input;
      } else {
        final querySnapshot = await _firestore
            .collection('users')
            .where('username', isEqualTo: input)
            .get();

        if (querySnapshot.docs.isEmpty) {
          throw FirebaseAuthException(
            code: 'user-not-found',
            message: 'ユーザーが見つかりません。',
          );
        }

        email = querySnapshot.docs.first['email'];
      }

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      print("ログインに成功しました");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => GroupMainPage(uid: userCredential.user!.uid)),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message ?? "ログインに失敗しました";
      });
    } catch (e) {
      setState(() {
        _errorMessage = "予期しないエラーが発生しました: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomPage(
      children: [
        Text(
          'ログイン',
          style: TextStyle(
            fontSize: 24,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 30),
        CustomForm(
          labelText: 'Username or E-mail',
          controller: emailOrUsernameController,
        ),
        SizedBox(height: 20),
        CustomForm(controller: passwordController, labelText: 'Password'),
        SizedBox(height: 30),
        CustomElevatedButton(text: 'ログイン', onPressed: _login),
        SizedBox(height: 30),
        CustomElevatedButton(
            text: '新規登録',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SignUpPage()),
              );
            }),
      ],
    );
  }
}
