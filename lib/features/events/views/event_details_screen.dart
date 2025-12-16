import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../favourites/models/favourite_event_model.dart';

class EventDetailsScreen extends StatelessWidget {
  final FavouriteEventModel event;

  const EventDetailsScreen({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Event Details'), elevation: 0),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (event.imageUrl != null && event.imageUrl!.isNotEmpty)
              Container(
                width: double.infinity,
                height: 250,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(event.imageUrl!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

            // Event Details
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    event.title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Date
                  _buildInfoRow(
                    context,
                    icon: Icons.calendar_today,
                    label: 'Date',
                    value: DateFormat('EEEE, MMMM d, yyyy').format(event.date),
                  ),
                  const SizedBox(height: 12),

                  // Time
                  _buildInfoRow(
                    context,
                    icon: Icons.access_time,
                    label: 'Time',
                    value: DateFormat('h:mm a').format(event.date),
                  ),
                  const SizedBox(height: 12),

                  // Location
                  _buildInfoRow(
                    context,
                    icon: Icons.location_on,
                    label: 'Location',
                    value: event.location,
                  ),
                  const SizedBox(height: 24),

                  // Description
                  Text(
                    'About Event',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event.description,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Event Type Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: event.isTicketmasterEvent
                          ? Colors.blue.shade50
                          : Colors.green.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: event.isTicketmasterEvent
                            ? Colors.blue
                            : Colors.green,
                      ),
                    ),
                    child: Text(
                      event.isTicketmasterEvent
                          ? 'Ticketmaster Event'
                          : 'Community Event',
                      style: TextStyle(
                        color: event.isTicketmasterEvent
                            ? Colors.blue
                            : Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
