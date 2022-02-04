import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/performance_screen.dart';
import '../screens/choose_create_plan_screen.dart';
import '../providers/profile.dart';
import '../screens/view_routine_screen.dart';
import '../screens/account_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/about_screen.dart';

enum DrawerSelection { Homepage, Account, Settings }

// ignore: must_be_immutable
class AppDrawer extends StatelessWidget {
  final DrawerSelection _selectedDraweritem = DrawerSelection.Homepage;

  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<Profile>(context).getProfile;
    return Drawer(
      child: Column(
        children: <Widget>[
          Container(
            // height: 190,
            child: DrawerHeader(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ListTile(
                    contentPadding:
                        EdgeInsets.only(top: 10, bottom: 0, left: 0, right: 0),
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(
                        profile['avatar'],
                      ),
                      radius: 40,
                    ),
                    horizontalTitleGap: 5,
                    title: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        profile['name'] != null
                            ? profile['name']
                            : 'User\'s Name',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    subtitle: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(profile['email'] != null
                          ? profile['email']
                          : 'email@email.com'),
                    ),
                    onTap: () => Navigator.of(context)
                        .pushNamed(ProfileScreen.routeName),
                  ),
                  Container(
                    margin: EdgeInsets.only(right: 20.0),
                    child: OutlinedButton(
                      style: ButtonStyle(visualDensity: VisualDensity.compact),
                      onPressed: () => Navigator.of(context)
                          .pushNamed(ProfileScreen.routeName),
                      child: Text(
                        'View Profile',
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            dense: true,
            visualDensity: VisualDensity.compact,
            selected: _selectedDraweritem == DrawerSelection.Homepage,
            leading: Icon(Icons.home),
            title: Text('Homepage'),
            onTap: () {
              Navigator.of(context).pushReplacementNamed('/');
            },
          ),
          ListTile(
            dense: true,
            visualDensity: VisualDensity.compact,
            // selected: _selectedDraweritem == DrawerSelection.Homepage,
            leading: Icon(Icons.more_time_rounded),
            title: Text('Create Plan'),
            onTap: () {
              Navigator.of(context).pushNamed(ChooseCreatePlan.routeName);
            },
          ),
          ListTile(
            dense: true,
            visualDensity: VisualDensity.compact,
            // selected: _selectedDraweritem == DrawerSelection.Homepage,
            leading: Icon(Icons.calendar_today_outlined),
            title: Text('View Plans'),
            onTap: () {
              Navigator.of(context).pushNamed(ViewRoutineScreen.routeName);
            },
          ),
          Divider(),
          ListTile(
            dense: true,
            visualDensity: VisualDensity.compact,
            selected: _selectedDraweritem == DrawerSelection.Account,
            leading: Icon(Icons.account_circle),
            title: Text('Account'),
            onTap: () {
              Navigator.of(context).pushNamed(AccountScreen.routeName);
            },
          ),
          ListTile(
            dense: true,
            visualDensity: VisualDensity.compact,
            // selected: _selectedDraweritem == DrawerSelection.Homepage,
            leading: Icon(Icons.insert_chart_outlined_rounded),
            title: Text('Performance'),
            onTap: () {
              Navigator.of(context).pushNamed(PerformanceScreen.routeName);
            },
          ),
          Divider(),
          ListTile(
            dense: true,
            visualDensity: VisualDensity.compact,
            leading: Icon(Icons.info),
            title: Text('About'),
            onTap: () {
              Navigator.of(context).pushNamed(AboutScreen.routeName);
            },
          ),
        ],
      ),
    );
  }
}
