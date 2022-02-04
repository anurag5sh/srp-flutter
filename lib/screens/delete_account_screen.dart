import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_routine_planner/providers/auth.dart';

class DeleteAccountScreen extends StatelessWidget {
  // const DeleteAccountScreen({ Key? key }) : super(key: key);
  static final routeName = '/delete-account';

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('An Error Occurred!'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Confirm Deletion'),
        content: Text('Do you want to proceed?'),
        actions: <Widget>[
          TextButton(
            child: Text('No'),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Yes'),
            onPressed: () async {
              try {
                await Provider.of<Auth>(context, listen: false).deleteAccount();
                Provider.of<Auth>(context, listen: false).logout();
              } catch (e) {
                _showErrorDialog(context, e.toString());
              } finally {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              }
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
        title: Text('Delete Account'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            Text(
              'Are you sure you want to delete your account?\nThis action is irreversible.',
              style: TextStyle(fontSize: 22),
            ),
            SizedBox(
              height: 80,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => _showDeleteDialog(context),
                  child: Text('DELETE'),
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          Colors.red.shade800)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
