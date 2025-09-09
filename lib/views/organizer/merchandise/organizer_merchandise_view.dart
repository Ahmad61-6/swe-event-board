import 'dart:io';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../controllers/organizer/organizer_merchandise_controller.dart';

class OrganizerMerchandiseView extends StatelessWidget {
  final OrganizerMerchandiseController controller = Get.put(
    OrganizerMerchandiseController(),
  );

  OrganizerMerchandiseView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Merchandise'),
        actions: [
          IconButton(
            onPressed: controller.refreshItems,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showMerchandiseDialog(),
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshItems,
        child: Obx(() {
          if (controller.isLoading.value && controller.items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No merchandise items yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _showMerchandiseDialog(),
                    child: const Text('Add Your First Item'),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: DataTable2(
              columnSpacing: 12,
              horizontalMargin: 12,
              minWidth: 800,
              headingRowColor: MaterialStateColor.resolveWith(
                (states) => Theme.of(context).primaryColor.withOpacity(0.1),
              ),
              columns: const [
                DataColumn2(label: Text('Item'), size: ColumnSize.L),
                DataColumn2(label: Text('Price')),
                DataColumn2(label: Text('Stock')),
                DataColumn2(label: Text('Sold')),
                DataColumn2(label: Text('Actions')),
              ],
              rows: controller.items.map((item) {
                return DataRow2(
                  cells: [
                    DataCell(
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: item.photoUrl.isNotEmpty
                                  ? DecorationImage(
                                      image: NetworkImage(item.photoUrl),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                              color: Colors.grey[300],
                            ),
                            child: item.photoUrl.isEmpty
                                ? const Icon(Icons.image, size: 20)
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              item.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    DataCell(
                      Text('₹${NumberFormat('#,##0.00').format(item.price)}'),
                    ),
                    DataCell(Text('${item.stock}')),
                    DataCell(Text('${item.soldCount}')),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () {
                              // TODO: View orders
                            },
                            icon: const Icon(Icons.list, size: 20),
                            tooltip: 'View Orders',
                          ),
                          IconButton(
                            onPressed: () => _showMerchandiseDialog(item: item),
                            icon: const Icon(Icons.edit, size: 20),
                            tooltip: 'Edit',
                          ),
                          IconButton(
                            onPressed: () => _showDeleteDialog(item),
                            icon: const Icon(Icons.delete, size: 20),
                            tooltip: 'Delete',
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          );
        }),
      ),
    );
  }

  void _showDeleteDialog(MerchandiseItem item) {
    Get.defaultDialog(
      title: 'Delete Merchandise',
      middleText:
          'Are you sure you want to delete "${item.title}"? This action cannot be undone.',
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
        TextButton(
          onPressed: () {
            Get.back();
            controller.deleteMerchandiseItem(item.itemId);
          },
          child: const Text('Delete'),
        ),
      ],
    );
  }

  void _showMerchandiseDialog({MerchandiseItem? item}) {
    final _formKey = GlobalKey<FormState>();
    final _titleController = TextEditingController(text: item?.title);
    final _descriptionController = TextEditingController(text: item?.description);
    final _priceController = TextEditingController(text: item?.price.toString());
    final _stockController = TextEditingController(text: item?.stock.toString());
    Rx<File?> _imageFile = Rx<File?>(null);
    Rx<String?> _imageUrl = Rx<String?>(item?.photoUrl);

    Get.dialog(
      AlertDialog(
        title: Text(item == null ? 'Create Item' : 'Edit Item'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Obx(() {
                  return GestureDetector(
                    onTap: () async {
                      final picker = ImagePicker();
                      final pickedFile =
                          await picker.pickImage(source: ImageSource.gallery);
                      if (pickedFile != null) {
                        _imageFile.value = File(pickedFile.path);
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                        image: _imageFile.value != null
                            ? DecorationImage(
                                image: FileImage(_imageFile.value!),
                                fit: BoxFit.cover,
                              )
                            : _imageUrl.value != null && _imageUrl.value!.isNotEmpty
                                ? DecorationImage(
                                    image: NetworkImage(_imageUrl.value!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                      ),
                      child: _imageFile.value == null && (_imageUrl.value == null || _imageUrl.value!.isEmpty)
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.camera_alt, color: Colors.grey),
                                  Text('Tap to select image'),
                                ],
                              ),
                            )
                          : null,
                    ),
                  );
                }),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter a title' : null,
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                ),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(labelText: 'Price', prefixText: '₹'),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter a price' : null,
                ),
                TextFormField(
                  controller: _stockController,
                  decoration: const InputDecoration(labelText: 'Stock'),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter the stock quantity' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                String? finalImageUrl = _imageUrl.value;
                if (_imageFile.value != null) {
                  finalImageUrl = await controller.uploadItemImage(_imageFile.value!);
                }

                if (finalImageUrl == null) {
                  Get.snackbar('Error', 'Image upload failed. Please try again.');
                  return;
                }

                final newItem = MerchandiseItem(
                  itemId: item?.itemId ?? '',
                  title: _titleController.text,
                  description: _descriptionController.text,
                  photoUrl: finalImageUrl,
                  price: double.parse(_priceController.text),
                  currency: item?.currency ?? 'INR',
                  stock: int.parse(_stockController.text),
                  soldCount: item?.soldCount ?? 0,
                  createdAt: item?.createdAt ?? DateTime.now(),
                );

                if (item == null) {
                  await controller.createMerchandiseItem(newItem);
                } else {
                  await controller.updateMerchandiseItem(newItem);
                }
                Get.back();
              }
            },
            child: Text(item == null ? 'Create' : 'Save'),
          ),
        ],
      ),
    );
  }
}