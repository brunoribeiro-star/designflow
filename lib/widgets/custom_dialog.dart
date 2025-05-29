import 'package:flutter/material.dart';

Future<void> showCustomDialog({
  required BuildContext context,
  required String title,
  required String content,
  required VoidCallback onConfirm,
  String confirmText = "Confirmar",
  String cancelText = "Cancelar",
}) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: Text(cancelText),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(ctx).pop();
            onConfirm();
          },
          child: Text(confirmText),
        ),
      ],
    ),
  );
}