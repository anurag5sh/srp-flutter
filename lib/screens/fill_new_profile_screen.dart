import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:provider/provider.dart';

import '../config.dart';
import '../models/hobbies.dart';
import '../providers/profile.dart';

class NewProfile extends StatefulWidget {
  static final routeName = "/newProfile";

  @override
  _NewProfileState createState() => _NewProfileState();
}

class _NewProfileState extends State<NewProfile> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  Map<String, dynamic> _profileData = {
    'age': null,
    'status': '',
    'occupation': '',
    'hobbies': [],
    'city': '',
  };

  var _selectedHobbies = [];

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

  void _saveForm() async {
    if (!_formKey.currentState.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState.save();
    try {
      await Provider.of<Profile>(context, listen: false)
          .saveProfile(_profileData);
      Navigator.of(context).pushReplacementNamed("/");
    } catch (error) {
      // print(error);
      const errorMessage =
          'Could not save your profile. Please try again later.';
      _showErrorDialog(errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 10,
              ),
              Text(
                "Tell us something about yourself",
                style: TextStyle(
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: "Age*"),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter your age";
                        }
                        return null;
                      },
                      onSaved: (value) => _profileData['age'] = value,
                    ),
                    SizedBox(height: 20),
                    DropdownButtonFormField(
                      // decoration: InputDecoration(labelText: "Marital Status"),
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
                      hint: Text("Choose Marital Status*"),
                      onChanged: (status) {
                        FocusScope.of(context).requestFocus(new FocusNode());
                        _profileData['status'] = status;
                      },
                      onSaved: (status) => _profileData['status'] = status,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    DropdownButtonFormField(
                      // decoration: InputDecoration(labelText: "Occupation"),
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
                          child: Text(
                            toBeginningOfSentenceCase(value),
                            style: TextStyle(color: Colors.black),
                          ),
                        );
                      }).toList(),
                      hint: Text("Choose Occupation"),
                      onChanged: (occupation) {
                        FocusScope.of(context).requestFocus(new FocusNode());
                        _profileData['occupation'] = occupation;
                      },
                      onSaved: (occupation) =>
                          _profileData['occupation'] = occupation,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    MultiSelectDialogField(
                      buttonIcon: Icon(Icons.arrow_drop_down),
                      title: Text("Choose Hobbies"),
                      buttonText: Text(
                        "Choose Hobbies",
                        style: TextStyle(fontSize: 16),
                      ),
                      searchable: true,
                      // listType: MultiSelectListType.CHIP,
                      chipDisplay: MultiSelectChipDisplay(
                        onTap: (value) {
                          setState(() {
                            _selectedHobbies.remove(value);
                          });
                        },
                        icon: Icon(Icons.close),
                      ),
                      items: HobbiesList.hobbies
                          .map((hobby) => MultiSelectItem<String>(hobby, hobby))
                          .toList(),

                      onConfirm: (value) {
                        FocusScope.of(context).requestFocus(new FocusNode());
                        _selectedHobbies = value;
                      },
                      onSaved: (values) {
                        _profileData['hobbies'] = values;
                      },
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    DropdownSearch<String>(
                      dropdownSearchDecoration: InputDecoration(
                        border: const UnderlineInputBorder(),
                        contentPadding: EdgeInsets.all(0.0),
                      ),
                      searchBoxDecoration: InputDecoration(
                        suffixIcon: Icon(Icons.search),
                      ),
                      showSearchBox: true,
                      mode: Mode.DIALOG,
                      showSelectedItem: true,
                      items: Config.indiaCities,
                      label: "Select a city",
                      // hint: "cities in menu mode",
                      // popupItemDisabled: (String s) => s.startsWith('I'),
                      onChanged: (city) => _profileData['city'] = city,
                      onSaved: (city) => _profileData['city'] = city,
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    ElevatedButton(
                      onPressed: _saveForm,
                      child: Wrap(
                        direction: Axis.horizontal,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text("PROCEED"),
                          Icon(Icons.chevron_right_rounded)
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
