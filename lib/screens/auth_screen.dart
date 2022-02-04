import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../models/http_exception.dart';
import "../providers/auth.dart";

enum AuthMode { Signup, Login }

class AuthScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [
                    Color.fromRGBO(131, 96, 195, 1),
                    Color.fromRGBO(46, 191, 145, 1)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: [0, 1]),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.only(top: 30.0),
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 15.0),
                      padding:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                              width: 100,
                              child: Image(
                                  image: AssetImage('assets/images/logo.png'))),
                          SizedBox(
                            width: 30,
                          ),
                          Container(
                            width: 120,
                            child: const Text(
                              'Smart Routine Planner',
                              style:
                                  TextStyle(fontSize: 30, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Flexible(
                    child: AuthCard(),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Login;
  Map<String, String> _authData = {'email': '', 'password': '', 'name': ''};
  var _isLoading = false;
  // final _passwordController = TextEditingController();

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

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.Signup;
      });
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });
    try {
      if (_authMode == AuthMode.Login) {
        // Log user in
        await Provider.of<Auth>(context, listen: false).login(
          _authData['email'],
          _authData['password'],
        );
      } else {
        // Sign user up
        await Provider.of<Auth>(context, listen: false).signup(
          _authData['name'],
          _authData['email'],
          _authData['password'],
        );
      }
    } on HttpException catch (error) {
      var errorMessage = 'Authentication failed';
      if (error.toString().contains('Invalid credentials!')) {
        errorMessage = 'Authentication failed';
      } else if (error.toString().contains('User already exits!')) {
        errorMessage = 'User already exits with this email!';
      } else if (error.toString().contains('vaild email')) {
        errorMessage = 'Enter vaild email!';
      }
      _showErrorDialog(errorMessage);
    }
    // catch (error) {
    //   print(error);
    //   const errorMessage =
    //       'Could not authenticate you. Please try again later.';
    //   _showErrorDialog(errorMessage);
    // }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 8.0,
      child: Container(
        height: _authMode == AuthMode.Signup ? 420 : 360,
        width: deviceSize.width * 0.85,
        padding: EdgeInsets.all(15.0),
        child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  if (_authMode == AuthMode.Signup)
                    TextFormField(
                      enabled: _authMode == AuthMode.Signup,
                      keyboardType: TextInputType.name,
                      decoration: InputDecoration(labelText: 'Name'),
                      validator: _authMode == AuthMode.Signup
                          ? (value) {
                              if (value == null || value.isEmpty) {
                                return "Please enter an E-mail ID";
                              }
                              return null;
                            }
                          : null,
                      onSaved: (value) {
                        _authData['name'] = value;
                      },
                    ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'E-mail'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter an E-mail ID";
                      }
                      final email = RegExp(
                          r"^\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*$");
                      if (!email.hasMatch(value)) {
                        return "Please enter a valid E-mail ID";
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _authData['email'] = value;
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return "Please enter a password";
                      if (value.length < 6)
                        return "Password should be greater than 5 characters";

                      return null;
                    },
                    onSaved: (value) {
                      _authData['password'] = value;
                    },
                  ),
                  // if (_authMode == AuthMode.Signup)
                  //   TextFormField(
                  //     enabled: _authMode == AuthMode.Signup,
                  //     decoration:
                  //         InputDecoration(labelText: 'Confirm Password'),
                  //     obscureText: true,
                  //     validator: _authMode == AuthMode.Signup
                  //         ? (value) {
                  //             if (value != _passwordController.text) {
                  //               return 'Passwords do not match!';
                  //             }
                  //             return null;
                  //           }
                  //         : null,
                  //   ),
                  SizedBox(
                    height: 20,
                  ),
                  if (_isLoading)
                    CircularProgressIndicator()
                  else
                    ElevatedButton(
                      onPressed: _submit,
                      child: Text(
                          _authMode == AuthMode.Login ? "LOGIN" : "SIGNUP"),
                      style: ButtonStyle(
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        padding: MaterialStateProperty.all<EdgeInsets>(
                          EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
                        ),
                      ),
                    ),
                  TextButton(
                    onPressed: _switchAuthMode,
                    child: Text(_authMode == AuthMode.Login
                        ? "Sign up as a new user"
                        : "Login as a user"),
                  ),
                ],
              ),
            )),
      ),
    );
  }
}
