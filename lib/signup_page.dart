import 'package:flutter/material.dart';

import 'custom_button.dart';
import 'custom_pagelayout.dart';
import 'custom_textformfield.dart';

class SignUpPage extends StatelessWidget {
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
        CustomTextFormField(labelText: 'E-mail'),
        SizedBox(height: 20),
        CustomTextFormField(labelText: 'Password'),
        SizedBox(height: 20),
        CustomElevatedButton(
            text: '新規登録',
            onPressed: () {
              print('新規登録ボタンが押されました');
            })
      ],
    );
  }
}
