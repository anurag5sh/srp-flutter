import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_routine_planner/models/http_exception.dart';
import 'package:smart_routine_planner/providers/auth.dart';

class ChangePasswordScreen extends StatefulWidget {
  // const ChangePasswordScreen({ Key? key }) : super(key: key);
  static final routeName = '/change-password';
  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _form = GlobalKey<FormState>();
  bool isLoading = false;
  var currentPassword = '';
  var newPassword = '';
  var cnfPassword = '';

  void _showErrorDialog(String message) {
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

  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Password Changed'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text('Okay'),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
          )
        ],
      ),
    );
  }

  Future<void> savePassword({currentPassword, newPassword, cnfPassword}) async {
    if (!_form.currentState.validate()) {
      // Invalid!
      return;
    }

    setState(() {
      isLoading = true;
    });
    _form.currentState.save();
    print('$currentPassword $newPassword $cnfPassword');
    try {
      await Provider.of<Auth>(context, listen: false)
          .changePassword(
              currentPassword: currentPassword,
              newPassword: newPassword,
              cnfPassword: cnfPassword)
          .then((value) {
        _showDialog("Your password has been updated!");
      });
    } on HttpException catch (e) {
      _showErrorDialog(e.toString());
    } catch (e) {
      print(e);
      _showErrorDialog('Something went wrong!');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Change Password'),
      ),
      body: Container(
        padding: const EdgeInsets.all(15.0),
        child: Form(
          key: _form,
          child: ListView(
            children: [
              TextFormField(
                obscureText: true,
                decoration: InputDecoration(labelText: 'Current Password'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your current password";
                  }
                  return null;
                },
                onSaved: (value) {
                  currentPassword = value;
                },
                onChanged: (value) {
                  currentPassword = value;
                },
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                obscureText: true,
                decoration: InputDecoration(labelText: 'New Password'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter New password";
                  }
                  return null;
                },
                onSaved: (value) {
                  newPassword = value;
                },
                onChanged: (value) {
                  newPassword = value;
                },
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                obscureText: true,
                decoration: InputDecoration(labelText: 'Confirm New Password'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter Confirm New password";
                  }
                  return null;
                },
                onSaved: (value) {
                  cnfPassword = value;
                },
                onChanged: (value) {
                  cnfPassword = value;
                },
              ),
              SizedBox(
                height: 40,
              ),
              if (isLoading)
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                    ],
                  ),
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('Cancel'),
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Colors.red.shade800)),
                    ),
                    ElevatedButton(
                      onPressed: () => savePassword(
                          currentPassword: currentPassword,
                          newPassword: newPassword,
                          cnfPassword: cnfPassword),
                      child: Text('SAVE'),
                    ),
                  ],
                )
            ],
          ),
        ),
      ),
    );
  }
}
