import 'package:flutter/material.dart';
import 'package:temp_project/custom_button.dart';
import 'package:temp_project/custom_textformfield.dart';

import 'custom_pagelayout.dart';
import 'group_list_page.dart';
import 'signup_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  void onPressed() {
    print('Button pressed');
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
        CustomTextFormField(labelText: 'Username'),
        SizedBox(height: 20),
        CustomTextFormField(labelText: 'Password'),
        SizedBox(height: 30),
        CustomElevatedButton(
            text: 'ログイン',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GroupListPage()),
              );
            }),
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
