import 'package:flutter/material.dart';

class CustomPage extends StatelessWidget {
  final List<Widget> children;

  const CustomPage({
    Key? key,
    required this.children,
  }): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: children,
        ),
      )),
    );
  }
}