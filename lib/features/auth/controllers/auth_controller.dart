import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class AuthController extends GetxController {
  static AuthController get instance => Get.find();

  // Variables
  final _auth = FirebaseAuth.instance;
  late final Rx<User?> firebaseUser;
  var isLoading = false.obs;

  @override
  void onReady() {
    // firebaseUser = Rx<User?>(_auth.currentUser);
    // firebaseUser.bindStream(_auth.userChanges());
    // ever(firebaseUser, _setInitialScreen);
    super.onReady();
  }

  _setInitialScreen(User? user) {
    if (user == null) {
      Get.offAllNamed('/login');
    } else {
      Get.offAllNamed('/home');
    }
  }

  Future<void> register(String email, String password) async {
    try {
      isLoading.value = true;
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      isLoading.value = false;
      Get.snackbar(
        'Success',
        'Account created successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      Get.offAllNamed('/home');
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
      isLoading.value = true;
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      isLoading.value = false;
      Get.snackbar(
        'Success',
        'Logged in successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      Get.offAllNamed('/home');
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
    await _auth.signOut();
    Get.offAllNamed('/login');
  }
}
