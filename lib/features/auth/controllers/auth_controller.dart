import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthController extends GetxController {
  static AuthController get instance => Get.find();

  // Variables
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;
  final Rx<User?> firebaseUser = Rx<User?>(null);
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

  Future<void> register(String fullName, String email, String phoneNo, String password) async {
    try {
      isLoading.value = true;
      final credentials = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credentials.user?.uid;
      if (uid != null) {
        await _db.collection('users').doc(uid).set({
          'fullName': fullName,
          'email': email,
          'phoneNo': phoneNo,
          'profileImage': null,
          'createdAt': FieldValue.serverTimestamp(),
        });
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
  }
}
