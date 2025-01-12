import 'package:flutter/material.dart';

import 'custom_pagelayout.dart';
import 'custom_textformfield.dart';

class GroupJoinPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPage(
      children: [
        Text(
          'グループ参加',
          style: TextStyle(
            fontSize: 24,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 30),
        CustomTextFormField(labelText: 'グループ名'),
        SizedBox(height: 20),
        CustomTextFormField(labelText: '招待コード'),
        SizedBox(height: 20),
        Divider(
          color: Colors.black,
          thickness: 1,
          indent: 20,
          endIndent: 20,
        ),
        SizedBox(height: 20),
        CustomTextFormField(labelText: '自分の目標'),
        SizedBox(height: 10),
        CustomTextFormField(),
        SizedBox(height: 10),
        CustomTextFormField()
      ],
    );
  }
}
