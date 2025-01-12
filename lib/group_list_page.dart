import 'package:flutter/material.dart';

import 'custom_button.dart';
import 'custom_pagelayout.dart';
import 'group_create_page.dart';
import 'group_join_page.dart';

class GroupListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPage(
      children: [
        Text(
          'グループ一覧',
          style: TextStyle(
            fontSize: 24,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomElevatedButton(
                text: '作成',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => GroupCreatePage()),
                  );
                }),
            SizedBox(width: 10),
            CustomElevatedButton(
                text: '参加',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => GroupJoinPage()),
                  );
                }),
          ],
        ),
        SizedBox(height: 20),
        CustomElevatedButton(
          text: 'Group01',
          onPressed: () {
            print('Group01が押されました');
          },
          width: 300,
          height: 40,
        ),
        SizedBox(height: 20),
        CustomElevatedButton(
          text: 'Group02',
          onPressed: () {
            print('Group02が押されました');
          },
          width: 300,
          height: 40,
        ),
        SizedBox(height: 20),
      ],
    );
  }
}
