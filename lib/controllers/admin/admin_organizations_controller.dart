import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../data/model/organization.dart';

class AdminOrganizationsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxList<Organization> organizations = <Organization>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isUpdating = false.obs;

  DocumentSnapshot? _lastOrgDoc;
  static const int _pageSize = 10;

  @override
  void onInit() {
    super.onInit();
    loadOrganizations(refresh: true);
  }

  Future<void> loadOrganizations({bool refresh = false}) async {
    try {
      if (refresh) {
        isLoading.value = true;
        _lastOrgDoc = null;
        organizations.clear();
      }

      Query query = _firestore
          .collection('organizations')
          .orderBy('createdAt', descending: true);

      if (_lastOrgDoc != null) {
        query = query.startAfterDocument(_lastOrgDoc!);
      }

      query = query.limit(_pageSize);

      final snapshot = await query.get();

      if (snapshot.docs.isNotEmpty) {
        _lastOrgDoc = snapshot.docs.last;
        final newOrgs = snapshot.docs
            .map(
              (doc) =>
                  Organization.fromJson(doc.data() as Map<String, dynamic>),
            )
            .toList();
        organizations.addAll(newOrgs);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load organizations: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> approveOrganization(String orgId, bool approve) async {
    try {
      isUpdating.value = true;

      await _firestore.collection('organizations').doc(orgId).update({
        'approved': approve,
      });

      final index = organizations.indexWhere((org) => org.orgId == orgId);
      if (index != -1) {
        final org = organizations[index];
        organizations[index] = Organization(
          orgId: org.orgId,
          ownerUid: org.ownerUid,
          name: org.name,
          type: org.type,
          contactEmail: org.contactEmail,
          approved: approve,
          createdAt: org.createdAt,
          ownerFullName: '',
          contactPhone: '',
        );
      }

      Get.snackbar(
        'Success',
        approve ? 'Organization approved' : 'Organization rejected',
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update organization approval: ${e.toString()}',
      );
    } finally {
      isUpdating.value = false;
    }
  }

  Future<void> refreshOrganizations() async {
    await loadOrganizations(refresh: true);
  }
}
