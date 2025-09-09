import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../constants/app_constants.dart';
import '../model/admin.dart';
import '../model/organization.dart';
import '../model/student.dart';

class AuthService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GetStorage _storage = GetStorage();

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> signOut() async {
    await _auth.signOut();
    _storage.remove(AppConstants.userProfileKey);
    _storage.remove(AppConstants.userRoleKey);
  }

  Future<Map<String, dynamic>?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      Map<String, dynamic>? userData = await _getUserData(
        userCredential.user!.uid,
      );
      if (userData != null) {
        _storage.write(AppConstants.userProfileKey, userData['profile']);
        _storage.write(AppConstants.userRoleKey, userData['role']);
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
  }) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      Student student = Student(
        uid: userCredential.user!.uid,
        displayName: fullName,
        email: email,
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

      _storage.write(AppConstants.userProfileKey, student.toJson());
      _storage.write(AppConstants.userRoleKey, AppConstants.roleStudent);

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
    String? logoUrl,
  }) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      String orgId = _firestore.collection('organizations').doc().id;

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

      _storage.write(AppConstants.userProfileKey, organization.toJson());
      _storage.write(AppConstants.userRoleKey, AppConstants.roleOrganizer);

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

      _storage.write(AppConstants.userProfileKey, admin.toJson());
      _storage.write(AppConstants.userRoleKey, AppConstants.roleAdmin);

      return {'profile': admin.toJson(), 'role': AppConstants.roleAdmin};
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> _getUserData(String uid) async {
    try {
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