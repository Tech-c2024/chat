import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:temp_project/group_list_page.dart';

import 'custom_button.dart';
import 'custom_pagelayout.dart';
import 'custom_textformfield.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _errorMessage = '';

  Future<void> _login() async {
    setState(() {
      _errorMessage = '';
    });
    try {
      await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      print("ログインに成功しました");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => GroupListPage()),
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
        CustomTextFormField(
          labelText: 'E-mail',
          controller: emailController,
        ),
        SizedBox(height: 20),
        CustomTextFormField(
            controller: passwordController, labelText: 'Password'),
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
