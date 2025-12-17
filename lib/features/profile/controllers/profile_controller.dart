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
    final email = _authRepo.firebaseUser.value?.email;
    if (email != null) {
      try {
        final snapshot = await _db
            .collection('users')
            .where('email', isEqualTo: email)
            .get();
        if (snapshot.docs.isNotEmpty) {
          userProfile.value = UserProfileModel.fromSnapshot(
            snapshot.docs.single,
          );
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
  }

  Future<void> updateUserProfile(UserProfileModel user) async {
    try {
      isLoading.value = true;
      await _db.collection('users').doc(user.id).update(user.toJson());
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
