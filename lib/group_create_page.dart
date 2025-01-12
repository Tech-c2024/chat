import 'package:flutter/material.dart';

import 'custom_pagelayout.dart';
import 'custom_textformfield.dart';

class GroupCreatePage extends StatelessWidget {
  @override
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
        CustomTextFormField(labelText: 'グループ名'),
        SizedBox(height: 20),
        CustomTextFormField(labelText: '人数'),
        SizedBox(height: 20),
        CustomTextFormField(labelText: '目標個数'),
        SizedBox(height: 20),
        CustomTextFormField(labelText: '期限'),
        SizedBox(height: 20),
        Divider(
          color: Colors.black,
          thickness: 1,
          indent: 20,
          endIndent: 20,
        ),
        SizedBox(height: 20),
        CustomTextFormField(labelText: '自分の目標'),
      ],
    );
  }
}
