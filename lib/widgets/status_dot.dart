import 'package:flutter/material.dart';

class StatusDot extends StatelessWidget {
  final String status; // "green", "yellow" ou "red"
  const StatusDot({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case 'green':
        color = Colors.green;
        break;
      case 'yellow':
        color = Colors.orange;
        break;
      case 'red':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(color: Colors.black12),
      ),
    );
  }
}