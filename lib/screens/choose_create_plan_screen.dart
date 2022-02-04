import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/plan.dart';
import './auto_generate_plan_screen.dart';
import './create_plan_screen.dart';

class ChooseCreatePlan extends StatelessWidget {
  static final routeName = '/chooseCreatePlan';
  // const ChooseCreatePlan({ Key? key }) : super(key: key);

  void _showDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Choose accuracy'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
          TextButton(
            child: Text('Moderate'),
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pushNamed(AutoGeneratePlan.routeName);
            },
          ),
          TextButton(
            child: Text('High'),
            onPressed: () {
              Navigator.of(ctx).pop();
              Provider.of<Plan>(context, listen: false).setReqAccHigh();
              Navigator.of(context).pushNamed(AutoGeneratePlan.routeName);
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create Plan"),
      ),
      body: Container(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Create your day's plan"),
            SizedBox(
              height: 50,
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed(CreatePlanScreen.routeName);
              },
              child: Text('Create Plan'),
            ),
            SizedBox(height: 10),
            Text("OR"),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                _showDialog(
                    context, 'Choose the auto generation plan accuracy');
              },
              child: Text('Auto-generate Plan'),
            ),
          ],
        ),
      ),
    );
  }
}
