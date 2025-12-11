import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class SupportTicket {
  final int id;
  final int userId;
  final String subject;
  final String message;
  final String category;
  final String priority;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> attachments;
  final String? contactName;
  final String? contactEmail;

  SupportTicket({
    required this.id,
    required this.userId,
    required this.subject,
    required this.message,
    required this.category,
    required this.priority,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.attachments,
    this.contactName,
    this.contactEmail,
  });

  factory SupportTicket.fromJson(Map<String, dynamic> json) {
    return SupportTicket(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      subject: json['subject'] ?? '',
      message: json['message'] ?? '',
      category: json['category'] ?? 'general',
      priority: json['priority'] ?? 'medium',
      status: json['status'] ?? 'open',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString())
          : DateTime.now(),
      attachments: List<String>.from(json['attachments'] ?? []),
      contactName: json['contact_name'],
      contactEmail: json['contact_email'],
    );
  }

  String get formattedCreatedAt {
    return DateFormat('MMM dd, yyyy - hh:mm a').format(createdAt);
  }

  String get formattedUpdatedAt {
    return DateFormat('MMM dd, yyyy - hh:mm a').format(updatedAt);
  }

  IconData get statusIcon {
    switch (status.toLowerCase()) {
      case 'open':
        return Icons.mark_chat_unread;
      case 'in_progress':
        return Icons.hourglass_bottom;
      case 'resolved':
        return Icons.check_circle;
      case 'closed':
        return Icons.archive;
      default:
        return Icons.mark_chat_unread;
    }
  }

  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'open':
        return Colors.blue;
      case 'in_progress':
        return Colors.orange;
      case 'resolved':
        return Colors.green;
      case 'closed':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  IconData get priorityIcon {
    switch (priority.toLowerCase()) {
      case 'low':
        return Icons.arrow_downward;
      case 'medium':
        return Icons.remove;
      case 'high':
        return Icons.arrow_upward;
      case 'urgent':
        return Icons.warning;
      default:
        return Icons.remove;
    }
  }

  Color get priorityColor {
    switch (priority.toLowerCase()) {
      case 'low':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'high':
        return Colors.red;
      case 'urgent':
        return Colors.deepOrange;
      default:
        return Colors.orange;
    }
  }
}