import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/plan.dart';
import '../providers/profile.dart';

import '../screens/change_password_screen.dart';
import '../screens/delete_account_screen.dart';
import '../providers/auth.dart';
import '../screens/profile_screen.dart';

class AccountScreen extends StatelessWidget {
  static final routeName = "/account";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Your Account"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(children: [
            ListTile(
              leading: Icon(Icons.person_sharp),
              title: Text("View Profile"),
              trailing: Icon(Icons.arrow_forward_ios_rounded),
              onTap: () {
                Navigator.of(context).pushNamed(ProfileScreen.routeName);
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.lock),
              title: Text("Change Password"),
              trailing: Icon(Icons.arrow_forward_ios_rounded),
              onTap: () {
                Navigator.of(context).pushNamed(ChangePasswordScreen.routeName);
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.person_remove_alt_1_rounded),
              title: Text("Delete Account"),
              trailing: Icon(Icons.arrow_forward_ios_rounded),
              onTap: () {
                Navigator.of(context).pushNamed(DeleteAccountScreen.routeName);
              },
            ),
            Divider(),
            SizedBox(
              height: 20,
            ),
            TextButton(
              child: Text(
                "SIGNOUT",
                style: TextStyle(fontSize: 15),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacementNamed('/');
                Provider.of<Auth>(context, listen: false).logout();
                Provider.of<Plan>(context, listen: false).clear();
                Provider.of<Profile>(context, listen: false).clear();
              },
            ),
          ]),
        ),
      ),
    );
  }
}
