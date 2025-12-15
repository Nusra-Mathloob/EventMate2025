import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../controllers/event_controller.dart';
import '../models/event_model.dart';
import '../../auth/controllers/auth_controller.dart';

class AddEventScreen extends StatefulWidget {
  final EventModel? event; // If provided, we are in edit mode

  const AddEventScreen({Key? key, this.event}) : super(key: key);

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final controller = Get.find<EventController>();
  final authController = Get.find<AuthController>();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController locationController;
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.event?.title ?? '');
    descriptionController = TextEditingController(text: widget.event?.description ?? '');
    locationController = TextEditingController(text: widget.event?.location ?? '');
    selectedDate = widget.event?.date;
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.event != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Event' : 'Add Event'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Event Title',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Please enter a description' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Please enter a location' : null,
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(selectedDate == null ? 'Select Date' : DateFormat.yMMMd().format(selectedDate!)),
                leading: const Icon(Icons.calendar_today),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: selectedDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) {
                    setState(() {
                      selectedDate = date;
                    });
                  }
                },
              ),
              const SizedBox(height: 24),
              Obx(() => CustomButton(
                    text: isEditing ? 'UPDATE EVENT' : 'CREATE EVENT',
                    isLoading: controller.isLoading.value,
                    onPressed: () {
                      if (_formKey.currentState!.validate() && selectedDate != null) {
                        final event = EventModel(
                          id: widget.event?.id,
                          title: titleController.text.trim(),
                          description: descriptionController.text.trim(),
                          date: selectedDate!,
                          location: locationController.text.trim(),
                          organizerId: authController.firebaseUser.value?.uid ?? 'unknown',
                        );

                        if (isEditing) {
                          controller.updateEvent(event);
                        } else {
                          controller.createEvent(event);
                        }
                      } else if (selectedDate == null) {
                        Get.snackbar('Error', 'Please select a date',
                            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
                      }
                    },
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
