import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../events/views/my_events_screen.dart';
import 'ticketmaster_events_screen.dart';

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
    return const EventListContent(showFavouriteButton: true);
  }
}
