import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'auth_service.dart';

class DashboardService {
  // Use 10.0.2.2 for Android emulators, otherwise use 127.0.0.1 for Windows/Web testing
  static String get baseUrl {
    if (kIsWeb) return 'http://127.0.0.1:8000';
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:8000';
    } catch (_) {}
    return 'http://127.0.0.1:8000';
  }
  
  // Method to fetch the patient dashboard data
  static Future<Map<String, dynamic>> fetchPatientDashboard(String uid) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/dashboard/patient/$uid'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load dashboard data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error while fetching dashboard: $e');
    }
  }

  // Method to log new vitals
  static Future<bool> logVitals({
    required String uid,
    required int sys,
    required int dia,
    required int hr,
    required double temp,
    required int rr,
    required int o2,
    required int weight,
    required double bmi,
    required int glucose,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/dashboard/vitals'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'uid': uid,
          'bloodPressureSys': sys,
          'bloodPressureDia': dia,
          'heartRate': hr,
          'temperature': temp,
          'respiratoryRate': rr,
          'oxygenSaturation': o2,
          'weight': weight,
          'bmi': bmi,
          'bloodGlucose': glucose,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] ?? false;
      } else {
        return false;
      }
    } catch (e) {
      print('Error logging vitals: $e');
      return false;
    }
  }
}
