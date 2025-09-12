// enrollment.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class EventEnrollment {
  final String enrollmentId;
  final String eventId;
  final String studentUid;
  final String organizerUid;
  final String orgId;
  final String eventTitle;
  final double amountPaid;
  final String paymentStatus; // 'pending', 'completed', 'failed'
  final String enrollmentStatus; // 'registered', 'cancelled', 'completed'
  final DateTime enrolledAt;
  final DateTime? paymentCompletedAt;

  EventEnrollment({
    required this.enrollmentId,
    required this.eventId,
    required this.studentUid,
    required this.organizerUid,
    required this.orgId,
    required this.eventTitle,
    required this.amountPaid,
    required this.paymentStatus,
    required this.enrollmentStatus,
    required this.enrolledAt,
    this.paymentCompletedAt,
  });

  factory EventEnrollment.fromJson(Map<String, dynamic> json) {
    return EventEnrollment(
      enrollmentId: json['enrollmentId'] ?? '',
      eventId: json['eventId'] ?? '',
      studentUid: json['studentUid'] ?? '',
      organizerUid: json['organizerUid'] ?? '',
      orgId: json['orgId'] ?? '',
      eventTitle: json['eventTitle'] ?? '',
      amountPaid: (json['amountPaid'] ?? 0).toDouble(),
      paymentStatus: json['paymentStatus'] ?? 'pending',
      enrollmentStatus: json['enrollmentStatus'] ?? 'registered',
      enrolledAt: (json['enrolledAt'] as Timestamp).toDate(),
      paymentCompletedAt: json['paymentCompletedAt'] != null
          ? (json['paymentCompletedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enrollmentId': enrollmentId,
      'eventId': eventId,
      'studentUid': studentUid,
      'organizerUid': organizerUid,
      'orgId': orgId,
      'eventTitle': eventTitle,
      'amountPaid': amountPaid,
      'paymentStatus': paymentStatus,
      'enrollmentStatus': enrollmentStatus,
      'enrolledAt': Timestamp.fromDate(enrolledAt),
      'paymentCompletedAt': paymentCompletedAt != null
          ? Timestamp.fromDate(paymentCompletedAt!)
          : null,
    };
  }
}
