// import 'package:cloud_firestore/cloud_firestore.dart'; // DISABLED FOR DEVELOPMENT
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/event_model.dart';
// import '../../auth/controllers/auth_controller.dart';

class EventController extends GetxController {
  static EventController get instance => Get.find();

  // final _db = FirebaseFirestore.instance; // DISABLED FOR DEVELOPMENT
  final isLoading = false.obs;

  // Mock data for development (no Firebase needed)
  final RxList<EventModel> _mockEvents = <EventModel>[
    EventModel(
      id: '1',
      title: 'Flutter Workshop',
      description: 'Learn Flutter basics and build your first app',
      date: DateTime.now().add(const Duration(days: 5)),
      location: 'Tech Hub, Colombo',
      organizerId: 'user123',
    ),
    EventModel(
      id: '2',
      title: 'Mobile Dev Meetup',
      description: 'Connect with mobile developers in your area',
      date: DateTime.now().add(const Duration(days: 10)),
      location: 'Innovation Center, Kandy',
      organizerId: 'user456',
    ),
    EventModel(
      id: '3',
      title: 'Hackathon 2025',
      description: '48-hour coding challenge with amazing prizes',
      date: DateTime.now().add(const Duration(days: 15)),
      location: 'University of Moratuwa',
      organizerId: 'user789',
    ),
  ].obs;

  // Create Event (Mock - stores in memory)
  Future<void> createEvent(EventModel event) async {
    try {
      isLoading.value = true;
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
      event.id = DateTime.now().millisecondsSinceEpoch.toString();
      _mockEvents.add(event);
      isLoading.value = false;
      Get.snackbar(
        'Success',
        'Event added successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      Get.back();
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to add event',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  // Read Events (Stream) - Returns mock data
  Stream<List<EventModel>> getAllEvents() {
    return Stream.value(_mockEvents.toList());
  }

  // Get events as a list (for non-stream usage)
  List<EventModel> getEventsList() {
        return _mockEvents.toList();
  }

  // Update Event (Mock)
  Future<void> updateEvent(EventModel event) async {
    try {
      isLoading.value = true;
      await Future.delayed(const Duration(milliseconds: 500));
      final index = _mockEvents.indexWhere((e) => e.id == event.id);
      if (index != -1) {
        _mockEvents[index] = event;
      }
      isLoading.value = false;
      Get.snackbar('Success', 'Event updated successfully',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white);
      Get.back();
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to update event',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  // Delete Event (Mock)
  Future<void> deleteEvent(String id) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      _mockEvents.removeWhere((event) => event.id == id);
      Get.snackbar(
        'Success',
        'Event deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete event',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
}
