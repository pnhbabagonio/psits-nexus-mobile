class UserModel {
  final int id;
  final String? firstName;
  final String? middleName;
  final String? lastName;
  final String name; // Fallback from Laravel
  final String email;
  final String? studentId;
  final String program;
  final String year;
  final String role;
  final String status;
  final DateTime? lastLogin;
  final DateTime createdAt;

  UserModel({
    required this.id,
    this.firstName,
    this.middleName,
    this.lastName,
    required this.name,
    required this.email,
    this.studentId,
    required this.program,
    required this.year,
    required this.role,
    required this.status,
    this.lastLogin,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      firstName: json['first_name'],
      middleName: json['middle_name'],
      lastName: json['last_name'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      studentId: json['student_id'],
      program: json['program'] ?? '',
      year: json['year'] ?? '',
      role: json['role'] ?? 'Member',
      status: json['status'] ?? 'active',
      lastLogin: json['last_login'] != null 
          ? DateTime.parse(json['last_login'].toString())
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
    );
  }

  // Get full name using Laravel's logic
  String get fullName {
    final parts = [firstName, middleName, lastName].where((part) => part != null && part.isNotEmpty).toList();
    return parts.isNotEmpty ? parts.join(' ') : name;
  }

  String get formattedLastLogin {
    if (lastLogin == null) return 'Never';
    return '${lastLogin!.day}/${lastLogin!.month}/${lastLogin!.year} ${lastLogin!.hour}:${lastLogin!.minute.toString().padLeft(2, '0')}';
  }

  String get formattedMemberSince {
    return '${createdAt.month}/${createdAt.year}';
  }

  bool get isOfficer => role == 'Officer' || role == 'Admin';
  bool get isActive => status == 'active';
}