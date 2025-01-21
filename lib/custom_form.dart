import 'package:flutter/material.dart';

class CustomForm extends StatelessWidget {
  final GlobalKey<FormState>? formKey;
  final TextEditingController? controller;
  final String? labelText;
  final double width;
  final String? Function(String?)? validator;
  final AutovalidateMode autovalidateMode;

  const CustomForm({
    Key? key,
    this.formKey,
    this.labelText,
    this.width = 300,
    this.controller,
    this.validator,
    this.autovalidateMode = AutovalidateMode.always,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey ?? GlobalKey<FormState>(),
      autovalidateMode: autovalidateMode,
      child: Container(
        width: width,
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: labelText,
            border: OutlineInputBorder(),
          ),
          validator: validator,
        ),
      ),
    );
  }
}
