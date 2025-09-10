import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../constants/app_constants.dart';
import '../../../controllers/organizer/organizer_events_controller.dart';
import '../../../data/model/event.dart';

class CreateEventView extends StatefulWidget {
  final Event? event;

  const CreateEventView({super.key, this.event});

  @override
  State<CreateEventView> createState() => _CreateEventViewState();
}

class _CreateEventViewState extends State<CreateEventView> {
  final OrganizerEventsController controller = Get.find();

  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _typeController = TextEditingController();
  final _venueController = TextEditingController();
  final _meetLinkController = TextEditingController();
  final _priceController = TextEditingController();
  final _capacityController = TextEditingController();

  DateTime _startDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _startTime = const TimeOfDay(hour: 10, minute: 0);
  DateTime _endDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _endTime = const TimeOfDay(hour: 12, minute: 0);

  File? _bannerImage;
  String? _bannerImageUrl;

  bool get isEditMode => widget.event != null;

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      final event = widget.event!;
      _titleController.text = event.title;
      _descriptionController.text = event.description;
      _typeController.text = event.type;
      _venueController.text = event.venue;
      _meetLinkController.text = event.meetLink;
      _priceController.text = event.price.toString();
      _capacityController.text = event.capacity.toString();
      _startDate = event.startAt;
      _startTime = TimeOfDay.fromDateTime(event.startAt);
      _endDate = event.endAt;
      _endTime = TimeOfDay.fromDateTime(event.endAt);
      _bannerImageUrl = event.bannerUrl;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _typeController.dispose();
    _venueController.dispose();
    _meetLinkController.dispose();
    _priceController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEditMode ? 'Edit Event' : 'Create Event')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Event Banner',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildBannerPicker(),
              const SizedBox(height: 24),
              const Text(
                'Event Details',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              // Fields...
              _buildTextFormField(
                controller: _titleController,
                label: 'Event Title',
                validator: (value) => (value == null || value.isEmpty) ? 'Please enter event title' : null,
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _descriptionController,
                label: 'Description',
                maxLines: 4,
                validator: (value) => (value == null || value.isEmpty) ? 'Please enter event description' : null,
              ),
              const SizedBox(height: 16),
              _buildDropdownFormField(
                controller: _typeController,
                label: 'Event Type',
                items: AppConstants.eventTypes,
                validator: (value) => (value == null || value.isEmpty) ? 'Please select event type' : null,
              ),
              const SizedBox(height: 16),
              _buildDateTimePicker(
                label: 'Start Date & Time',
                date: _startDate,
                time: _startTime,
                onDateTap: () => _pickDate(context, isStart: true),
                onTimeTap: () => _pickTime(context, isStart: true),
              ),
              const SizedBox(height: 16),
              _buildDateTimePicker(
                label: 'End Date & Time',
                date: _endDate,
                time: _endTime,
                onDateTap: () => _pickDate(context, isStart: false),
                onTimeTap: () => _pickTime(context, isStart: false),
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _venueController,
                label: 'Venue',
                validator: (value) => (value == null || value.isEmpty) ? 'Please enter venue' : null,
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _meetLinkController,
                label: 'Online Meeting Link (Optional)',
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _priceController,
                label: 'Price (₹)',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter price';
                  if (double.tryParse(value) == null) return 'Please enter a valid number';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _capacityController,
                label: 'Capacity',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter capacity';
                  if (int.tryParse(value) == null) return 'Please enter a valid number';
                  return null;
                },
              ),
              const SizedBox(height: 32),
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: controller.isCreating.value || controller.isUpdating.value ? null : _handleSaveEvent,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: controller.isCreating.value || controller.isUpdating.value
                        ? const CircularProgressIndicator()
                        : Text(isEditMode ? 'Update Event' : 'Create Event', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBannerPicker() {
    return GestureDetector(
      onTap: () async {
        final picker = ImagePicker();
        final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
        if (pickedFile != null) {
          setState(() {
            _bannerImage = File(pickedFile.path);
            _bannerImageUrl = null; // Clear the network image if a new file is picked
          });
        }
      },
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade400),
          image: _bannerImage != null
              ? DecorationImage(image: FileImage(_bannerImage!), fit: BoxFit.cover)
              : _bannerImageUrl != null
                  ? DecorationImage(image: NetworkImage(_bannerImageUrl!), fit: BoxFit.cover)
                  : null,
        ),
        child: _bannerImage == null && _bannerImageUrl == null
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo, color: Colors.grey, size: 40),
                    SizedBox(height: 8),
                    Text('Tap to upload a banner', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
    );
  }

  Widget _buildDropdownFormField({
    required TextEditingController controller,
    required String label,
    required List<String> items,
    String? Function(String?)? validator,
  }) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      value: controller.text.isEmpty ? null : controller.text,
      items: items.map((String value) {
        return DropdownMenuItem<String>(value: value, child: Text(value));
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          controller.text = value;
        }
      },
      validator: validator,
    );
  }

  Widget _buildDateTimePicker({
    required String label,
    required DateTime date,
    required TimeOfDay time,
    required VoidCallback onDateTap,
    required VoidCallback onTimeTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Card(
                child: InkWell(
                  onTap: onDateTap,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today),
                        const SizedBox(width: 8),
                        Text(DateFormat('MMM dd, yyyy').format(date)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Card(
                child: InkWell(
                  onTap: onTimeTap,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time),
                        const SizedBox(width: 8),
                        Text(time.format(context)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _pickDate(BuildContext context, {required bool isStart}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _pickTime(BuildContext context, {required bool isStart}) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  void _handleSaveEvent() async {
    if (!_formKey.currentState!.validate()) return;

    if (_bannerImage == null && _bannerImageUrl == null) {
      Get.snackbar('Error', 'Please select a banner image for the event.');
      return;
    }

    final startDateTime = DateTime(_startDate.year, _startDate.month, _startDate.day, _startTime.hour, _startTime.minute);
    final endDateTime = DateTime(_endDate.year, _endDate.month, _endDate.day, _endTime.hour, _endTime.minute);

    if (endDateTime.isBefore(startDateTime)) {
      Get.snackbar('Error', 'End time must be after start time');
      return;
    }

    String? bannerUrl = _bannerImageUrl;
    if (_bannerImage != null) {
      bannerUrl = await controller.uploadBannerImage(_bannerImage!);
      if (bannerUrl == null) {
        Get.snackbar('Error', 'Failed to upload banner image.');
        return;
      }
    }

    final event = Event(
      eventId: isEditMode ? widget.event!.eventId : '', // Generated by controller for new events
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      type: _typeController.text,
      bannerUrl: bannerUrl!,
      startAt: startDateTime,
      endAt: endDateTime,
      venue: _venueController.text.trim(),
      meetLink: _meetLinkController.text.trim(),
      price: double.tryParse(_priceController.text) ?? 0,
      capacity: int.tryParse(_capacityController.text) ?? 0,
      createdByUid: isEditMode ? widget.event!.createdByUid : '', // Set by controller for new events
      approved: isEditMode ? widget.event!.approved : false,
      enrolledCount: isEditMode ? widget.event!.enrolledCount : 0,
      conflict: isEditMode ? widget.event!.conflict : false,
      createdAt: isEditMode ? widget.event!.createdAt : DateTime.now(),
    );

    if (isEditMode) {
      await controller.updateEvent(event);
    } else {
      await controller.createEvent(event);
    }

    if (!controller.isCreating.value && !controller.isUpdating.value) {
      Get.back();
    }
  }
}