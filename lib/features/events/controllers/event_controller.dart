import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/event_model.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../core/db/user_local_db.dart';
import '../../../core/db/event_local_db.dart';

class EventController extends GetxController {
  static EventController get instance => Get.find();

  final _db = FirebaseFirestore.instance;
  final _authController = Get.find<AuthController>();
  final _localDb = EventLocalDb.instance;
  final isLoading = false.obs;
  String? _cachedUserName;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _firestoreSub;

  @override
  void onReady() {
    super.onReady();
    final uid = _authController.firebaseUser.value?.uid;
    if (uid != null) {
      _ensureLocalTable();
    }
    ever(_authController.firebaseUser, (user) {
      if (user != null) {
        _ensureLocalTable();
      }
    });
  }

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
      final now = DateTime.now();
      event.createdAt = now;
      event.updatedAt = now;
      final docRef = await _db.collection('events').add({
        ...event.toJson(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      event.id = docRef.id;
      await docRef.update({'id': docRef.id});
      await _localDb.upsertEvents([event]);
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
    _startRemoteSync(uid);
    return _localDb.watchEvents(userId: uid);
  }

  Future<List<EventModel>> getEventsList() async {
    final uid = _authController.firebaseUser.value?.uid;
    if (uid == null) return [];
    _startRemoteSync(uid);
    return _localDb.getEvents(userId: uid);
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
      event.updatedAt = DateTime.now();
      await _db.collection('events').doc(event.id).update({
        ...event.toJson(),
        'userId': event.userId,
        'userName': userName,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      await _localDb.upsertEvents([event]);
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
      await _localDb.deleteEvent(id);
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

  void _startRemoteSync(String uid) {
    if (_firestoreSub != null) return;
    _firestoreSub = _db
        .collection('events')
        .where('userId', isEqualTo: uid)
        .snapshots()
        .listen((snapshot) async {
      final events = snapshot.docs.map(EventModel.fromSnapshot).toList();
      await _localDb.replaceUserEvents(uid, events);
    });
  }

  Future<void> _ensureLocalTable() async {
    try {
      await _localDb.ensureTableExists();
    } catch (_) {
      // ignore failures; Firestore stream will surface issues if any
    }
  }

  @override
  void onClose() {
    _firestoreSub?.cancel();
    super.onClose();
  }
}
