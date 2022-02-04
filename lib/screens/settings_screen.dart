import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  static final routeName = "/settings";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
      ),
    );
  }
}
