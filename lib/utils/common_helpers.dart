import 'package:flutter/material.dart';

class CommonHelpers {
  static void navigateTo(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return screen;
      },
    ));
  }
}
