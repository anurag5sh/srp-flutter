import 'package:dropdown_search/dropdown_search.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:provider/provider.dart';
import 'package:smart_routine_planner/models/hobbies.dart';

import '../config.dart';
import '../providers/profile.dart';

class ProfileScreen extends StatefulWidget {
  static final routeName = "/profile";

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // TextEditingController _field3Controller;
  bool _formChanged = false;
  bool _ageReadOnly = true;
  bool _isLoading = false;
  bool _isFilterByRegion = false;

  final focusName = FocusNode();
  final focusAge = FocusNode();

  final GlobalKey<FormState> _formKey = GlobalKey();

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

  void _selectHobbiesDialog(Map<String, dynamic> data) {
    final _suggestedHobbies = [...data['suggested']];
    var _selectedHobbiesNew = [];
    final _items = _suggestedHobbies
        .map((_hobby) =>
            MultiSelectItem<String>(_hobby, toBeginningOfSentenceCase(_hobby)))
        .toList();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Hobbies Suggested'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 20,
            ),
            Text("Tap to choose them."),
            SizedBox(height: 20),
            Container(
              child: MultiSelectChipField<String>(
                showHeader: false,
                scroll: false,
                items: _items,
                icon: Icon(Icons.check),
                onTap: (values) => _selectedHobbiesNew = values,
              ),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
          TextButton(
            child: Text('Add'),
            onPressed: () async {
              _selectedHobbiesNew.forEach((e) {
                if (!_selectedHobbies.contains(e)) _selectedHobbies.add(e);
              });
              _profileData['hobbies'] = [..._selectedHobbies];
              Navigator.of(ctx).pop();
              await _saveForm().then((value) {
                // Navigator.of(context)
                //     .pushReplacementNamed(ProfileScreen.routeName);
                setState(() {
                  _selectedHobbies = _selectedHobbies;
                });
              });
            },
          )
        ],
      ),
    );
  }

  void _findHobbies() async {
    try {
      var result = await Provider.of<Profile>(context, listen: false)
          .findHobbies(findByRegion: _isFilterByRegion);

      if (result != null) {
        // print(result);

        Navigator.of(context, rootNavigator: true).pop();
        _selectHobbiesDialog(result);
      }
    } catch (error) {
      _showErrorDialog(error.toString());
    }
  }

  void _showHobbiesDialog() {
    _findHobbies();
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Find Hobbies'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(
              height: 30,
            ),
            Text(
                "Finding Hobbies that may interest you. Please wait for a while."),
          ],
        ),
        // actions: <Widget>[
        //   TextButton(
        //     child: Text('Cancel'),
        //     onPressed: () {
        //       Navigator.of(ctx).pop();
        //       return;
        //     },
        //   )
        // ],
      ),
    );
  }

  buildShowDialog(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: CircularProgressIndicator(),
          );
        });
  }

  var userData;
  var _profileData;
  var _selectedHobbies = [];

  @override
  void initState() {
    userData = Provider.of<Profile>(context, listen: false).getProfile;
    _profileData = userData;
    _selectedHobbies = [...userData['hobbies']];

    super.initState();
  }

  final snackBar = SnackBar(
    content: Text('Changes Saved!'),
  );

  Future<void> _saveForm() async {
    if (!_formKey.currentState.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });
    try {
      await Provider.of<Profile>(context, listen: false)
          .saveProfile(_profileData);
      // Navigator.of(context).pushReplacementNamed("/");
      setState(() {
        _formChanged = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } catch (error) {
      const errorMessage =
          'Could not save your profile. Please try again later.';
      _showErrorDialog(errorMessage);
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    focusName.dispose();
    focusAge.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        actions: [
          if (_formChanged)
            TextButton(
              onPressed: _saveForm,
              child: Text("SAVE"),
            )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            Center(
              // child: CircleAvatar(
              child: Stack(
                children: [
                  CircleAvatar(
                    // child: Align(
                    //   alignment: Alignment.bottomRight,
                    //   heightFactor: 9.0,
                    //   widthFactor: 4.0,
                    //   child: GestureDetector(
                    //     onTap: () {},
                    //     child: CircleAvatar(
                    //       backgroundColor: Colors.white,
                    //       radius: 18.0,
                    //       child: Icon(
                    //         Icons.camera_alt,
                    //         size: 26.0,
                    //         color: Color(0xFF404040),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    radius: 80,
                    backgroundImage: NetworkImage(userData['avatar']),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.centerRight,
                      children: [
                        TextFormField(
                          focusNode: focusName,
                          initialValue: userData['name'],
                          decoration: InputDecoration(
                            labelText: "Name*",
                          ),
                          readOnly: true,
                          enableInteractiveSelection: false,
                          // onEditingComplete: () {
                          //   setState(() {
                          //     _nameReadOnly = true;
                          //   });
                          // },
                          // // onChanged: (name) => _profileData['name'] = name,
                          // onSaved: (name) => _profileData['name'] = name,
                        ),
                        // IconButton(
                        //   icon: Icon(Icons.edit),
                        //   onPressed: () {
                        //     setState(() {
                        //       _formChanged = true;
                        //       _nameReadOnly = false;
                        //     });
                        //     focusName.requestFocus();
                        //   },
                        // ),
                      ],
                    ),
                    Stack(
                      alignment: Alignment.centerRight,
                      children: [
                        TextFormField(
                          // focusNode: focusEmail,
                          enableInteractiveSelection: false,
                          readOnly: true,
                          initialValue: userData['email'],
                          decoration: InputDecoration(
                            labelText: "Email",
                          ),
                          // onEditingComplete: () {
                          //   setState(() {
                          //     _enableEmail = true;
                          //   });
                          // },
                        ),
                        // IconButton(
                        //   icon: Icon(Icons.edit),
                        //   onPressed: () {
                        //     setState(() {
                        //       _enableEmail = false;
                        //     });
                        //     focusEmail.requestFocus();
                        //   },
                        // ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Stack(
                            alignment: Alignment.centerRight,
                            children: [
                              TextFormField(
                                readOnly: _ageReadOnly,
                                focusNode: focusAge,
                                initialValue: userData['age'],
                                decoration: InputDecoration(
                                  labelText: "Age*",
                                ),
                                enableInteractiveSelection: false,
                                onEditingComplete: () {
                                  setState(() {
                                    _ageReadOnly = true;
                                  });
                                },
                                onSaved: (age) => _profileData['age'] = age,
                              ),
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () {
                                  setState(() {
                                    _formChanged = true;
                                    _ageReadOnly = false;
                                  });
                                  focusAge.requestFocus();
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField(
                            decoration:
                                InputDecoration(labelText: "Marital Status"),
                            value: _profileData['status'],
                            isExpanded: true,
                            items: <String>[
                              'unmarried',
                              'married',
                              'divorced',
                              'widowed',
                            ].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  toBeginningOfSentenceCase(value),
                                  style: TextStyle(color: Colors.black),
                                ),
                              );
                            }).toList(),
                            hint: Text("Choose Status*"),
                            onChanged: (status) {
                              FocusScope.of(context)
                                  .requestFocus(new FocusNode());
                              _profileData['status'] = status;
                              setState(() {
                                _formChanged = true;
                              });
                            },
                            onSaved: (status) =>
                                _profileData['status'] = status,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: DropdownButtonFormField(
                            decoration:
                                InputDecoration(labelText: "Occupation"),
                            value: _profileData['occupation'],
                            isExpanded: true,
                            items: <String>[
                              'student',
                              'home-maker',
                              'working professional',
                              'retired',
                              'others'
                            ].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    toBeginningOfSentenceCase(value),
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                              );
                            }).toList(),
                            hint: Text("Choose Occupation"),
                            onChanged: (occupation) {
                              FocusScope.of(context)
                                  .requestFocus(new FocusNode());
                              _profileData['occupation'] = occupation;
                              setState(() {
                                _formChanged = true;
                              });
                            },
                            onSaved: (occupation) =>
                                _profileData['occupation'] = occupation,
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: DropdownSearch<String>(
                            dropdownSearchDecoration: InputDecoration(
                              border: const UnderlineInputBorder(),
                              contentPadding: EdgeInsets.all(0.0),
                              labelStyle: TextStyle(height: 2.0),
                            ),
                            searchBoxDecoration: InputDecoration(
                              suffixIcon: Icon(Icons.search),
                            ),
                            showSearchBox: true,
                            mode: Mode.DIALOG,
                            showSelectedItem: true,
                            items: Config.indiaCities,
                            label: "Select a city",
                            autoFocusSearchBox: true,
                            hint: "Select a city",

                            // hint: "cities in menu mode",
                            // popupItemDisabled: (String s) => s.startsWith('I'),
                            onChanged: (city) {
                              _profileData['city'] = city;
                              FocusScope.of(context)
                                  .requestFocus(new FocusNode());
                              setState(() {
                                _formChanged = true;
                              });
                            },
                            onSaved: (city) => _profileData['city'] = city,
                            selectedItem: _profileData['city'],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    MultiSelectDialogField(
                      title: Text("Choose Hobbies"),
                      buttonText: Text("Your Hobbies"),
                      searchable: true,
                      // listType: MultiSelectListType.CHIP,
                      chipDisplay: MultiSelectChipDisplay(
                        onTap: (value) {
                          // setState(() {
                          // });
                          _selectedHobbies.remove(value);
                          setState(() {
                            _formChanged = true;
                          });
                          return _selectedHobbies;
                        },
                        icon: Icon(Icons.close),
                      ),
                      items: HobbiesList.hobbies
                          .map(
                            (hobby) => MultiSelectItem<String>(
                                hobby, toBeginningOfSentenceCase(hobby)),
                          )
                          .toList(),
                      initialValue: _selectedHobbies,
                      onConfirm: (value) {
                        FocusScope.of(context).requestFocus(new FocusNode());
                        _selectedHobbies = value;
                        setState(() {
                          _formChanged = true;
                        });
                      },
                      onSaved: (values) {
                        _profileData['hobbies'] = values;
                      },
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Card(
                            elevation: 8.0,
                            child: Container(
                              padding: EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    "Let's help you find some interests!",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text("Filter by Region"),
                                      Switch(
                                          value: _isFilterByRegion,
                                          onChanged: (val) {
                                            setState(() {
                                              _isFilterByRegion = true;
                                            });
                                          })
                                    ],
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  OutlinedButton(
                                    onPressed: _showHobbiesDialog,
                                    child: Text("Find Hobbies"),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    if (_isLoading)
                      Center(
                        child: CircularProgressIndicator(
                          backgroundColor: Colors.black38,
                        ),
                      )
                    // buildShowDialog(context)
                    else
                      ElevatedButton(
                        onPressed: _formChanged ? _saveForm : null,
                        child: Text("SAVE"),
                      )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
