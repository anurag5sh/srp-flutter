import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  static final routeName = "/about";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("About"),
      ),
      body: ListView(
        children: [
          SizedBox(
            height: 30,
          ),
          CircleAvatar(
            radius: 100,
            backgroundImage: AssetImage('assets/images/logo_2.png'),
          ),
          SizedBox(
            height: 30,
          ),
          Center(
            child: Text(
              'Smart Routine Planner',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w500),
            ),
          ),
          SizedBox(
            height: 30,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '"Smart Routine Planner, to keep work and leisure in perfect balance and help you achieve your daily target by making the best use of your time."',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              " Smart Routine Planner is like a supportive friend who helps one to achieve their goals by making the best use of their time, keeping work and leisure in perfect balance, and also ensures that they follow a healthy routine. Thereby, implementing a structure to their day that not only gives them a sense of control but also improves their focus, organization, and productivity.",
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
