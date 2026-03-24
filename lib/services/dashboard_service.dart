import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class DashboardService {
  static String get baseUrl => 'https://graduation-backend-production-7023.up.railway.app';
  
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

  static Future<Map<String, dynamic>> uploadLabResult({
    required String uid,
    File? imageFile,
    Uint8List? webBytes,
    String? fileName,
  }) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/lab/upload'));
      request.fields['uid'] = uid;
      
      if (webBytes != null) {
        request.files.add(http.MultipartFile.fromBytes(
          'file',
          webBytes,
          filename: fileName ?? 'upload.jpg',
        ));
      } else if (imageFile != null) {
        request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));
      } else {
        return {'success': false, 'message': 'No file selected'};
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Upload successful'};
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false, 
          'message': errorData['detail'] ?? 'Server error (${response.statusCode})'
        };
      }
    } catch (e) {
      print('Error uploading lab result: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Method to book an appointment
  static Future<bool> bookAppointment({
    required String uid,
    required String doctorName,
    required String specialty,
    required String date,
    required String time,
    required String type,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/dashboard/appointments/book'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'uid': uid,
          'doctorName': doctorName,
          'specialty': specialty,
          'date': date,
          'time': time,
          'type': type,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error booking appointment: $e');
      return false;
    }
  }

  // Method to cancel an appointment
  static Future<bool> cancelAppointment(String apptId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/dashboard/appointments/cancel/$apptId'),
        headers: {'Content-Type': 'application/json'},
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error canceling appointment: $e');
      return false;
    }
  }

  Future<List<UserModel>> fetchPatients() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/patients'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => UserModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch patients: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching patients: $e');
      return [];
    }
  }

  Future<List<UserModel>> fetchDoctors() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/doctors'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => UserModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch doctors: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching doctors: $e');
      return [];
    }
  }

  static Future<List<UserModel>> fetchActiveDoctors() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/doctors/active'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => UserModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch active doctors: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching active doctors: $e');
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> fetchDoctorSchedule(String doctorId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/doctors/$doctorId/schedule'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('Failed to fetch schedule: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching schedule: $e');
      return [];
    }
  }

  static Future<bool> addDoctorSchedule({
    required String doctorId,
    required String day,
    required String startTime,
    required String endTime,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/doctors/$doctorId/schedule'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'day': day,
          'startTime': startTime,
          'endTime': endTime,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] ?? false;
      } else {
        return false;
      }
    } catch (e) {
      print('Error adding schedule: $e');
      return false;
    }
  }
}
