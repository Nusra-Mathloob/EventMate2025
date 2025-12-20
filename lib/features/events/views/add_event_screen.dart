import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/widgets/custom_button.dart';
import '../controllers/event_controller.dart';
import '../models/event_model.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../favourites/controllers/favourites_controller.dart';
import 'my_events_screen.dart';

class AddEventScreen extends StatefulWidget {
  final EventModel? event; // If provided, we are in edit mode

  const AddEventScreen({Key? key, this.event}) : super(key: key);

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final controller = Get.find<EventController>();
  final authController = Get.find<AuthController>();
  final favController = Get.find<FavouritesController>();
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
              
              // Date Selection Trigger
              InkWell(
                onTap: () async {
                  final now = DateTime.now();
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate ?? now,
                    firstDate: DateTime(now.year - 1),
                    lastDate: DateTime(now.year + 5),
                  );
                  if (picked != null) {
                    setState(() {
                      selectedDate = DateTime(
                        picked.year,
                        picked.month,
                        picked.day,
                      );
                    });
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                    suffixIcon: Icon(Icons.date_range),
                  ),
                  child: Text(
                    selectedDate != null 
                        ? DateFormat.yMMMd().format(selectedDate!) 
                        : 'Select Date',
                    style: TextStyle(
                      color: selectedDate != null ? Theme.of(context).textTheme.bodyLarge?.color : Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Obx(() => CustomButton(
                    text: isEditing ? 'UPDATE EVENT' : 'CREATE EVENT',
                    isLoading: controller.isLoading.value,
                    onPressed: () async {
                      if (_formKey.currentState!.validate() && selectedDate != null) {
                        final event = EventModel(
                          id: widget.event?.id,
                          title: titleController.text.trim(),
                          description: descriptionController.text.trim(),
                          date: selectedDate!,
                          location: locationController.text.trim(),
                          userId: authController.firebaseUser.value?.uid ?? 'unknown',
                          userName: widget.event?.userName ?? '',
                        );

                        if (isEditing) {
                          final updated = await controller.updateEvent(event);
                          if (updated && mounted) {
                            // Ensure stack is Home -> My Events after update
                            Get.until((route) => route.settings.name == '/home');
                            Get.to(() => const EventListScreen());
                          }
                        } else {
                          final createdEvent = await controller.createEvent(event);
                          if (createdEvent != null && mounted) {
                            // Ensure stack is Home -> My Events after creation
                            Get.until((route) => route.settings.name == '/home');
                            Get.to(() => const EventListScreen());
                          }
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
  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
