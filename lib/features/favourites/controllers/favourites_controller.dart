import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/favourite_event_model.dart';
import '../../../core/db/favourites_local_db.dart';
import '../../auth/controllers/auth_controller.dart';

class FavouritesController extends GetxController {
  static FavouritesController get instance => Get.find();

  final _db = FirebaseFirestore.instance;
  final _authController = Get.find<AuthController>();
  final _localDb = FavouritesLocalDb.instance;
  final RxList<FavouriteEventModel> _favourites = <FavouriteEventModel>[].obs;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _firestoreSub;

  RxList<FavouriteEventModel> get favourites => _favourites;

  @override
  void onInit() {
    super.onInit();
    _loadFromStorage();
    final uid = _authController.firebaseUser.value?.uid;
    if (uid != null) {
      _startRemoteSync(uid);
    }
    ever<User?>(_authController.firebaseUser, _handleUserChange);
  }

  Future<void> _loadFromStorage() async {
    try {
      final saved = await _localDb.getFavourites();
      _favourites.assignAll(saved);
    } catch (_) {
      // Ignore load failures; UI can still operate in memory.
    }
  }

  void _handleUserChange(User? user) {
    if (user == null) {
      _stopRemoteSync();
      _favourites.clear();
      return;
    }
    _startRemoteSync(user.uid);
  }

  bool isFavourite(String eventId) {
    return _favourites.any((event) => event.id == eventId);
  }

  Future<void> addToFavourites(FavouriteEventModel event) async {
    final uid = _authController.firebaseUser.value?.uid;
    if (uid == null) {
      Get.snackbar(
        'Login required',
        'Please log in to save favourites',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (event.id.isEmpty) {
      Get.snackbar(
        'Error',
        'Event is missing an identifier',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (!isFavourite(event.id)) {
      _favourites.add(event);
      try {
        await _localDb.upsertFavourite(event);
        await _uploadFavourite(uid, event);
        Get.snackbar(
          'Added to Favourites',
          '${event.title} has been added to your favourites',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } catch (_) {
        _favourites.removeWhere((item) => item.id == event.id);
        await _localDb.deleteFavourite(event.id);
        Get.snackbar(
          'Error',
          'Could not save favourite',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  // Remove event from favourites
  Future<void> removeFromFavourites(String eventId) async {
    final uid = _authController.firebaseUser.value?.uid;
    final index = _favourites.indexWhere((e) => e.id == eventId);
    if (index == -1) return;
    final event = _favourites[index];
    _favourites.removeAt(index);
    try {
      await _deleteFavouriteRemote(uid, eventId);
      await _localDb.deleteFavourite(eventId);
      Get.snackbar(
        'Removed from Favourites',
        '${event.title} has been removed from your favourites',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (_) {
      _favourites.insert(index, event);
      Get.snackbar(
        'Error',
        'Could not remove favourite',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> toggleFavourite(FavouriteEventModel event) async =>
      isFavourite(event.id)
          ? removeFromFavourites(event.id)
          : addToFavourites(event);

  int get favouritesCount => _favourites.length;

  Future<void> clearAllFavourites() async {
    final uid = _authController.firebaseUser.value?.uid;
    final backup = List<FavouriteEventModel>.from(_favourites);
    _favourites.clear();
    try {
      await _clearRemote(uid);
      await _localDb.clearAll();
      Get.snackbar(
        'Cleared',
        'All favourites have been removed',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.grey,
        colorText: Colors.white,
      );
    } catch (_) {
      _favourites.assignAll(backup);
      Get.snackbar(
        'Error',
        'Could not clear favourites locally',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _uploadFavourite(String uid, FavouriteEventModel event) {
    return _db.collection('favourites').doc(_docId(uid, event.id)).set({
      ...event.toJson(),
      'userId': uid,
    });
  }

  Future<void> _deleteFavouriteRemote(String? uid, String eventId) async {
    if (uid == null) return;
    await _db.collection('favourites').doc(_docId(uid, eventId)).delete();
  }

  Future<void> _clearRemote(String? uid) async {
    if (uid == null) return;
    final snapshot = await _db
        .collection('favourites')
        .where('userId', isEqualTo: uid)
        .get();
    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  Future<void> _startRemoteSync(String uid) async {
    _stopRemoteSync();
    await _seedRemoteFromLocal(uid);
    _firestoreSub = _db
        .collection('favourites')
        .where('userId', isEqualTo: uid)
        .snapshots()
        .listen((snapshot) async {
      final remote = snapshot.docs.map((doc) {
        final data = doc.data();
        final map = {
          ...data,
          'id': data['id'] ?? '',
        };
        return FavouriteEventModel.fromJson(map);
      }).toList()
        ..sort((a, b) => a.date.compareTo(b.date));

      _favourites.assignAll(remote);
      await _localDb.replaceAll(remote);
    });
  }

  void _stopRemoteSync() {
    _firestoreSub?.cancel();
    _firestoreSub = null;
  }

  String _docId(String uid, String eventId) => '${uid}_$eventId';

  Future<void> _seedRemoteFromLocal(String uid) async {
    if (_favourites.isEmpty) return;
    final existing = await _db
        .collection('favourites')
        .where('userId', isEqualTo: uid)
        .limit(1)
        .get();
    if (existing.docs.isNotEmpty) return;
    for (final fav in _favourites) {
      await _uploadFavourite(uid, fav);
    }
  }

  @override
  void onClose() {
    _stopRemoteSync();
    super.onClose();
  }
}
