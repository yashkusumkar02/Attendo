import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool isDropdown;
  final VoidCallback? onTap;
  final bool readOnly; // ✅ Added readOnly parameter

  CustomTextField({
    required this.controller,
    required this.hintText,
    this.isDropdown = false,
    this.onTap,
    this.readOnly = false, // ✅ Default value set to false
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      readOnly: readOnly, // ✅ Fixed `readOnly` implementation
      onTap: isDropdown ? onTap : null,
      decoration: InputDecoration(
        labelText: hintText,
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        suffixIcon: isDropdown ? Icon(Icons.arrow_drop_down) : null,
      ),
    );
  }
}
