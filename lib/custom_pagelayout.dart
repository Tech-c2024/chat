import 'package:flutter/material.dart';

class CustomPage extends StatelessWidget {
  final List<Widget> children;

  const CustomPage({
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: children,
        ),
      ),
    );
  }
}
