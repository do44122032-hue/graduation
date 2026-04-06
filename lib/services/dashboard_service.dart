import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/student_report_model.dart';
import '../models/student_task_model.dart';
import '../models/course_model.dart';
import '../constants/api_config.dart';

class DashboardService {
  static String get baseUrl => ApiConfig.baseUrl;
  
  // Local cache to ensure immediate UI feedback even if server is slow
  static Map<String, dynamic>? _lastLoggedVital;

  static Future<void> saveVitalLocally(Map<String, dynamic> vital) async {
    _lastLoggedVital = vital;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_vital_cache', jsonEncode(vital));
      
      final strList = prefs.getString('vitals_list_cache');
      List<dynamic> list = [];
      if (strList != null) {
        list = jsonDecode(strList);
      }
      list.insert(0, vital);
      await prefs.setString('vitals_list_cache', jsonEncode(list));
    } catch (_) {}
  }
  
  static Future<List<Map<String, dynamic>>> getLocalVitalsList() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final strList = prefs.getString('vitals_list_cache');
      if (strList != null) {
        final List<dynamic> list = jsonDecode(strList);
        return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
    } catch (e) {
      print('DEBUG DashboardService: getLocalVitalsList Error: $e');
    }
    return [];
  }
  
  static Future<Map<String, dynamic>?> getLocalVital() async {
    if (_lastLoggedVital != null) return _lastLoggedVital;
    try {
      final prefs = await SharedPreferences.getInstance();
      final str = prefs.getString('last_vital_cache');
      if (str != null) {
        _lastLoggedVital = jsonDecode(str);
        return _lastLoggedVital;
      }
    } catch (_) {}
    return null;
  }

  // Deprecated: used old in-memory only methods
  static void setLastLoggedVital(Map<String, dynamic> vital) => saveVitalLocally(vital);
  static Map<String, dynamic>? getLastLoggedVital() => _lastLoggedVital;
  static Future<Map<String, dynamic>> fetchPatientDashboard(String uid) async {
    try {
      final url = '$baseUrl/dashboard/patient/$uid';
      print('DEBUG DashboardService: GET $url');
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 30));

      print('DEBUG DashboardService: Response Code: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('DEBUG DashboardService: Success! Vitals: ${data['recentVitals']?.length ?? 0}');
        return data;
      } else {
        print('DEBUG DashboardService: Error ${response.statusCode}: ${response.body}');
        return {'success': false, 'error': 'Server error: ${response.statusCode}'};
      }
    } catch (e) {
      print('DEBUG DashboardService: Fetch Network Error: $e');
      throw Exception('Network error while fetching dashboard: $e');
    }
  }

  static Future<Map<String, dynamic>> logVitals({
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
      final url = '$baseUrl/dashboard/vitals';
      final payload = {
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
      };
      
      print('DEBUG DashboardService: POST to $url with $payload');
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      ).timeout(const Duration(seconds: 20));

      print('DEBUG DashboardService: Response Code: ${response.statusCode}');
      print('DEBUG DashboardService: Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        print('DEBUG DashboardService: Log Vitals Success: ${data['success']}');
        
        // Save to local cache for instant dashboard update
        setLastLoggedVital({
          'bloodPressureSys': sys,
          'bloodPressureDia': dia,
          'heartRate': hr,
          'temperature': temp,
          'respiratoryRate': rr,
          'oxygenSaturation': o2,
          'weight': weight,
          'bmi': bmi,
          'bloodGlucose': glucose,
          'date': DateTime.now().toIso8601String(),
        });

        return {
          'success': data['success'] ?? true, 
          'message': data['message'] ?? 'Successfully logged'
        };
      } else {
        print('DEBUG DashboardService: Log Vitals Error: ${response.statusCode}');
        return {
          'success': false, 
          'message': 'Server Error: ${response.statusCode} - ${response.body}'
        };
      }
    } catch (e) {
      print('DEBUG DashboardService: Log Vitals Error: $e');
      return {'success': false, 'message': 'Network/Connection Error: $e'};
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

  static Future<List<Map<String, dynamic>>> fetchLabResults(String uid) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/lab/$uid'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching lab results: $e');
      return [];
    }
  }

  static Future<bool> bookAppointment({
    required String uid,
    String? patientName,
    String? doctorId,
    required String doctorName,
    required String specialty,
    required String date,
    required String time,
    required String type,
  }) async {
    try {
      print('DEBUG: Booking appointment for UID: $uid with Doctor: $doctorName');
      final response = await http.post(
        Uri.parse('$baseUrl/dashboard/appointments/book'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'uid': uid,
          'patientName': patientName,
          'doctorId': doctorId,
          'doctorName': doctorName,
          'specialty': specialty,
          'date': date,
          'time': time,
          'type': type,
        }),
      ).timeout(const Duration(seconds: 30));

      print('DEBUG: Booking Status Code: ${response.statusCode}');
      if (response.statusCode != 200) {
        print('DEBUG: Booking Error Body: ${response.body}');
      }
      return response.statusCode == 200;
    } catch (e) {
      print('Error booking appointment (Possible Timeout): $e');
      return false;
    }
  }

  // Method to cancel an appointment
  static Future<bool> cancelAppointment(String apptId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/dashboard/appointments/cancel/$apptId'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 30));

      return response.statusCode == 200;
    } catch (e) {
      print('Error canceling appointment: $e');
      return false;
    }
  }

  // Method to confirm an appointment
  static Future<bool> confirmAppointment(String apptId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/dashboard/appointments/confirm/$apptId'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 30));

      return response.statusCode == 200;
    } catch (e) {
      print('Error confirming appointment: $e');
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> fetchDoctorAppointments(String doctorId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/dashboard/doctor/$doctorId/appointments'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching doctor appointments: $e');
      return [];
    }
  }

  static Future<List<UserModel>> fetchPatients() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/patients'),
      ).timeout(const Duration(seconds: 30));

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

  static Future<List<UserModel>> fetchDoctors() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/doctors'),
      ).timeout(const Duration(seconds: 30));

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
      ).timeout(const Duration(seconds: 30));

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
      final url = '$baseUrl/users/doctors/$doctorId/schedule';
      print('DEBUG DashboardService: GET $url');
      final response = await http.get(
        Uri.parse(url),
      ).timeout(const Duration(seconds: 30));

      print('DEBUG DashboardService: Response Code: ${response.statusCode}');
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('DEBUG DashboardService: Success! Slots: ${data.length}');
        return List<Map<String, dynamic>>.from(data);
      } else {
        print('DEBUG DashboardService: Error ${response.statusCode}: ${response.body}');
        return [];
      }
    } catch (e) {
      print('DEBUG DashboardService: Fetch Schedule Error: $e');
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

  static Future<bool> deleteDoctorSchedule({
    required String doctorId,
    required int scheduleId,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/users/doctors/$doctorId/schedule/$scheduleId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] ?? false;
      } else {
        return false;
      }
    } catch (e) {
      print('Error deleting schedule: $e');
      return false;
    }
  }

  static Future<bool> submitStudentReport({
    required String uid,
    required int doctorId,
    required String title,
    required String description,
    Uint8List? fileBytes,
    String? fileName,
  }) async {
    try {
      var uri = Uri.parse('$baseUrl/student/upload-report');
      var request = http.MultipartRequest('POST', uri);
      
      request.fields['uid'] = uid;
      request.fields['doctor_id'] = doctorId.toString();
      request.fields['title'] = title;
      request.fields['description'] = description;

      if (fileBytes != null && fileName != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            fileBytes,
            filename: fileName,
          ),
        );
      }

      var streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] ?? false;
      } else {
        print('Failed to submit report: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error submitting report: $e');
      return false;
    }
  }

  static Future<List<StudentReportModel>> getStudentReports(String uid) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/student/$uid/reports'),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => StudentReportModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch student reports: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching student reports: $e');
      return [];
    }
  }

  static Future<List<StudentReportModel>> getDoctorStudentReports(String doctorUid) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/student/doctor/$doctorUid/reports'),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => StudentReportModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch doctor reports: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching doctor reports: $e');
      return [];
    }
  }
  static Future<List<StudentTaskModel>> getStudentTasks(String uid) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/student/tasks/$uid'),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => StudentTaskModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch tasks: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching student tasks: $e');
      return [];
    }
  }

  static Future<List<StudentTaskModel>> getDoctorAssignedTasks(String doctorUid) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/student/doctor/$doctorUid/tasks'),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => StudentTaskModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch doctor tasks: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching doctor tasks: $e');
      return [];
    }
  }

  static Future<List<UserModel>> getAllStudents() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/students'),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => UserModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch students: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching students: $e');
      return [];
    }
  }

  static Future<List<Course>> getStudentCourses(String uid) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/student/$uid/courses'),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Course.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch courses: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching student courses: $e');
      return [];
    }
  }

  static Future<List<Course>> getAvailableCourses(String uid) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/student/courses/available/$uid'),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Course.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch available courses: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching available courses: $e');
      return [];
    }
  }

  static Future<bool> enrollInCourse(String uid, int courseId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/student/enroll'),
        body: {
          'uid': uid,
          'course_id': courseId.toString(),
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] ?? false;
      } else {
        throw Exception('Failed to enroll in course: ${response.statusCode}');
      }
    } catch (e) {
      print('Error enrolling in course: $e');
      return false;
    }
  }

  static Future<bool> seedCourses() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/student/courses/seed'),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] ?? false;
      } else {
        throw Exception('Failed to seed courses: ${response.statusCode}');
      }
    } catch (e) {
      print('Error seeding courses: $e');
      return false;
    }
  }

  static Future<bool> assignStudentTask({
    int? studentId,
    int? doctorId,
    required String title,
    String? description,
    String? dueDate,
    String? colorHex,
    Uint8List? fileBytes,
    String? fileName,
  }) async {
    try {
      var uri = Uri.parse('$baseUrl/student/tasks');
      var request = http.MultipartRequest('POST', uri);
      
      request.fields['title'] = title;
      request.fields['description'] = description ?? '';
      request.fields['due_date'] = dueDate ?? '';
      request.fields['color_hex'] = colorHex ?? 'E8C998';
      if (studentId != null) {
        request.fields['student_id'] = studentId.toString();
      }
      if (doctorId != null) {
        request.fields['doctor_id'] = doctorId.toString();
      }

      if (fileBytes != null && fileName != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            fileBytes,
            filename: fileName,
          ),
        );
      }

      var streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] ?? false;
      } else {
        print('Failed to assign task: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error assigning task: $e');
      return false;
    }
  }

  static Future<bool> completeStudentTask(int taskId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/student/tasks/$taskId/complete'),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] ?? false;
      } else {
        return false;
      }
    } catch (e) {
      print('Error completing task: $e');
      return false;
    }
  }
}
