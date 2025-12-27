import 'dart:io';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/ticketmaster_event.dart';
import '../services/ticketmaster_service.dart';

class BrowseController extends GetxController {
  static BrowseController get instance => Get.find();

  final TicketmasterService _service = TicketmasterService();
  
  final RxList<TicketmasterEvent> events = <TicketmasterEvent>[].obs;
  final isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchEvents();
  }

  Future<void> fetchEvents({String keyword = '', String city = ''}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      print('BrowseController: Fetching events...'); 
      
      final fetchedEvents = await _service.searchEvents(
        keyword: keyword,
        city: city,
      );
      
      print('BrowseController: Fetched ${fetchedEvents.length} events'); 
      events.value = fetchedEvents;
      isLoading.value = false;
    } on SocketException {
      print('BrowseController: No internet connection'); 
      isLoading.value = false;
      errorMessage.value = 'No internet connection. Please check your network settings and try again.';
      Get.snackbar(
        'No Internet Connection',
        'Please check your network settings and try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        icon: const Icon(Icons.wifi_off, color: Colors.white),
      );
    } catch (e) {
      print('BrowseController: Error - $e'); 
      isLoading.value = false;
      String cleanError = e.toString().replaceAll('Exception: ', '');
      errorMessage.value = cleanError;
      Get.snackbar('Error', cleanError,
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void searchEvents(String keyword) {
    fetchEvents(keyword: keyword);
  }
}
