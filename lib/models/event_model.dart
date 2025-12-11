class EventModel {
  final int id;
  final String title;
  final String description;
  final DateTime date;
  final String time;
  final String location;
  final String category;
  final String status;
  final int? capacity;
  final String? registered;
  final String? attendanceStatus; // New: registration status
  final DateTime? registeredAt; // New: when user registered
  final bool isRegistered; // New: calculated field

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.location,
    required this.category,
    required this.status,
    this.capacity,
    this.registered,
    this.attendanceStatus,
    this.registeredAt,
    this.isRegistered = false, // Default to false
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      date: json['date'] != null ? DateTime.parse(json['date'].toString()) : DateTime.now(),
      time: json['time'] ?? '',
      location: json['location'] ?? '',
      category: json['category'] ?? 'General',
      status: json['status'] ?? json['event_status'] ?? 'upcoming', // Handle both fields
      capacity: json['capacity'],
      registered: json['registered'],
      attendanceStatus: json['attendance_status'],
      registeredAt: json['registered_at'] != null 
          ? DateTime.parse(json['registered_at'].toString()) 
          : null,
      isRegistered: json['attendance_status'] != null, // User is registered if attendance_status exists
    );
  }

  // Helper method to create a copy with updated fields
  EventModel copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? date,
    String? time,
    String? location,
    String? category,
    String? status,
    int? capacity,
    String? registered,
    String? attendanceStatus,
    DateTime? registeredAt,
    bool? isRegistered,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      time: time ?? this.time,
      location: location ?? this.location,
      category: category ?? this.category,
      status: status ?? this.status,
      capacity: capacity ?? this.capacity,
      registered: registered ?? this.registered,
      attendanceStatus: attendanceStatus ?? this.attendanceStatus,
      registeredAt: registeredAt ?? this.registeredAt,
      isRegistered: isRegistered ?? this.isRegistered,
    );
  }

  String get formattedDate {
    return '${date.day}/${date.month}/${date.year}';
  }

  String get formattedDateTime {
    return '$formattedDate at $time';
  }

  bool get isUpcoming {
    final now = DateTime.now();
    return date.isAfter(now) || (date.day == now.day && date.month == now.month && date.year == now.year);
  }

  bool get isPast => !isUpcoming;
  
  bool get isOngoing {
    // An event is ongoing if it's today and within reasonable hours (or you could have a separate field)
    final now = DateTime.now();
    return date.day == now.day && date.month == now.month && date.year == now.year;
  }
  
  bool get isFull {
    if (capacity == null || registered == null) return false;
    final registeredCount = int.tryParse(registered!) ?? 0;
    return registeredCount >= capacity!;
  }
  
  // Check if registration can be cancelled (before event date)
  bool get canCancelRegistration {
    if (!isRegistered) return false;
    final now = DateTime.now();
    return date.isAfter(now); // Can cancel if event is in the future
  }
  
  // Check if registration is open (not full and not past)
  bool get canRegister {
    return !isFull && !isPast && !isRegistered;
  }
}