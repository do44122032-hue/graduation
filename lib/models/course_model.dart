import 'package:flutter/material.dart';

class Course {
  final String id;
  final String title;
  final String instructor;
  final double progress;
  final String nextClass;
  final String? imageAsset;
  final Color color;
  final IconData icon;
  final String grade;

  Course({
    required this.id,
    required this.title,
    required this.instructor,
    required this.progress,
    required this.nextClass,
    this.imageAsset,
    required this.color,
    required this.icon,
    required this.grade,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      instructor: json['instructor'] ?? '',
      progress: (json['progress'] ?? 0.0).toDouble(),
      nextClass: json['nextClass'] ?? '',
      color: _parseColor(json['colorHex'] ?? 'E8C998'),
      icon: _getIconData(json['iconName'] ?? 'school'),
      grade: json['grade'] ?? 'Pending',
    );
  }

  static Color _parseColor(String hex) {
    try {
      return Color(int.parse("FF$hex", radix: 16));
    } catch (_) {
      return const Color(0xFFE8C998);
    }
  }

  static IconData _getIconData(String name) {
    switch (name) {
      case 'monitor_heart': return Icons.monitor_heart_outlined;
      case 'medical_services': return Icons.medical_services;
      case 'gavel': return Icons.gavel;
      case 'science': return Icons.science;
      case 'medication': return Icons.medication;
      case 'school': return Icons.school_outlined;
      default: return Icons.book_outlined;
    }
  }
}
