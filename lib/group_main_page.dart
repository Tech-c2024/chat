import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'custom_pagelayout.dart';

class GroupMainPage extends StatelessWidget {
  final String uid;

  GroupMainPage({required this.uid});

  @override
  Widget build(BuildContext context) {
    return CustomPage(
      children: [Text('groupmainpage')],
    );
  }
}
