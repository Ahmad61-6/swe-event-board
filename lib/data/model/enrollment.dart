import 'package:cloud_firestore/cloud_firestore.dart';

class Enrollment {
  final String enrollId;
  final String studentUid;
  final DateTime registeredAt;
  final String status;
  final double pricePaid;

  Enrollment({
    required this.enrollId,
    required this.studentUid,
    required this.registeredAt,
    required this.status,
    required this.pricePaid,
  });

  factory Enrollment.fromJson(Map<String, dynamic> json) {
    return Enrollment(
      enrollId: json['enrollId'] ?? '',
      studentUid: json['studentUid'] ?? '',
      registeredAt: (json['registeredAt'] as Timestamp).toDate(),
      status: json['status'] ?? 'registered',
      pricePaid: (json['pricePaid'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enrollId': enrollId,
      'studentUid': studentUid,
      'registeredAt': Timestamp.fromDate(registeredAt),
      'status': status,
      'pricePaid': pricePaid,
    };
  }
}
