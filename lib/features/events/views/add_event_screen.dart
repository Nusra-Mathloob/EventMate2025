import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/widgets/custom_button.dart';
import '../controllers/event_controller.dart';
import '../models/event_model.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../favourites/controllers/favourites_controller.dart';
import 'my_events_screen.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';

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
  bool _isCalendarExpanded = false;

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
                onTap: () {
                  setState(() {
                    _isCalendarExpanded = !_isCalendarExpanded;
                  });
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                    suffixIcon: Icon(Icons.arrow_drop_down),
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
              
              const SizedBox(height: 16),
              StreamBuilder<List<EventModel>>(
                stream: controller.getAllEvents(),
                builder: (context, snapshot) {
                  return Obx(() {
                    final firestoreEvents = snapshot.data ?? [];
                    final favEvents = favController.favourites;
                    
                    // Combine dates for markers
                    final eventDates = <DateTime>{};
                    for (var e in firestoreEvents) {
                      eventDates.add(DateTime(e.date.year, e.date.month, e.date.day));
                    }
                    for (var e in favEvents) {
                      eventDates.add(DateTime(e.date.year, e.date.month, e.date.day));
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_isCalendarExpanded)
                        Container(
                          margin: const EdgeInsets.only(bottom: 24),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.withOpacity(0.5)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: CalendarDatePicker2(
                            config: CalendarDatePicker2Config(
                              calendarType: CalendarDatePicker2Type.single,
                              selectedDayHighlightColor: Theme.of(context).primaryColor,
                              dayBuilder: ({required date, textStyle, decoration, isSelected, isDisabled, isToday}) {
                                final isEventDay = eventDates.contains(DateTime(date.year, date.month, date.day));
                                
                                return Container(
                                  decoration: decoration,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Text(
                                        date.day.toString(),
                                        style: textStyle,
                                      ),
                                      if (isEventDay && isSelected != true) 
                                        Positioned(
                                          bottom: 4,
                                          child: Container(
                                            width: 5,
                                            height: 5,
                                            decoration: BoxDecoration(
                                              color: Colors.redAccent,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            value: [selectedDate ?? DateTime.now()],
                            onValueChanged: (dates) {
                              if (dates.isNotEmpty) {
                                setState(() {
                                  selectedDate = dates.first;
                                  // Keep calendar expanded
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (selectedDate != null) ...[
                          Text(
                            'Events on ${DateFormat.yMMMd().format(selectedDate!)}:',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          // Firestore Events
                          ...firestoreEvents.where((e) => isSameDay(e.date, selectedDate!)).map((event) => Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: Container(
                                width: 4,
                                color: Theme.of(context).primaryColor,
                              ),
                              title: Text(event.title),
                              subtitle: Text(event.location),
                              dense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            ),
                          )),
                          // Favourites Events (Ticketmaster & Community)
                          ...favEvents.where((e) {
                            final matchesDate = isSameDay(e.date, selectedDate!);
                            // Deduplicate: Don't show if already shown in main list
                            final isDuplicate = firestoreEvents.any((fe) => fe.id == e.id);
                            return matchesDate && !isDuplicate;
                          }).map((event) {
                            final isTM = event.isTicketmasterEvent;
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: Container(
                                  width: 4,
                                  color: isTM ? Colors.orange : Colors.deepPurple,
                                ),
                                title: Text(event.title),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(event.location),
                                    const SizedBox(height: 2),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: (isTM ? Colors.orange : Colors.deepPurple).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        isTM ? 'Ticketmaster' : 'Community Favourite',
                                        style: TextStyle(
                                          color: isTM ? Colors.orange[800] : Colors.deepPurple[800],
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                dense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              ),
                            );
                          }),
                          if (firestoreEvents.where((e) => isSameDay(e.date, selectedDate!)).isEmpty && 
                              favEvents.where((e) => isSameDay(e.date, selectedDate!) && !firestoreEvents.any((fe) => fe.id == e.id)).isEmpty)
                             Padding(
                               padding: const EdgeInsets.all(8.0),
                               child: Text('No events scheduled for this day.', style: TextStyle(color: Colors.grey)),
                             ),
                        ],
                      ],
                    );
                  });
                }
              ),
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
