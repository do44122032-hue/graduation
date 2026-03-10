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
}
