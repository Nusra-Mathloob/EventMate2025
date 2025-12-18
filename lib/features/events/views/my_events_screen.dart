import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/event_controller.dart';
import '../../favourites/controllers/favourites_controller.dart';
import '../../favourites/models/favourite_event_model.dart';
import 'add_event_screen.dart';
import 'event_detail_screen.dart';

class EventListScreen extends StatelessWidget {
  const EventListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Events',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: const EventListContent(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => const AddEventScreen());
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class EventListContent extends StatelessWidget {
  final bool showFavouriteButton;

  const EventListContent({Key? key, this.showFavouriteButton = false})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EventController());
    final favouritesController = showFavouriteButton
        ? Get.find<FavouritesController>()
        : null;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Events',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder(
              stream: controller.getAllEvents(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Something went wrong'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_busy,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No events yet',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Create your first event',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                final events = snapshot.data!;
                return ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(
                          event.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(DateFormat.yMMMd().format(event.date)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Expanded(child: Text(event.location)),
                              ],
                            ),
                          ],
                        ),
                        trailing:
                            showFavouriteButton && favouritesController != null
                            ? Obx(
                                () => IconButton(
                                  icon: Icon(
                                    favouritesController.isFavourite(
                                          event.id ?? '',
                                        )
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color:
                                        favouritesController.isFavourite(
                                          event.id ?? '',
                                        )
                                        ? Colors.red
                                        : Colors.grey,
                                  ),
                                  onPressed: () {
                                    final favouriteEvent = FavouriteEventModel(
                                      id: event.id ?? '',
                                      title: event.title,
                                      description: event.description,
                                      date: event.date,
                                      location: event.location,
                                      organizerId: event.userId,
                                      isTicketmasterEvent: false,
                                    );
                                    favouritesController.toggleFavourite(
                                      favouriteEvent,
                                    );
                                  },
                                ),
                              )
                            : const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Get.to(() => EventDetailScreen(event: event));
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
