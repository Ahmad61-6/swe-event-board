import 'package:cloud_firestore/cloud_firestore.dart';

class Organization {
  final String orgId;
  final String ownerUid;
  final String ownerFullName;
  final String name;
  final String type;
  final String contactEmail;
  final String contactPhone;
  final String? logoUrl;
  final String? bannerImageUrl;
  final bool approved;
  final DateTime createdAt;

  Organization({
    required this.orgId,
    required this.ownerUid,
    required this.ownerFullName,
    required this.name,
    required this.type,
    required this.contactEmail,
    required this.contactPhone,
    this.logoUrl,
    this.bannerImageUrl,
    required this.approved,
    required this.createdAt,
  });

  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      orgId: json['orgId'] ?? '',
      ownerUid: json['ownerUid'] ?? '',
      ownerFullName: json['ownerFullName'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      contactEmail: json['contactEmail'] ?? '',
      contactPhone: json['contactPhone'] ?? '',
      logoUrl: json['logoUrl'],
      bannerImageUrl: json['bannerImageUrl'],
      approved: json['approved'] ?? false,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orgId': orgId,
      'ownerUid': ownerUid,
      'ownerFullName': ownerFullName,
      'name': name,
      'type': type,
      'contactEmail': contactEmail,
      'contactPhone': contactPhone,
      'logoUrl': logoUrl,
      'bannerImageUrl': bannerImageUrl,
      'approved': approved,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
