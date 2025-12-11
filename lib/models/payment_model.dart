class PaymentModel {
  final int id;
  final int? userId;
  final int? requirementId;
  final String? requirementTitle;
  final double amountPaid;
  final DateTime? paidAt;
  final String status;
  final String? notes;
  final String? paymentMethod;
  final String? firstName;
  final String? middleName;
  final String? lastName;
  final String? studentId;

  PaymentModel({
    required this.id,
    this.userId,
    this.requirementId,
    this.requirementTitle,
    required this.amountPaid,
    this.paidAt,
    required this.status,
    this.notes,
    this.paymentMethod,
    this.firstName,
    this.middleName,
    this.lastName,
    this.studentId,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] ?? 0,
      userId: json['user_id'],
      requirementId: json['requirement_id'],
      requirementTitle: json['requirement']?['title'] ?? 'Unspecified Requirement',
      amountPaid: double.tryParse(json['amount_paid']?.toString() ?? '0') ?? 0.0,
      paidAt: json['paid_at'] != null ? DateTime.tryParse(json['paid_at'].toString()) : null,
      status: json['status']?.toString().toLowerCase() ?? 'pending',
      notes: json['notes']?.toString(),
      paymentMethod: json['payment_method']?.toString(),
      firstName: json['first_name']?.toString(),
      middleName: json['middle_name']?.toString(),
      lastName: json['last_name']?.toString(),
      studentId: json['student_id']?.toString(),
    );
  }

  String get displayName {
    final parts = [firstName, middleName, lastName].where((part) => part != null && part.isNotEmpty).toList();
    return parts.isNotEmpty ? parts.join(' ') : 'Unknown';
  }

  String get formattedDate {
    if (paidAt == null) return 'Not paid yet';
    return '${paidAt!.day}/${paidAt!.month}/${paidAt!.year}';
  }

  String get formattedDateTime {
    if (paidAt == null) return '';
    return '$formattedDate at ${paidAt!.hour}:${paidAt!.minute.toString().padLeft(2, '0')}';
  }

  bool get isPaid => status == 'paid';
  bool get isPending => status == 'pending';
  bool get isLinkedToUser => userId != null;
}