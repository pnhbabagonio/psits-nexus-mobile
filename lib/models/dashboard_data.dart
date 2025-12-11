// models/dashboard_data.dart
class DashboardData {
  final int upcomingEvents;
  final int pendingPayments;
  final String memberSince;
  final RecentPayment? recentPayment;

  DashboardData({
    required this.upcomingEvents,
    required this.pendingPayments,
    required this.memberSince,
    this.recentPayment,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      upcomingEvents: json['upcoming_events'] ?? 0,
      pendingPayments: json['pending_payments'] ?? 0,
      memberSince: json['member_since'] ?? '',
      recentPayment: json['recent_payment'] != null
          ? RecentPayment.fromJson(json['recent_payment'])
          : null,
    );
  }
}

class RecentPayment {
  final String amount;
  final String date;
  final String requirement;

  RecentPayment({
    required this.amount,
    required this.date,
    required this.requirement,
  });

  factory RecentPayment.fromJson(Map<String, dynamic> json) {
    return RecentPayment(
      amount: json['amount'] ?? '0.00',
      date: json['date'] ?? '',
      requirement: json['requirement'] ?? '',
    );
  }
}