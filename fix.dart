import 'dart:io';

void main() {
  final file = File('lib/screens/student/patient_case_study.dart');
  String content = file.readAsStringSync();
  
  // Remove the static field definitions
  content = content.replaceFirst('static const Color bgColor = Color(0xFFF7F7F7);', '');
  content = content.replaceFirst('static const Color whiteColor = Color(0xFFFFFFFF);', '');
  content = content.replaceFirst('static const Color charcoalColor = Color(0xFF282828);', '');
  content = content.replaceFirst('static const Color secondaryTextColor = Color(0xFF4A4A4A);', '');
  
  // Replace the definitions with dynamic Theme Lookups
  content = content.replaceAll('bgColor', 'Theme.of(context).scaffoldBackgroundColor');
  content = content.replaceAll('whiteColor', 'Theme.of(context).cardColor');
  content = content.replaceAll('charcoalColor', '(Theme.of(context).textTheme.bodyLarge?.color ?? const Color(0xFF282828))');
  content = content.replaceAll('secondaryTextColor', '(Theme.of(context).textTheme.bodyMedium?.color ?? const Color(0xFF4A4A4A))');
  
  // Remove "const " keyword from widgets
  content = content.replaceAll('const Text(', 'Text(');
  content = content.replaceAll('const TextStyle(', 'TextStyle(');
  content = content.replaceAll('const TextSpan(', 'TextSpan(');
  content = content.replaceAll('const Icon(', 'Icon(');
  content = content.replaceAll('const Padding(', 'Padding(');
  content = content.replaceAll('const SizedBox(', 'SizedBox(');
  content = content.replaceAll('const Row(', 'Row(');
  content = content.replaceAll('const Column(', 'Column(');
  content = content.replaceAll('const Container(', 'Container(');
  content = content.replaceAll('const BoxDecoration(', 'BoxDecoration(');
  content = content.replaceAll('const BorderDirectional(', 'BorderDirectional(');
  content = content.replaceAll('const Center(', 'Center(');
  content = content.replaceAll('const Expanded(', 'Expanded(');
  content = content.replaceAll('const Stack(', 'Stack(');
  content = content.replaceAll('const RichText(', 'RichText(');
  content = content.replaceAll('const Positioned(', 'Positioned(');
  content = content.replaceAll('const ClipRRect(', 'ClipRRect(');
  
  file.writeAsStringSync(content);
}
