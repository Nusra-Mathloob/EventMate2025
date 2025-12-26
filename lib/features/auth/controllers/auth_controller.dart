import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../profile/models/user_profile_model.dart';
import '../../../core/db/user_local_db.dart';

class AuthController extends GetxController {
  static AuthController get instance => Get.find();

  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;
  final Rx<User?> firebaseUser = Rx<User?>(null);

  // 1. Reactive variable (Observable)
  var isLoading = false.obs;

  @override
  void onReady() {
    firebaseUser.value = _auth.currentUser;
    firebaseUser.bindStream(_auth.userChanges());
    ever<User?>(firebaseUser, _setInitialScreen);
    _setInitialScreen(firebaseUser.value);
    super.onReady();
  }

  void checkAuthState() => _setInitialScreen(firebaseUser.value);

  void _setInitialScreen(User? user) {
    if (user == null) {
      Get.offAllNamed('/login');
    } else {
      Get.offAllNamed('/home');
    }
  }

  Future<void> register(
    String fullName,
    String email,
    String phoneNo,
    String password,
  ) async {
    try {
      // 2. Updating the state
      isLoading.value = true;

      final credentials = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credentials.user?.uid;
      if (uid != null) {
        final userProfile = UserProfileModel(
          id: uid,
          fullName: fullName,
          email: email,
          phoneNo: phoneNo,
          profileImage: null,
          createdAt: DateTime.now().toIso8601String(),
        );
        await _db.collection('users').doc(uid).set({
          'fullName': userProfile.fullName,
          'email': userProfile.email,
          'phoneNo': userProfile.phoneNo,
          'profileImage': userProfile.profileImage,
          'createdAt': FieldValue.serverTimestamp(),
        });
        await UserLocalDb.instance.upsertUser(userProfile);
      }
      isLoading.value = false;
      Get.snackbar(
        'Success',
        'Account created successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      Get.snackbar(
        'Error',
        e.message ?? 'An error occurred',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (_) {
      isLoading.value = false;
      Get.snackbar(
        'Error',
        'Something went wrong',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> login(String email, String password) async {
    try {
      // 2. Updating the state
      isLoading.value = true;
      final credentials = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _cacheUserFromFirestore(credentials.user?.uid);

      // Update state back to false
      isLoading.value = false;
      Get.snackbar(
        'Success',
        'Logged in successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      Get.snackbar(
        'Error',
        e.message ?? 'An error occurred',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (_) {
      isLoading.value = false;
      Get.snackbar(
        'Error',
        'Something went wrong',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> logout() async {
    await UserLocalDb.instance.deleteUser();
    await _auth.signOut();
  }

  Future<void> changePassword(String newPassword) async {
    try {
      isLoading.value = true;
      await _auth.currentUser?.updatePassword(newPassword);
      isLoading.value = false;
      Get.snackbar(
        'Success',
        'Password changed successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      String message = e.message ?? 'An error occurred';
      if (e.code == 'requires-recent-login') {
        message =
            'Please re-login to change your password for security reasons.';
      }
      Get.snackbar(
        'Error',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (_) {
      isLoading.value = false;
      Get.snackbar(
        'Error',
        'Something went wrong',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> deleteAccount() async {
    try {
      isLoading.value = true;
      final uid = _auth.currentUser?.uid;
      if (uid == null) throw Exception('User not found');

      // 1. Delete Firestore User Document
      await _db.collection('users').doc(uid).delete();

      // 2. Delete Auth Account
      await _auth.currentUser?.delete();

      // 3. Cleanup Local DB & Sign Out
      await logout();

      isLoading.value = false;
      Get.snackbar(
        'Success',
        'Account deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      String message = e.message ?? 'An error occurred';
      if (e.code == 'requires-recent-login') {
        message =
            'Please re-login to delete your account for security reasons.';
      }
      Get.snackbar(
        'Error',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (_) {
      isLoading.value = false;
      Get.snackbar(
        'Error',
        'Something went wrong',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _cacheUserFromFirestore(String? uid) async {
    if (uid == null) return;
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return;
    final profile = UserProfileModel.fromSnapshot(doc);
    await UserLocalDb.instance.upsertUser(profile);
  }
}
