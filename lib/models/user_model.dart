import '../enums/user_role.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? profilePicture;
  final String? phoneNumber;
  final String? department;
  final String? bio;
  final bool isActive;

  final String? age;
  final String? bloodType;
  final String? height;
  final String? weight;
  final String? dateOfBirth;
  final String? socialStatus;
  final List<String>? chronicConditions;
  final List<String>? medications;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.profilePicture,
    this.phoneNumber,
    this.department,
    this.bio,
    this.isActive = false,
    this.age,
    this.bloodType,
    this.height,
    this.weight,
    this.dateOfBirth,
    this.socialStatus,
    this.chronicConditions,
    this.medications,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => UserRole.patient,
      ),
      profilePicture: json['profilePicture'],
      phoneNumber: json['phoneNumber'],
      department: json['department'],
      bio: json['bio'],
      isActive: json['isActive'] ?? false,
      age: json['age'],
      bloodType: json['bloodType'],
      height: json['height'],
      weight: json['weight'],
      dateOfBirth: json['dateOfBirth'],
      socialStatus: json['socialStatus'],
      chronicConditions: json['chronicConditions'] != null
          ? List<String>.from(json['chronicConditions'])
          : [],
      medications: json['medications'] != null
          ? List<String>.from(json['medications'])
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.name,
      'profilePicture': profilePicture,
      'phoneNumber': phoneNumber,
      'department': department,
      'bio': bio,
      'isActive': isActive,
      'age': age,
      'bloodType': bloodType,
      'height': height,
      'weight': weight,
      'dateOfBirth': dateOfBirth,
      'socialStatus': socialStatus,
      'chronicConditions': chronicConditions,
      'medications': medications,
    };
  }
}
