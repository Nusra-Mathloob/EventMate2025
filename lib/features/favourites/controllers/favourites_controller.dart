import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/favourite_event_model.dart';

class FavouritesController extends GetxController {
  static FavouritesController get instance => Get.find();

  final RxList<FavouriteEventModel> _favourites = <FavouriteEventModel>[].obs;

  RxList<FavouriteEventModel> get favourites => _favourites;

  bool isFavourite(String eventId) {
    return _favourites.any((event) => event.id == eventId);
  }

  void addToFavourites(FavouriteEventModel event) {
    if (!isFavourite(event.id)) {
      _favourites.add(event);
      Get.snackbar(
        'Added to Favourites',
        '${event.title} has been added to your favourites',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    }
  }

  // Remove event from favourites
  void removeFromFavourites(String eventId) {
    final event = _favourites.firstWhere((e) => e.id == eventId);
    _favourites.removeWhere((event) => event.id == eventId);
    Get.snackbar(
      'Removed from Favourites',
      '${event.title} has been removed from your favourites',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  void toggleFavourite(FavouriteEventModel event) {
    if (isFavourite(event.id)) {
      removeFromFavourites(event.id);
    } else {
      addToFavourites(event);
    }
  }

  int get favouritesCount => _favourites.length;

  void clearAllFavourites() {
    _favourites.clear();
    Get.snackbar(
      'Cleared',
      'All favourites have been removed',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.grey,
      colorText: Colors.white,
    );
  }
}
