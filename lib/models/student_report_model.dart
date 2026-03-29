class StudentReportModel {
  final int id;
  final int studentId;
  final int doctorId;
  final String title;
  final String description;
  final String? fileUrl;
  final String status;
  final String submittedAt;
  final String? studentName;

  StudentReportModel({
    required this.id,
    required this.studentId,
    required this.doctorId,
    required this.title,
    required this.description,
    this.fileUrl,
    required this.status,
    required this.submittedAt,
    this.studentName,
  });

  factory StudentReportModel.fromJson(Map<String, dynamic> json) {
    return StudentReportModel(
      id: json['id'],
      studentId: json['studentId'],
      doctorId: json['doctorId'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      fileUrl: json['fileUrl'],
      status: json['status'] ?? 'submitted',
      submittedAt: json['submittedAt'] ?? '',
      studentName: json['studentName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'doctorId': doctorId,
      'title': title,
      'description': description,
      'fileUrl': fileUrl,
      'status': status,
      'submittedAt': submittedAt,
      'studentName': studentName,
    };
  }
}
