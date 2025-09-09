import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:event_board/data/services/network_service.dart';

import '../../data/model/organization.dart';
import '../../data/model/student.dart';

class AdminUsersController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NetworkService _networkService = Get.find();

  final RxList<Student> students = <Student>[].obs;
  final RxList<Organization> organizers = <Organization>[].obs;
  final RxBool isLoading = true.obs;

  DocumentSnapshot? _lastStudentDoc;
  DocumentSnapshot? _lastOrgDoc;
  static const int _pageSize = 10;

  @override
  void onInit() {
    super.onInit();
    loadUsers(refresh: true);
  }

  Future<void> loadUsers({bool refresh = false}) async {
    try {
      if (!await _networkService.isConnected) {
        Get.snackbar('No Internet', 'Please check your internet connection.');
        isLoading.value = false;
        return;
      }
      if (refresh) {
        isLoading.value = true;
        _lastStudentDoc = null;
        _lastOrgDoc = null;
        students.clear();
        organizers.clear();
      }

      await _loadStudents();
      await _loadOrganizers();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load users: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadStudents() async {
    try {
      if (!await _networkService.isConnected) {
        throw Exception('No Internet Connection');
      }
      Query query = _firestore.collectionGroup('details').limit(_pageSize);

      if (_lastStudentDoc != null) {
        query = query.startAfterDocument(_lastStudentDoc!);
      }

      QuerySnapshot snapshot = await query.get();

      if (snapshot.docs.isNotEmpty) {
        _lastStudentDoc = snapshot.docs.last;

        final newStudents = snapshot.docs
            .map((doc) => Student.fromJson(doc.data() as Map<String, dynamic>))
            .toList();

        students.addAll(newStudents);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load students: ${e.toString()}');
    }
  }

  Future<void> _loadOrganizers() async {
    try {
      if (!await _networkService.isConnected) {
        throw Exception('No Internet Connection');
      }
      Query query = _firestore
          .collection('organizations')
          .orderBy('createdAt', descending: true)
          .limit(_pageSize);

      if (_lastOrgDoc != null) {
        query = query.startAfterDocument(_lastOrgDoc!);
      }

      final snapshot = await query.get();

      if (snapshot.docs.isNotEmpty) {
        _lastOrgDoc = snapshot.docs.last;
        final newOrgs = snapshot.docs
            .map((doc) =>
                Organization.fromJson(doc.data() as Map<String, dynamic>))
            .toList();
        organizers.addAll(newOrgs);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load organizers: ${e.toString()}');
    }
  }

  Future<void> deleteUser(String uid, String userType) async {
    try {
      if (!await _networkService.isConnected) {
        Get.snackbar('No Internet', 'Please check your internet connection.');
        return;
      }
      if (userType == 'student') {
        await _firestore.collection('students').doc(uid).delete();
        students.removeWhere((student) => student.uid == uid);
      } else if (userType == 'organizer') {
        await _firestore.collection('organizations').doc(uid).delete();
        organizers.removeWhere((org) => org.orgId == uid);
      }

      Get.snackbar('Success', 'User deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete user: ${e.toString()}');
    }
  }

  Future<void> refreshUsers() async {
    await loadUsers(refresh: true);
  }
}
