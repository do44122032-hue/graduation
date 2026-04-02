import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../enums/user_role.dart';
import '../constants/api_config.dart';

class AuthResult {
  final bool success;
  final String? message;
  final UserModel? user;

  AuthResult({required this.success, this.message, this.user});
}

class AuthService extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  bool _isInitialized = false;

  static String get _baseUrl => ApiConfig.baseUrl;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  bool get isInitialized => _isInitialized;

  AuthService() {
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadUser();
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _loadUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user_data');
      if (userJson != null) {
        _currentUser = UserModel.fromJson(jsonDecode(userJson));
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading user: $e');
    }
  }

  Future<void> _saveUser(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', jsonEncode(user.toJson()));
    } catch (e) {
      debugPrint('Error saving user: $e');
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<AuthResult> loginAsStudent(String studentId, String password) async {
    return _login(studentId, password, UserRole.student);
  }

  Future<AuthResult> loginAsDoctor(String sheetId, String password) async {
    return _login(sheetId, password, UserRole.doctor);
  }

  Future<AuthResult> loginAsPatient(String email, String password) async {
    return _login(email, password, UserRole.patient);
  }

  Future<AuthResult> _login(String email, String password, UserRole role) async {
    _setLoading(true);
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'role': role.name,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _currentUser = UserModel.fromJson(data['user']);
        if (_currentUser != null) {
          await _saveUser(_currentUser!);
        }
        _setLoading(false);
        return AuthResult(success: true, user: _currentUser);
      } else {
        _setLoading(false);
        return AuthResult(
          success: false, 
          message: _getErrorMessage(response),
        );
      }
    } catch (e) {
      _setLoading(false);
      return AuthResult(success: false, message: 'Connection error: $e');
    }
  }

  Future<AuthResult> signUp({
    required String name,
    required String email,
    required String password,
    required String phone,
    required UserRole role,
    String? department,
    String? bio,
  }) async {
    _setLoading(true);
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'phone': phone,
          'role': role.name,
          if (department != null) 'department': department,
          if (bio != null) 'bio': bio,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _currentUser = UserModel.fromJson(data['user']);
        if (_currentUser != null) {
          await _saveUser(_currentUser!);
        }
        
        if (role == UserRole.doctor) {
          // Doctors need to login to become "active" on the backend
          return await _login(email, password, role);
        }

        _setLoading(false);
        return AuthResult(success: true, user: _currentUser);
      } else {
        _setLoading(false);
        return AuthResult(
          success: false,
          message: _getErrorMessage(response),
        );
      }
    } catch (e) {
      _setLoading(false);
      return AuthResult(success: false, message: 'Connection error: $e');
    }
  }

  Future<AuthResult> updatePatientProfile({
    String? age,
    String? bloodType,
    String? height,
    String? weight,
    String? dateOfBirth,
    String? socialStatus,
    List<String>? chronicConditions,
    List<String>? medications,
  }) async {
    if (_currentUser == null) return AuthResult(success: false, message: 'Not logged in');
    
    _setLoading(true);
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/users/patient-profile'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'uid': _currentUser!.id,
          'age': age,
          'bloodType': bloodType,
          'height': height,
          'weight': weight,
          'dateOfBirth': dateOfBirth,
          'socialStatus': socialStatus,
          'chronicConditions': chronicConditions,
          'medications': medications,
        }),
      );

      if (response.statusCode == 200) {
        // Refresh local user data
        final profileRes = await http.get(Uri.parse('$_baseUrl/users/profile/${_currentUser!.id}'));
        if (profileRes.statusCode == 200) {
          _currentUser = UserModel.fromJson(jsonDecode(profileRes.body));
          if (_currentUser != null) {
            await _saveUser(_currentUser!);
          }
        }
        _setLoading(false);
        notifyListeners();
        return AuthResult(success: true);
      } else {
        _setLoading(false);
        return AuthResult(success: false, message: _getErrorMessage(response));
      }
    } catch (e) {
      _setLoading(false);
      return AuthResult(success: false, message: 'Connection error: $e');
    }
  }

  Future<AuthResult> resetPassword(String phone) async {
    _setLoading(true);
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone}),
      ).timeout(const Duration(seconds: 30));
      
      debugPrint('Reset Password Stats: ${response.statusCode}');
      debugPrint('Reset Password Body: ${response.body}');
      
      _setLoading(false);
      if (response.statusCode == 200) {
        return AuthResult(success: true, message: 'Reset code sent to your phone');
      } else {
        return AuthResult(success: false, message: _getErrorMessage(response));
      }
    } catch (e) {
      _setLoading(false);
      return AuthResult(success: false, message: 'Connection error: $e');
    }
  }

  // Helper methods matched to existing UI calls
  Future<AuthResult> verifyRecoveryCode(String phone, String code) async {
    _setLoading(true);
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/verify-code'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone, 'code': code}),
      );
      _setLoading(false);
      if (response.statusCode == 200) {
        return AuthResult(success: true);
      } else {
        return AuthResult(success: false, message: _getErrorMessage(response));
      }
    } catch (e) {
      _setLoading(false);
      return AuthResult(success: false, message: 'Connection error: $e');
    }
  }

  Future<AuthResult> updatePassword(String phone, String newPassword) async {
    _setLoading(true);
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/update-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone, 'new_password': newPassword}),
      );
      _setLoading(false);
      if (response.statusCode == 200) {
        return AuthResult(success: true, message: 'Password updated successfully');
      } else {
        return AuthResult(success: false, message: _getErrorMessage(response));
      }
    } catch (e) {
      _setLoading(false);
      return AuthResult(success: false, message: 'Connection error: $e');
    }
  }

  String _getErrorMessage(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      if (data['detail'] is List) {
        return (data['detail'] as List).map((e) {
          if (e is Map) return e['msg'] ?? e.toString();
          return e.toString();
        }).join(', ');
      }
      return data['detail']?.toString() ?? 'Error: ${response.statusCode}';
    } catch (e) {
      return 'Server error (Status: ${response.statusCode})';
    }
  }

  void logout() async {
    if (_currentUser != null) {
      try {
        await http.post(
          Uri.parse('$_baseUrl/auth/logout'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'uid': _currentUser!.id}),
        );
      } catch (e) {
        // Ignore logout network errors
      }
    }
    _currentUser = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_data');
    } catch (e) {
      // Ignore
    }
    notifyListeners();
  }
}
