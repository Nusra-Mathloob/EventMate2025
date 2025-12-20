import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/favourite_event_model.dart';
import '../../../core/db/favourites_local_db.dart';

class FavouritesController extends GetxController {
  static FavouritesController get instance => Get.find();

  final _localDb = FavouritesLocalDb.instance;
  final RxList<FavouriteEventModel> _favourites = <FavouriteEventModel>[].obs;

  RxList<FavouriteEventModel> get favourites => _favourites;

  @override
  void onInit() {
    super.onInit();
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    try {
      final saved = await _localDb.getFavourites();
      _favourites.assignAll(saved);
    } catch (_) {
      // Ignore load failures; UI can still operate in memory.
    }
  }

  bool isFavourite(String eventId) {
    return _favourites.any((event) => event.id == eventId);
  }

  Future<void> addToFavourites(FavouriteEventModel event) async {
    if (!isFavourite(event.id)) {
      _favourites.add(event);
      try {
        await _localDb.upsertFavourite(event);
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
        Get.snackbar(
          'Error',
          'Could not save favourite locally',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  // Remove event from favourites
  Future<void> removeFromFavourites(String eventId) async {
    final index = _favourites.indexWhere((e) => e.id == eventId);
    if (index == -1) return;
    final event = _favourites[index];
    _favourites.removeAt(index);
    try {
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
        'Could not remove favourite locally',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> toggleFavourite(FavouriteEventModel event) async {
    if (isFavourite(event.id)) {
      await removeFromFavourites(event.id);
    } else {
      await addToFavourites(event);
    }
  }

  int get favouritesCount => _favourites.length;

  Future<void> clearAllFavourites() async {
    final backup = List<FavouriteEventModel>.from(_favourites);
    _favourites.clear();
    try {
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
}
