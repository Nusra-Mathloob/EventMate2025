import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/event_model.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../core/db/user_local_db.dart';

class EventController extends GetxController {
  static EventController get instance => Get.find();

  final _db = FirebaseFirestore.instance;
  final _authController = Get.find<AuthController>();
  final isLoading = false.obs;
  String? _cachedUserName;

  Future<EventModel?> createEvent(EventModel event) async {
    try {
      isLoading.value = true;
      final uid = _authController.firebaseUser.value?.uid;
      if (uid == null) {
        Get.snackbar('Error', 'User not logged in',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
        return null;
      }
      final userName = await _getCurrentUserName(uid);
      event.userId = uid;
      event.userName = userName;
      final docRef = await _db.collection('events').add({
        ...event.toJson(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      event.id = docRef.id;
      await docRef.update({'id': docRef.id});
      Get.snackbar('Success', 'Event added successfully',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white);
      return event;
    } catch (_) {
      Get.snackbar('Error', 'Failed to add event',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Stream<List<EventModel>> getAllEvents() {
    final uid = _authController.firebaseUser.value?.uid;
    if (uid == null) {
      return Stream.value([]);
    }
    return _db
        .collection('events')
        .where('userId', isEqualTo: uid)
        .snapshots()
        .map((snapshot) {
      final events = snapshot.docs.map(EventModel.fromSnapshot).toList();
      events.sort((a, b) => a.date.compareTo(b.date));
      return events;
    });
  }

  Future<List<EventModel>> getEventsList() async {
    final uid = _authController.firebaseUser.value?.uid;
    if (uid == null) return [];
    final snapshot = await _db.collection('events').where('userId', isEqualTo: uid).get();
    final events = snapshot.docs.map(EventModel.fromSnapshot).toList();
    events.sort((a, b) => a.date.compareTo(b.date));
    return events;
  }

  Future<bool> updateEvent(EventModel event) async {
    if (event.id == null) {
      Get.snackbar('Error', 'Event ID is missing',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }

    try {
      isLoading.value = true;
      final userName = event.userName.isNotEmpty
          ? event.userName
          : await _getCurrentUserName(event.userId);
      event.userName = userName;
      await _db.collection('events').doc(event.id).update({
        ...event.toJson(),
        'userId': event.userId,
        'userName': userName,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      Get.snackbar('Success', 'Event updated successfully',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white);
      return true;
    } catch (_) {
      Get.snackbar('Error', 'Failed to update event',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteEvent(String id) async {
    try {
      await _db.collection('events').doc(id).delete();
      Get.snackbar(
        'Success',
        'Event deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (_) {
      Get.snackbar('Error', 'Failed to delete event',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<String> _getCurrentUserName(String uid) async {
    if (_cachedUserName != null && _cachedUserName!.isNotEmpty) {
      return _cachedUserName!;
    }

    try {
      final cachedUser = await UserLocalDb.instance.getUser();
      final cachedName = cachedUser?.fullName.trim();
      if (cachedName != null && cachedName.isNotEmpty) {
        _cachedUserName = cachedName;
        return cachedName;
      }

      final displayName = _authController.firebaseUser.value?.displayName?.trim();
      if (displayName != null && displayName.isNotEmpty) {
        _cachedUserName = displayName;
        return displayName;
      }

      final doc = await _db.collection('users').doc(uid).get();
      final remoteName = doc.data()?['fullName']?.toString().trim();
      if (remoteName != null && remoteName.isNotEmpty) {
        _cachedUserName = remoteName;
        return remoteName;
      }
    } catch (_) {
      // Ignore and fall through to fallback
    }
    _cachedUserName = '';
    return '';
  }
}
