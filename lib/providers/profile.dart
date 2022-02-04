import 'dart:convert';

import 'package:flutter/widgets.dart';
import '../models/http_exception.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config.dart';

class Profile with ChangeNotifier {
  final apiUrl = Config.apiUrl;

  String token;

  static final profileInit = {
    'name': '',
    'avatar': '',
    'date': '',
    'age': null,
    'status': '',
    'hobbies': [],
    'city': '',
    'email': '',
    'occupation': ''
  };

  Map<String, dynamic> profileData;

  Profile({this.token, this.profileData});

  Map<String, dynamic> get getProfile {
    return {...profileData};
  }

  Future<Map<String, dynamic>> profile() async {
    final url = Uri.parse('$apiUrl/profile/me');
    try {
      final response = await http.get(url,
          headers: {"x-auth-token": token, "Content-Type": "application/json"});
      final responseData = json.decode(response.body);
      // print(responseData);
      if (response.statusCode != 200) {
        throw new HttpException(responseData['msg']);
      }

      profileData['name'] = responseData['user']['name'];
      profileData['avatar'] = responseData['user']['avatar'].isEmpty
          ? "https://github.com/google/material-design-icons/raw/master/png/social/person/materialicons/48dp/2x/baseline_person_black_48dp.png"
          : 'https:${responseData['user']['avatar']}';
      profileData['date'] =
          DateTime.parse(responseData['date'].toString()).toIso8601String();
      profileData['status'] = responseData['status'];
      profileData['city'] = responseData['city'];
      profileData['hobbies'] = responseData['hobbies'];
      profileData['occupation'] = responseData['occupation'];
      profileData['age'] = responseData['age'];
      profileData['email'] = responseData['user']['email'];
      // notifyListeners();
      // print(profileData);
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('profile', json.encode(profileData));

      return {...profileData};
    } catch (error) {
      throw error;
    }
  }

  Future<void> saveProfile(Map<String, dynamic> data) async {
    data['hobbies'] = data['hobbies'] != null ? data['hobbies'].join(",") : '';

    final url = Uri.parse('$apiUrl/profile');
    try {
      final response = await http.post(url,
          body: json.encode(data),
          headers: {"x-auth-token": token, "Content-Type": "application/json"});
      final responseData = json.decode(response.body);

      if (response.statusCode != 200) {
        throw new HttpException(responseData);
      }

      profile();
    } catch (error) {
      throw error;
    }
  }

  Future<Map<String, dynamic>> findHobbies(
      {@required bool findByRegion}) async {
    final url = Uri.parse('$apiUrl/predict/hobbies?region=$findByRegion');
    try {
      final response = await http.get(url,
          headers: {"x-auth-token": token, "Content-Type": "application/json"});
      final responseData = json.decode(response.body);

      if (response.statusCode != 200) {
        throw new HttpException(responseData);
      }

      return responseData;
    } catch (error) {
      throw error;
    }
  }

  void clear() {
    token = null;
    profileData = profileInit;
    notifyListeners();
  }
}
