class RequirementModel {
  final int id;
  final String title;
  final String description;
  final double amount;
  final DateTime deadline;
  final int totalUsers;
  final int paid;
  final int unpaid;
  final String? status;
  final DateTime? paidAt;
  final double? amountPaid;

  RequirementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.amount,
    required this.deadline,
    required this.totalUsers,
    required this.paid,
    required this.unpaid,
    this.status,
    this.paidAt,
    this.amountPaid,
  });

  factory RequirementModel.fromJson(Map<String, dynamic> json) {
    return RequirementModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      deadline: json['deadline'] != null ? DateTime.parse(json['deadline'].toString()) : DateTime.now(),
      totalUsers: json['total_users'] ?? 0,
      paid: json['paid'] ?? 0,
      unpaid: json['unpaid'] ?? 0,
      status: json['status'],
      paidAt: json['paid_at'] != null ? DateTime.parse(json['paid_at'].toString()) : null,
      amountPaid: (json['amount_paid'] as num?)?.toDouble(),
    );
  }

  String get formattedDeadline {
    return '${deadline.day}/${deadline.month}/${deadline.year}';
  }

  String get calculatedStatus {
    if (status != null) return status!;
    
    final now = DateTime.now();
    if (paidAt != null) return 'Paid';
    if (deadline.isBefore(now)) return 'Overdue';
    return 'Pending';
  }

  bool get isPaid => calculatedStatus == 'Paid';
  bool get isOverdue => calculatedStatus == 'Overdue';
  bool get isPending => calculatedStatus == 'Pending';
  
  int get daysUntilDeadline {
    final now = DateTime.now();
    return deadline.difference(now).inDays;
  }

  double get paidPercentage {
    if (totalUsers == 0) return 0.0;
    return (paid / totalUsers) * 100;
  }
}