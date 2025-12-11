import 'package:intl/intl.dart';

class RequirementModel {
  final int id;
  final String title;
  final String description;
  final double amount;
  final DateTime deadline;
  final String? status; // From API: "paid" or "unpaid"
  final DateTime? paidAt;
  final double? amountPaid;

  RequirementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.amount,
    required this.deadline,
    this.status,
    this.paidAt,
    this.amountPaid,
  });

  factory RequirementModel.fromJson(Map<String, dynamic> json) {
    return RequirementModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      deadline: json['deadline'] != null 
          ? DateTime.parse(json['deadline'].toString()) 
          : DateTime.now().add(const Duration(days: 30)), // Default to 30 days from now
      status: json['status']?.toString(),
      paidAt: json['paid_at'] != null 
          ? DateTime.tryParse(json['paid_at'].toString()) 
          : null,
      amountPaid: json['amount_paid'] != null 
          ? double.tryParse(json['amount_paid'].toString()) 
          : null,
    );
  }

  String get formattedDeadline {
    return DateFormat('dd/MM/yyyy').format(deadline);
  }

  String get calculatedStatus {
    if (status != null) {
      return status!; // Use API status if available
    }
    
    final now = DateTime.now();
    if (paidAt != null || amountPaid != null) return 'Paid';
    if (deadline.isBefore(now)) return 'Overdue';
    return 'Pending';
  }

  bool get isPaid {
    final calculated = calculatedStatus.toLowerCase();
    return calculated == 'paid' || 
           (status?.toLowerCase() == 'paid') || 
           paidAt != null || 
           amountPaid != null;
  }
  
  bool get isOverdue {
    if (isPaid) return false;
    final now = DateTime.now();
    return deadline.isBefore(now);
  }
  
  bool get isPending => !isPaid && !isOverdue;
  
  int get daysUntilDeadline {
    final now = DateTime.now();
    return deadline.difference(now).inDays;
  }
}