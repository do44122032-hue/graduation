class StudentTaskModel {
  final int id;
  final int? studentId;
  final String title;
  final String description;
  final String dueDate;
  final String? colorHex;
  final String? fileUrl;
  final String status;

  StudentTaskModel({
    required this.id,
    this.studentId,
    required this.title,
    required this.description,
    required this.dueDate,
    this.colorHex,
    this.fileUrl,
    required this.status,
  });

  factory StudentTaskModel.fromJson(Map<String, dynamic> json) {
    return StudentTaskModel(
      id: json['id'],
      studentId: json['studentId'],
      title: json['title'],
      description: json['description'] ?? '',
      dueDate: json['dueDate'] ?? '',
      colorHex: json['colorHex'] ?? 'E8C998',
      fileUrl: json['fileUrl'],
      status: json['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'title': title,
      'description': description,
      'dueDate': dueDate,
      'colorHex': colorHex,
      'fileUrl': fileUrl,
      'status': status,
    };
  }
}
