import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../enums/user_role.dart';

class AuthResult {
  final bool success;
  final String? message;
  final UserModel? user;

  AuthResult({required this.success, this.message, this.user});
}

class AuthService extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<AuthResult> loginAsStudent(String studentId, String password) async {
    _setLoading(true);
    await Future.delayed(const Duration(seconds: 2));

    if (password.length < 6) {
      _setLoading(false);
      return AuthResult(
        success: false,
        message: 'Password must be at least 6 characters',
      );
    }

    _currentUser = UserModel(
      id: 'student_1',
      name: 'Student User',
      email: studentId.contains('@')
          ? studentId
          : '$studentId@cihanuniversity.edu.iq',
      role: UserRole.student,
    );

    _setLoading(false);
    return AuthResult(success: true, user: _currentUser);
  }

  Future<AuthResult> loginAsDoctor(String sheetId, String password) async {
    _setLoading(true);
    await Future.delayed(const Duration(seconds: 2));

    if (password.length < 6) {
      _setLoading(false);
      return AuthResult(success: false, message: 'Invalid credentials');
    }

    _currentUser = UserModel(
      id: 'doctor_1',
      name: 'Dr. Smith',
      email: 'doctor@hospital.com',
      role: UserRole.doctor,
    );
    _setLoading(false);
    return AuthResult(success: true, user: _currentUser);
  }

  Future<AuthResult> loginAsPatient(String email, String password) async {
    _setLoading(true);
    await Future.delayed(const Duration(seconds: 2));

    if (password.length < 6) {
      _setLoading(false);
      return AuthResult(
        success: false,
        message: 'Account not found or password incorrect',
      );
    }

    _currentUser = UserModel(
      id: 'patient_1',
      name: 'Patient User',
      email: email,
      role: UserRole.patient,
    );
    _setLoading(false);
    return AuthResult(success: true, user: _currentUser);
  }

  Future<AuthResult> signUp({
    required String name,
    required String email,
    required String password,
    required String phone,
    required UserRole role,
  }) async {
    _setLoading(true);
    await Future.delayed(const Duration(seconds: 2));

    if (!email.contains('@')) {
      _setLoading(false);
      return AuthResult(success: false, message: 'Invalid email address');
    }

    _currentUser = UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      email: email,
      role: role,
      phoneNumber: phone,
      // Initialize patient fields as null for now
      age: null,
      bloodType: null,
      height: null,
      weight: null,
      dateOfBirth: null,
      socialStatus: null,
      chronicConditions: [],
      medications: [],
    );

    _setLoading(false);
    return AuthResult(success: true, user: _currentUser);
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
    _setLoading(true);
    await Future.delayed(const Duration(seconds: 1)); // Simulate network

    if (_currentUser == null) {
      _setLoading(false);
      return AuthResult(success: false, message: 'No user logged in');
    }

    // Create new user object with updated fields
    _currentUser = UserModel(
      id: _currentUser!.id,
      name: _currentUser!.name,
      email: _currentUser!.email,
      role: _currentUser!.role,
      phoneNumber: _currentUser!.phoneNumber,
      profilePicture: _currentUser!.profilePicture,
      age: age ?? _currentUser!.age,
      bloodType: bloodType ?? _currentUser!.bloodType,
      height: height ?? _currentUser!.height,
      weight: weight ?? _currentUser!.weight,
      dateOfBirth: dateOfBirth ?? _currentUser!.dateOfBirth,
      socialStatus: socialStatus ?? _currentUser!.socialStatus,
      chronicConditions: chronicConditions ?? _currentUser!.chronicConditions,
      medications: medications ?? _currentUser!.medications,
    );

    _setLoading(false);
    notifyListeners(); // Important to notify UI of changes
    return AuthResult(success: true, user: _currentUser);
  }

  Future<AuthResult> resetPassword(String identifier) async {
    _setLoading(true);
    await Future.delayed(const Duration(seconds: 2));

    if (identifier.length < 3) {
      _setLoading(false);
      return AuthResult(success: false, message: 'Invalid identifier');
    }

    _setLoading(false);
    return AuthResult(
      success: true,
      message: 'Reset instructions sent successfully',
    );
  }

  Future<AuthResult> verifyRecoveryCode(String identifier, String code) async {
    _setLoading(true);
    await Future.delayed(const Duration(seconds: 2));

    if (code == '123456') {
      // Mock verification code
      _setLoading(false);
      return AuthResult(success: true, message: 'Code verified successfully');
    }

    _setLoading(false);
    return AuthResult(success: false, message: 'Invalid verification code');
  }

  Future<AuthResult> updatePassword(
    String identifier,
    String newPassword,
  ) async {
    _setLoading(true);
    await Future.delayed(const Duration(seconds: 2));

    if (newPassword.length < 6) {
      _setLoading(false);
      return AuthResult(
        success: false,
        message: 'Password must be at least 6 characters',
      );
    }

    _setLoading(false);
    return AuthResult(success: true, message: 'Password updated successfully');
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
