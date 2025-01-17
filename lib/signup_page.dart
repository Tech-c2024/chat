import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'custom_button.dart';
import 'custom_pagelayout.dart';
import 'custom_textformfield.dart';
import 'login_page.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _signUp() async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
      print("アカウントの作成に成功, UID:${userCredential.user?.uid}");
    } catch (e) {
      print("アカウントの作成に失敗: $e");
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
        CustomTextFormField(
          controller: emailController,
          labelText: 'E-mail',
        ),
        SizedBox(height: 20),
        CustomTextFormField(
          controller: passwordController,
          labelText: 'Password',
        ),
        SizedBox(height: 20),
        CustomElevatedButton(text: '新規登録', onPressed: _signUp),
      ],
    );
  }
}
