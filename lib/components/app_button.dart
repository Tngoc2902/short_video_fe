import 'package:flutter/material.dart';
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool disabled;
  const AppButton({super.key, required this.label, required this.onPressed, this.disabled = false});
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: disabled ? null : onPressed,
      style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
      child: Text(label),
    );
  }
}
