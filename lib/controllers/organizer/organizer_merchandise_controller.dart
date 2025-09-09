import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';

import '../../data/model/organization.dart';
import '../auth_controller.dart';

class MerchandiseItem {
  final String itemId;
  final String title;
  final String description;
  final String photoUrl;
  final double price;
  final String currency;
  final int stock;
  final int soldCount;
  final DateTime createdAt;

  MerchandiseItem({
    required this.itemId,
    required this.title,
    required this.description,
    required this.photoUrl,
    required this.price,
    required this.currency,
    required this.stock,
    required this.soldCount,
    required this.createdAt,
  });

  factory MerchandiseItem.fromJson(Map<String, dynamic> json) {
    return MerchandiseItem(
      itemId: json['itemId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      photoUrl: json['photoUrl'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'INR',
      stock: json['stock'] ?? 0,
      soldCount: json['soldCount'] ?? 0,
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itemId': itemId,
      'title': title,
      'description': description,
      'photoUrl': photoUrl,
      'price': price,
      'currency': currency,
      'stock': stock,
      'soldCount': soldCount,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

class MerchandiseOrder {
  final String orderId;
  final String buyerUid;
  final int quantity;
  final double amount;
  final String status;
  final DateTime createdAt;

  MerchandiseOrder({
    required this.orderId,
    required this.buyerUid,
    required this.quantity,
    required this.amount,
    required this.status,
    required this.createdAt,
  });

  factory MerchandiseOrder.fromJson(Map<String, dynamic> json) {
    return MerchandiseOrder(
      orderId: json['orderId'] ?? '',
      buyerUid: json['buyerUid'] ?? '',
      quantity: json['quantity'] ?? 0,
      amount: (json['amount'] ?? 0).toDouble(),
      status: json['status'] ?? 'pending',
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }
}

class OrganizerMerchandiseController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final Rx<Organization?> organization = Rx<Organization?>(null);
  final RxList<MerchandiseItem> items = <MerchandiseItem>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isCreating = false.obs;

  DocumentSnapshot? _lastItemDoc;
  static const int _pageSize = 10;

  @override
  void onInit() {
    super.onInit();
    _loadOrganizationProfile();
  }

  Future<void> _loadOrganizationProfile() async {
    try {
      isLoading.value = true;
      final user = Get.find<AuthController>().user.value;
      if (user == null) {
        isLoading.value = false;
        return;
      }

      final snapshot = await _firestore
          .collection('organizations')
          .where('ownerUid', isEqualTo: user.uid)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        organization.value = Organization.fromJson(
            snapshot.docs.first.data() as Map<String, dynamic>);
        await loadMerchandiseItems(refresh: true);
      } else {
        Get.snackbar('Error', 'Organization profile not found.');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load organization profile: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMerchandiseItems({bool refresh = false}) async {
    if (organization.value == null) return;

    try {
      if (refresh) {
        _lastItemDoc = null;
        items.clear();
      }

      Query query = _firestore
          .collection('organizations')
          .doc(organization.value!.orgId)
          .collection('merchandise')
          .orderBy('createdAt', descending: true);

      if (_lastItemDoc != null) {
        query = query.startAfterDocument(_lastItemDoc!);
      }

      query = query.limit(_pageSize);

      QuerySnapshot snapshot = await query.get();

      if (snapshot.docs.isNotEmpty) {
        _lastItemDoc = snapshot.docs.last;

        List<MerchandiseItem> newItems = snapshot.docs
            .map((doc) =>
                MerchandiseItem.fromJson(doc.data() as Map<String, dynamic>))
            .toList();

        if (refresh) {
          items.value = newItems;
        } else {
          items.addAll(newItems);
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load merchandise: ${e.toString()}');
    }
  }

  Future<String?> uploadItemImage(File imageFile) async {
    if (organization.value == null) return null;
    try {
      final storageRef = _storage.ref(
          'organizations/${organization.value!.orgId}/merchandise/${DateTime.now().millisecondsSinceEpoch}.jpg');
      UploadTask uploadTask = storageRef.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      Get.snackbar('Error', 'Failed to upload image: ${e.toString()}');
      return null;
    }
  }

  Future<void> createMerchandiseItem(MerchandiseItem item) async {
    if (organization.value == null) return;

    try {
      isCreating.value = true;

      final itemId = _firestore.collection('temp').doc().id;
      final newItem = MerchandiseItem(
        itemId: itemId,
        title: item.title,
        description: item.description,
        photoUrl: item.photoUrl,
        price: item.price,
        currency: item.currency,
        stock: item.stock,
        soldCount: 0,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('organizations')
          .doc(organization.value!.orgId)
          .collection('merchandise')
          .doc(itemId)
          .set(newItem.toJson());

      items.insert(0, newItem);

      Get.snackbar('Success', 'Merchandise item created successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to create merchandise item: ${e.toString()}');
    } finally {
      isCreating.value = false;
    }
  }

  Future<void> updateMerchandiseItem(MerchandiseItem item) async {
    if (organization.value == null) return;

    try {
      await _firestore
          .collection('organizations')
          .doc(organization.value!.orgId)
          .collection('merchandise')
          .doc(item.itemId)
          .update(item.toJson());

      final index = items.indexWhere((i) => i.itemId == item.itemId);
      if (index != -1) {
        items[index] = item;
      }

      Get.snackbar('Success', 'Merchandise item updated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update merchandise item: ${e.toString()}');
    }
  }

  Future<void> deleteMerchandiseItem(String itemId) async {
    if (organization.value == null) return;

    try {
      await _firestore
          .collection('organizations')
          .doc(organization.value!.orgId)
          .collection('merchandise')
          .doc(itemId)
          .delete();

      items.removeWhere((item) => item.itemId == itemId);

      Get.snackbar('Success', 'Merchandise item deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete merchandise item: ${e.toString()}');
    }
  }

  Future<void> refreshItems() async {
    await loadMerchandiseItems(refresh: true);
  }
}
