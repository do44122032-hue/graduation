import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConfig {
  // Toggle this to true for local testing, false for production (Railway)
  static bool isLocal = false; 

  static String get baseUrl {
    if (!isLocal) {
      return 'https://graduation-backend-production-7023.up.railway.app';
    }
    
    // For local testing
    if (kIsWeb) {
      return 'http://localhost:8000';
    }
    
    // For mobile/desktop
    try {
      if (!kIsWeb && Platform.isAndroid) {
        return 'http://10.0.2.2:8000';
      }
    } catch (_) {}
    
    return 'http://127.0.0.1:8000';
  }
}
