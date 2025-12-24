import 'package:flutter/material.dart';

class UiUtils {
  static void snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  static String newId() => DateTime.now().millisecondsSinceEpoch.toString();

  static int? tryParseInt(String v) => int.tryParse(v.trim());
}
