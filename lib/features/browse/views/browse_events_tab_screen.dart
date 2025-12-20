import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../events/views/my_events_screen.dart';
import 'ticketmaster_events_screen.dart';
import '../../events/controllers/event_controller.dart';
import '../../events/models/event_model.dart';
import '../../favourites/controllers/favourites_controller.dart';
import '../../favourites/models/favourite_event_model.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import '../../events/views/community_event_view_screen.dart';

class BrowseEventsTabScreen extends StatelessWidget {
  const BrowseEventsTabScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Browse Events',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          bottom: TabBar(
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(icon: Icon(Icons.people), text: 'Community'),
              Tab(icon: Icon(Icons.public), text: 'Ticketmaster'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [CommunityEventsTab(), TicketmasterEventsScreen()],
        ),
      ),
    );
  }
}

class CommunityEventsTab extends StatelessWidget {
  const CommunityEventsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EventController());
    final favouritesController = Get.find<FavouritesController>();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Community Events',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<List<EventModel>>(
              stream: controller.getCommunityEvents(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Something went wrong'));
                }
                final events = snapshot.data ?? [];
                if (events.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.groups_2_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No community events yet',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Check back soon for new events',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

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
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.person,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    'Posted by ${event.userName.isNotEmpty ? event.userName : 'Community member'}',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: Obx(
                          () => IconButton(
                            icon: Icon(
                              favouritesController.isFavourite(event.id ?? '')
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: favouritesController.isFavourite(
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
                        ),
                        onTap: () {
                          Get.to(() => CommunityEventViewScreen(event: event));
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
