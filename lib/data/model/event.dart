import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String eventId;
  final String title;
  final String description;
  final String type;
  final String bannerUrl;
  final DateTime startAt;
  final DateTime endAt;
  final String venue;
  final String meetLink;
  final double price;
  final int capacity;
  final String createdByUid;
  final String
  approvalStatus; // Changed from bool approved to String approvalStatus
  final int enrolledCount;
  final bool conflict;
  final DateTime createdAt;

  Event({
    required this.eventId,
    required this.title,
    required this.description,
    required this.type,
    required this.bannerUrl,
    required this.startAt,
    required this.endAt,
    required this.venue,
    required this.meetLink,
    required this.price,
    required this.capacity,
    required this.createdByUid,
    required this.approvalStatus,
    required this.enrolledCount,
    required this.conflict,
    required this.createdAt,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      eventId: json['eventId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? '',
      bannerUrl: json['bannerUrl'] ?? '',
      startAt: (json['startAt'] as Timestamp).toDate(),
      endAt: (json['endAt'] as Timestamp).toDate(),
      venue: json['venue'] ?? '',
      meetLink: json['meetLink'] ?? '',
      price: (json['price'] is int)
          ? (json['price'] as int).toDouble()
          : (json['price'] ?? 0).toDouble(),
      capacity: json['capacity'] ?? 0,
      createdByUid: json['createdByUid'] ?? '',
      approvalStatus: json['approvalStatus'] ?? 'pending',
      enrolledCount: json['enrolledCount'] ?? 0,
      conflict: json['conflict'] ?? false,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eventId': eventId,
      'title': title,
      'description': description,
      'type': type,
      'bannerUrl': bannerUrl,
      'startAt': Timestamp.fromDate(startAt),
      'endAt': Timestamp.fromDate(endAt),
      'venue': venue,
      'meetLink': meetLink,
      'price': price,
      'capacity': capacity,
      'createdByUid': createdByUid,
      'approvalStatus': approvalStatus,
      'enrolledCount': enrolledCount,
      'conflict': conflict,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
