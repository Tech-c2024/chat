import 'package:flutter/material.dart';
import 'package:temp_project/login_page.dart';

void main() {
  runApp(
    MaterialApp(
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.white,
        ),
        home: const LoginPage()),
  );
}
