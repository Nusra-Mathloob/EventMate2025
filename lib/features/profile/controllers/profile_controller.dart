import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/user_profile_model.dart';
import '../../auth/controllers/auth_controller.dart';

class ProfileController extends GetxController {
  static ProfileController get instance => Get.find();

  final _db = FirebaseFirestore.instance;
  final _authRepo = Get.find<AuthController>();
  final isLoading = false.obs;
  final userProfile = Rx<UserProfileModel?>(null);

  @override
  void onReady() {
    super.onReady();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    isLoading.value = true;
    final uid = _authRepo.firebaseUser.value?.uid;
    if (uid != null) {
      try {
        final snapshot = await _db.collection('users').doc(uid).get();
        if (snapshot.exists) {
          userProfile.value = UserProfileModel.fromSnapshot(snapshot);
        } else {
          userProfile.value = null;
        }
      } catch (e) {
        Get.snackbar(
          'Error',
          'Failed to fetch profile',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
    isLoading.value = false;
  }

  Future<void> updateUserProfile(UserProfileModel user) async {
    try {
      isLoading.value = true;
      final docId = user.id ?? _authRepo.firebaseUser.value?.uid;
      if (docId == null) {
        throw Exception('User ID missing');
      }
      await _db.collection('users').doc(docId).update(user.toJson());
      userProfile.value = user; // Update local state
      isLoading.value = false;
      Get.snackbar(
        'Success',
        'Profile updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      Get.back();
      Get.offNamed('/profile');
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        'Error',
        'Failed to update profile',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
