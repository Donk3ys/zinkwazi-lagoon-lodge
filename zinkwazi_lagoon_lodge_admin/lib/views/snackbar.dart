import 'package:flutter/material.dart';

class InfoSnackBar {
  static Future<SnackBar> create(String message) async {
    return SnackBar(
        content: Text(message),
        action: SnackBarAction(
            label: 'ok',
            onPressed: () {
              // Some code to undo the change.
            }
        )
    );
  }
}