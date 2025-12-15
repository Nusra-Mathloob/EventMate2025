import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../../auth/controllers/auth_controller.dart';

class EventController extends GetxController {
  static EventController get instance => Get.find();

  final _db = FirebaseFirestore.instance;
  final isLoading = false.obs;

  // Create Event
  Future<void> createEvent(EventModel event) async {
    try {
      isLoading.value = true;
      await _db.collection('events').add(event.toJson());
      isLoading.value = false;
      Get.snackbar('Success', 'Event added successfully',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white);
      Get.back(); // Go back to previous screen
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to add event',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  // Read Events (Stream)
  Stream<List<EventModel>> getAllEvents() {
    return _db.collection('events').orderBy('date', descending: false).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => EventModel.fromSnapshot(doc)).toList();
    });
  }

  // Update Event
  Future<void> updateEvent(EventModel event) async {
    try {
      isLoading.value = true;
      await _db.collection('events').doc(event.id).update(event.toJson());
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

  // Delete Event
  Future<void> deleteEvent(String id) async {
    try {
      await _db.collection('events').doc(id).delete();
      Get.snackbar('Success', 'Event deleted successfully',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete event',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
}
