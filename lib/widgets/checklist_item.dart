import 'package:flutter/material.dart';
import '../models/project.dart';

class ChecklistItemWidget extends StatelessWidget {
  final ChecklistItem item;
  final void Function(bool?)? onChanged;

  const ChecklistItemWidget({
    super.key,
    required this.item,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Checkbox(
        value: item.isDone,
        onChanged: onChanged,
      ),
      title: Text(item.title),
    );
  }
}