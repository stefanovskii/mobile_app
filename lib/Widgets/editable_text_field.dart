import 'package:flutter/material.dart';

class EditableTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool enabled;

  const EditableTextField({Key? key, required this.controller, required this.label, this.enabled = true,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final FocusNode focusNode = FocusNode();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: GestureDetector(
        onTap: () {
          if (enabled) {
            focusNode.requestFocus();
          }
        },
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: label,
            enabled: enabled,
            suffixIcon: enabled
                ? IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                focusNode.requestFocus();
              },
            )
                : null,
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            disabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
          ),
        ),
      ),
    );
  }
}
