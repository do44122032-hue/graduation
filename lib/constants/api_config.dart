import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConfig {
  // Toggle this to true for local testing, false for production (Railway)
  static bool isLocal = false; 

  // IMPORTANT: For physical devices (True phone), replace 'localhost' with your 
  // machine's actual local IP address (e.g. '192.168.1.100').
  // You can find this by running 'ipconfig' (Windows) or 'ifconfig' (Mac/Linux) in your terminal.
  static const String localMachineIp = '192.168.68.104'; 

  static String get baseUrl {
    if (!isLocal) {
      return 'https://graduation-backend-production-7023.up.railway.app';
    }
    
    // For local testing
    if (kIsWeb) {
      // In web, 'localhost' refers to the machine running the browser
      return 'http://localhost:8000';
    }
    
    // For mobile/desktop
    try {
      if (Platform.isAndroid) {
        // Use machine's actual IP for all Android devices to support physical phones
        return 'http://$localMachineIp:8000';
      }
      if (Platform.isIOS || Platform.isMacOS || Platform.isWindows) {
        return 'http://localhost:8000';
      }
    } catch (_) {
      // Fallback if Platform checks fail (e.g. on web if kIsWeb wasn't caught)
      return 'http://localhost:8000';
    }
    
    // Default fallback
    return 'http://$localMachineIp:8000';
  }
}
