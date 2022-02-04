import 'dart:convert';
import 'dart:async';
// import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:smart_routine_planner/models/http_exception.dart';

// import '../models/http_exception.dart';
import '../config.dart';

class Auth with ChangeNotifier {
  final apiUrl = Config.apiUrl;

  String _token;
  DateTime _expiryDate;
  String _userId;
  Timer _authTimer;

  bool get isAuth {
    return token != null;
  }

  String get token {
    if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  String get userId {
    return _userId;
  }

  Future<void> signup(String name, String email, String password) async {
    final url = Uri.parse('$apiUrl/users');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode(
          {
            'name': name,
            'email': email,
            'password': password,
            'admin': false,
          },
        ),
      );

      final responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        _token = responseData['token'];
        final jwtPlayload = Jwt.parseJwt(_token);
        _userId = jwtPlayload['user']['id'];
        _expiryDate = DateTime.now().add(
          Duration(
            seconds: jwtPlayload['exp'],
          ),
        );
        _autoLogout();
        notifyListeners();
        final prefs = await SharedPreferences.getInstance();
        final userData = json.encode(
          {
            'token': _token,
            'userId': _userId,
            'expiryDate': _expiryDate.toIso8601String(),
          },
        );
        prefs.setString('userData', userData);
      } else {
        throw HttpException(responseData['errors'][0]['msg']);
      }
    } catch (error) {
      throw error;
    }
  }

  Future<void> login(String email, String password) async {
    final url = Uri.parse('$apiUrl/auth');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode(
          {
            'email': email,
            'password': password,
          },
        ),
      );
      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        _token = responseData['token'];
        final jwtPlayload = Jwt.parseJwt(_token);
        _userId = jwtPlayload['user']['id'];
        _expiryDate = DateTime.now().add(
          Duration(seconds: jwtPlayload['exp']),
        );
        _autoLogout();
        notifyListeners();
        final prefs = await SharedPreferences.getInstance();
        final userData = json.encode(
          {
            'token': _token,
            'userId': _userId,
            'expiryDate': _expiryDate.toIso8601String(),
          },
        );
        prefs.setString('userData', userData);
      } else {
        throw HttpException(responseData['errors'][0]['msg']);
      }
    } catch (error) {
      throw error;
    }
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractedUserData =
        json.decode(prefs.getString('userData')) as Map<String, Object>;
    final expiryDate = DateTime.parse(extractedUserData['expiryDate']);

    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }
    _token = extractedUserData['token'];
    _userId = extractedUserData['userId'];
    _expiryDate = expiryDate;
    notifyListeners();
    _autoLogout();
    return true;
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    // prefs.remove('userData');
    prefs.clear();
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }

  Future<void> changePassword(
      {String currentPassword, String newPassword, String cnfPassword}) async {
    final url = Uri.parse('$apiUrl/users/password');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json", "x-auth-token": _token},
        body: json.encode(
          {
            'currentPassword': currentPassword,
            'newPassword': newPassword,
            'dupliPassword': cnfPassword
          },
        ),
      );
      final responseData = json.decode(response.body);

      if (response.statusCode != 200) {
        throw HttpException(responseData['errors'][0]['msg']);
      }

      return responseData;
    } catch (error) {
      throw error;
    }
  }

  Future<void> deleteAccount() async {
    final url = Uri.parse('$apiUrl/profile');
    try {
      final response = await http.delete(
        url,
        headers: {"Content-Type": "application/json", "x-auth-token": _token},
      );
      final responseData = json.decode(response.body);

      if (response.statusCode != 200) {
        print(responseData);
        throw HttpException('Sorry! Could not delete your Account.');
      }

      return responseData;
    } catch (error) {
      throw error;
    }
  }
}
