import 'package:flutter/material.dart';

class ProgressBar extends StatelessWidget {
  final double value;
  final String label;
  const ProgressBar({required this.value, required this.label, super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: value,
          minHeight: 6,
          backgroundColor: Colors.grey[200],
          color: Colors.blueGrey,
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
