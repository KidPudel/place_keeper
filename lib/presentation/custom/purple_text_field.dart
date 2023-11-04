import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class PurpleTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final String? errorMessage;
  const PurpleTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.hintText,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
        decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Colors.deepPurple,
                ),
                borderRadius: BorderRadius.circular(15)),
            focusedBorder: OutlineInputBorder(
                borderSide:
                const BorderSide(color: Colors.deepPurple, width: 2),
                borderRadius: BorderRadius.circular(15)),
            errorBorder: OutlineInputBorder(
                borderSide:
                BorderSide(color: Colors.red.shade800),
                borderRadius: BorderRadius.circular(15)),
            focusedErrorBorder: OutlineInputBorder(
                borderSide:
                BorderSide(color: Colors.red.shade800, width: 2),
                borderRadius: BorderRadius.circular(15)),
            errorText: errorMessage,
            labelText: labelText,
            labelStyle: const TextStyle(
                color: Colors.deepPurple, fontWeight: FontWeight.bold),
            alignLabelWithHint: true,
            hintText: hintText,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            isDense: true));
  }
}