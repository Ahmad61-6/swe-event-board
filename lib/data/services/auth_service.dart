import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:event_board/data/services/network_service.dart';
import 'package:get_storage/get_storage.dart';

import '../../constants/app_constants.dart';
import '../model/admin.dart';
import '../model/organization.dart';
import '../model/student.dart';

class AuthService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final GetStorage _getStorage = GetStorage();
  final NetworkService _networkService = Get.find();

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> signOut() async {
    if (!await _networkService.isConnected) {
      throw Exception('No Internet Connection');
    }
    await _auth.signOut();
    _getStorage.remove(AppConstants.userProfileKey);
    _getStorage.remove(AppConstants.userRoleKey);
  }

  Future<Map<String, dynamic>?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      if (!await _networkService.isConnected) {
        throw Exception('No Internet Connection');
      }
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      Map<String, dynamic>? userData = await _getUserData(
        userCredential.user!.uid,
      );
      if (userData != null) {
        _getStorage.write(AppConstants.userProfileKey, userData['profile']);
        _getStorage.write(AppConstants.userRoleKey, userData['role']);
      }

      return userData;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> signUpStudent({
    required String email,
    required String password,
    required String fullName,
    required String studentId,
    required String batch,
    required List<String> interests,
    File? image,
  }) async {
    try {
      if (!await _networkService.isConnected) {
        throw Exception('No Internet Connection');
      }
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      String? profileImageUrl;
      if (image != null) {
        final ref = _storage
            .ref()
            .child('profile_images')
            .child('${userCredential.user!.uid}.jpg');
        await ref.putFile(image);
        profileImageUrl = await ref.getDownloadURL();
      }

      Student student = Student(
        uid: userCredential.user!.uid,
        displayName: fullName,
        email: email,
        profileImageUrl: profileImageUrl,
        studentId: studentId,
        batch: batch,
        interests: interests,
        fcmTokens: [],
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('students')
          .doc(userCredential.user!.uid)
          .collection('details')
          .doc('profile')
          .set(student.toJson());

      _getStorage.write(AppConstants.userProfileKey, student.toJson());
      _getStorage.write(AppConstants.userRoleKey, AppConstants.roleStudent);

      return {'profile': student.toJson(), 'role': AppConstants.roleStudent};
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> signUpOrganizer({
    required String email,
    required String password,
    required String fullName,
    required String organizationName,
    required String organizationType,
    required String contactPhone,
    File? image,
  }) async {
    try {
      if (!await _networkService.isConnected) {
        throw Exception('No Internet Connection');
      }
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      String orgId = _firestore.collection('organizations').doc().id;

      String? logoUrl;
      if (image != null) {
        final ref = _storage
            .ref()
            .child('organization_logos')
            .child('$orgId.jpg');
        await ref.putFile(image);
        logoUrl = await ref.getDownloadURL();
      }

      Organization organization = Organization(
        orgId: orgId,
        ownerUid: userCredential.user!.uid,
        ownerFullName: fullName,
        name: organizationName,
        type: organizationType,
        contactEmail: email,
        contactPhone: contactPhone,
        logoUrl: logoUrl,
        approved: false,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('organizations')
          .doc(orgId)
          .set(organization.toJson());

      _getStorage.write(AppConstants.userProfileKey, organization.toJson());
      _getStorage.write(AppConstants.userRoleKey, AppConstants.roleOrganizer);

      return {
        'profile': organization.toJson(),
        'role': AppConstants.roleOrganizer,
      };
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> signUpAdmin({
    required String email,
    required String password,
    required String adminCode,
  }) async {
    try {
      if (!await _networkService.isConnected) {
        throw Exception('No Internet Connection');
      }
      if (adminCode != AppConstants.adminCode) {
        throw Exception('Invalid admin code');
      }

      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      Admin admin = Admin(
        uid: userCredential.user!.uid,
        email: email,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('admins')
          .doc(userCredential.user!.uid)
          .collection('details')
          .doc('profile')
          .set(admin.toJson());

      _getStorage.write(AppConstants.userProfileKey, admin.toJson());
      _getStorage.write(AppConstants.userRoleKey, AppConstants.roleAdmin);

      return {'profile': admin.toJson(), 'role': AppConstants.roleAdmin};
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> _getUserData(String uid) async {
    try {
      if (!await _networkService.isConnected) {
        throw Exception('No Internet Connection');
      }
      DocumentSnapshot studentDoc = await _firestore
          .collection('students')
          .doc(uid)
          .collection('details')
          .doc('profile')
          .get();

      if (studentDoc.exists) {
        return {'profile': studentDoc.data(), 'role': AppConstants.roleStudent};
      }

      DocumentSnapshot adminDoc = await _firestore
          .collection('admins')
          .doc(uid)
          .collection('details')
          .doc('profile')
          .get();

      if (adminDoc.exists) {
        return {'profile': adminDoc.data(), 'role': AppConstants.roleAdmin};
      }

      QuerySnapshot orgSnapshot = await _firestore
          .collection('organizations')
          .where('ownerUid', isEqualTo: uid)
          .get();

      if (orgSnapshot.docs.isNotEmpty) {
        DocumentSnapshot orgDoc = orgSnapshot.docs.first;
        return {'profile': orgDoc.data(), 'role': AppConstants.roleOrganizer};
      }

      return null;
    } catch (e) {
      return null;
    }
  }
}
