import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/browse_controller.dart';
import '../models/ticketmaster_event.dart';
import '../../favourites/controllers/favourites_controller.dart';
import '../../favourites/models/favourite_event_model.dart';

class TicketmasterEventsScreen extends StatelessWidget {
  const TicketmasterEventsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BrowseController());
    final favouritesController = Get.find<FavouritesController>();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search Ticketmaster events...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
            onSubmitted: (value) {
              controller.searchEvents(value);
            },
          ),
        ),

        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.errorMessage.value.isNotEmpty) {
              final isNetworkError = controller.errorMessage.value.toLowerCase().contains('internet') ||
                  controller.errorMessage.value.toLowerCase().contains('network');
              
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isNetworkError ? Icons.wifi_off : Icons.error_outline,
                      size: 64,
                      color: isNetworkError ? Colors.orange[300] : Colors.red[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isNetworkError ? 'No Internet Connection' : 'Error loading events',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Text(
                        controller.errorMessage.value,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => controller.fetchEvents(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isNetworkError ? Colors.orange : AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              );
            }

            if (controller.events.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No events found',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Try searching for something else',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => controller.fetchEvents(),
              child: ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: controller.events.length,
                itemBuilder: (context, index) {
                  final event = controller.events[index];
                  return _buildEventCard(context, event, favouritesController);
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildEventCard(
    BuildContext context,
    TicketmasterEvent event,
    FavouritesController favouritesController,
  ) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (event.imageUrl != null)
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: Image.network(
                    event.imageUrl!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.event,
                          size: 64,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Obx(
                    () => CircleAvatar(
                      backgroundColor: Colors.white,
                      child: IconButton(
                        icon: Icon(
                          favouritesController.isFavourite(event.id)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: favouritesController.isFavourite(event.id)
                              ? Colors.red
                              : Colors.grey,
                        ),
                        onPressed: () {
                          final favouriteEvent =
                              FavouriteEventModel.fromTicketmasterEvent({
                                'id': event.id,
                                'name': event.name,
                                'dates': {
                                  'start': {
                                    'dateTime': event.startDate
                                        ?.toIso8601String(),
                                  },
                                },
                                '_embedded': {
                                  'venues': [
                                    {
                                      'name': event.venueName,
                                      'city': {'name': event.city},
                                    },
                                  ],
                                },
                                'url': event.url,
                                'images': [
                                  {'url': event.imageUrl},
                                ],
                              });
                          favouritesController.toggleFavourite(favouriteEvent);
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),

                if (event.startDate != null)
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat.yMMMd().format(event.startDate!),
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),

                if (event.venueName != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${event.venueName}${event.city != null ? ', ${event.city}' : ''}${event.state != null ? ', ${event.state}' : ''}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    ],
                  ),
                ],

                if (event.priceRange != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.attach_money,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        event.priceRange!,
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _openEventUrl(event.url),
                    icon: const Icon(Icons.open_in_browser),
                    label: const Text('View Details & Buy Tickets'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openEventUrl(String? url) async {
    if (url == null || url.isEmpty) {
      Get.snackbar(
        'Error',
        'Event URL not available',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      final Uri uri = Uri.parse(url);
      final bool launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      
      if (!launched) {
        Get.snackbar(
          'Error',
          'Could not open event link',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to open browser: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
