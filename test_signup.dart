import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final url = Uri.parse('https://graduation-backend-production-7023.up.railway.app/auth/signup');
  final body = jsonEncode({
    'name': 'Doctor Test',
    'email': 'doctor_test_' + DateTime.now().millisecondsSinceEpoch.toString() + '@example.com',
    'password': 'password123',
    'phone': '1234567890',
    'role': 'doctor',
    'department': 'Cardiology',
    'bio': 'Test bio'
  });

  print('Sending POST...');
  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );
    print('Status Code: ' + response.statusCode.toString());
    print('Response Body: ' + response.body);
  } catch (e) {
    print('Error: ' + e.toString());
  }
}
