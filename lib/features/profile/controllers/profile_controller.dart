import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/user_profile_model.dart';
// import '../../auth/controllers/auth_controller.dart'; // DISABLED FOR DEVELOPMENT

class ProfileController extends GetxController {
  static ProfileController get instance => Get.find();

  // final _db = FirebaseFirestore.instance; // DISABLED FOR DEVELOPMENT
  // final _authRepo = Get.find<AuthController>(); // DISABLED FOR DEVELOPMENT
  final isLoading = false.obs;
  final userProfile = Rx<UserProfileModel?>(null);

  @override
  void onReady() {
    super.onReady();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    // Firebase DISABLED - using mock data for development
    // final email = _authRepo.firebaseUser.value?.email;
    // Simulate loading mock profile data
    try {
      // Mock user profile for development
      userProfile.value = UserProfileModel(
        id: 'mock_user_123',
        email: 'user@example.com',
        fullName: 'John Doe',
        phoneNo: '+1234567890',
        profileImage: null,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch profile',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
    }
    
    /* FIREBASE CODE - COMMENTED FOR DEVELOPMENT
    if (email != null) {
      try {
        final snapshot = await _db.collection('users').where('email', isEqualTo: email).get();
        if (snapshot.docs.isNotEmpty) {
          userProfile.value = UserProfileModel.fromSnapshot(snapshot.docs.single);
        }
      } catch (e) {
        Get.snackbar('Error', 'Failed to fetch profile',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      }
    }
    */
  }

  Future<void> updateUserProfile(UserProfileModel user) async {
    // Firebase DISABLED - using mock update for development
    try {
      isLoading.value = true;
      // Simulate update delay
      await Future.delayed(const Duration(milliseconds: 500));
      userProfile.value = user; // Update local state
      isLoading.value = false;
      Get.snackbar('Success', 'Profile updated successfully',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to update profile',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
    }
    
    /* FIREBASE CODE - COMMENTED FOR DEVELOPMENT
    try {
      isLoading.value = true;
      await _db.collection('users').doc(user.id).update(user.toJson());
      userProfile.value = user; // Update local state
      isLoading.value = false;
      Get.snackbar('Success', 'Profile updated successfully',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to update profile',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
    }
    */
  }
}
