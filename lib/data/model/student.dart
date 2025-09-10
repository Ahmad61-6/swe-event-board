import 'package:cloud_firestore/cloud_firestore.dart';

class Student {
  final String uid;
  final String displayName;
  final String email;
  final String? profileImageUrl;
  final String studentId;
  final String batch;
  final List<String> interests;
  final List<String> fcmTokens;
  final DateTime createdAt;

  Student({
    required this.uid,
    required this.displayName,
    required this.email,
    this.profileImageUrl,
    required this.studentId,
    required this.batch,
    required this.interests,
    required this.fcmTokens,
    required this.createdAt,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      uid: json['uid'] ?? '',
      displayName: json['displayName'] ?? '',
      email: json['email'] ?? '',
      profileImageUrl: json['profileImageUrl'],
      studentId: json['studentId'] ?? '',
      batch: json['batch'] ?? '',
      interests: List<String>.from(json['interests'] ?? []),
      fcmTokens: List<String>.from(json['fcmTokens'] ?? []),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'displayName': displayName,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'studentId': studentId,
      'batch': batch,
      'interests': interests,
      'fcmTokens': fcmTokens,
      'createdAt': createdAt,
    };
  }

  Student copyWith({String? profileImageUrl}) {
    return Student(
      uid: uid,
      displayName: displayName,
      email: email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      studentId: studentId,
      batch: batch,
      interests: interests,
      fcmTokens: fcmTokens,
      createdAt: createdAt,
    );
  }
}
