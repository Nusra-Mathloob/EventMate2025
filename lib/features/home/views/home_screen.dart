import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../browse/views/browse_events_tab_screen.dart';
import '../../events/views/my_events_screen.dart';
import '../../favourites/views/favourites_screen.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:intl/intl.dart';
import '../../events/controllers/event_controller.dart';
import '../../events/models/event_model.dart';
import '../../favourites/controllers/favourites_controller.dart';
import '../../profile/views/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final eventController = Get.put(EventController());
  final favController = Get.put(FavouritesController());
  DateTime? selectedDate = DateTime.now();
  bool _isCalendarVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'EventMate',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isCalendarVisible ? Icons.calendar_month : Icons.calendar_today_outlined),
            onPressed: () {
              setState(() {
                _isCalendarVisible = !_isCalendarVisible;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Get.to(() => const ProfileScreen());
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Text(
              'Welcome Back!',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Discover and manage your events',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),

            // Calendar Section
            if (_isCalendarVisible)
            StreamBuilder<List<EventModel>>(
              stream: eventController.getAllEvents(),
              builder: (context, snapshot) {
                return Obx(() {
                  final firestoreEvents = snapshot.data ?? [];
                  final favEvents = favController.favourites;
                  
                  // Combine dates for markers
                  final eventDates = <DateTime>{};
                  for (var e in firestoreEvents) {
                    eventDates.add(DateTime(e.date.year, e.date.month, e.date.day));
                  }
                  for (var e in favEvents) {
                    eventDates.add(DateTime(e.date.year, e.date.month, e.date.day));
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: CalendarDatePicker2(
                          config: CalendarDatePicker2Config(
                            calendarType: CalendarDatePicker2Type.single,
                            selectedDayHighlightColor: Theme.of(context).primaryColor,
                            dayBuilder: ({required date, textStyle, decoration, isSelected, isDisabled, isToday}) {
                              final isEventDay = eventDates.contains(DateTime(date.year, date.month, date.day));
                              
                              return Container(
                                decoration: decoration,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Text(
                                      date.day.toString(),
                                      style: textStyle,
                                    ),
                                    if (isEventDay && isSelected != true) 
                                      Positioned(
                                        bottom: 4,
                                        child: Container(
                                          width: 5,
                                          height: 5,
                                          decoration: BoxDecoration(
                                            color: Colors.redAccent,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                          value: [selectedDate ?? DateTime.now()],
                          onValueChanged: (dates) {
                            if (dates.isNotEmpty) {
                              setState(() {
                                selectedDate = dates.first;
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (selectedDate != null) ...[
                        Text(
                          'Schedule for ${DateFormat.yMMMd().format(selectedDate!)}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        // Firestore Events
                        ...firestoreEvents.where((e) => isSameDay(e.date, selectedDate!)).map((event) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: Container(
                              width: 4,
                              color: Theme.of(context).primaryColor,
                            ),
                            title: Text(event.title),
                            subtitle: Text(event.location),
                            dense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            onTap: () {
                              // Optional: navigate to details
                            },
                          ),
                        )),
                        // Favourites Events (Ticketmaster & Community)
                        ...favEvents.where((e) {
                          final matchesDate = isSameDay(e.date, selectedDate!);
                          // Deduplicate
                          final isDuplicate = firestoreEvents.any((fe) => fe.id == e.id);
                          return matchesDate && !isDuplicate;
                        }).map((event) {
                          final isTM = event.isTicketmasterEvent;
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: Container(
                                width: 4,
                                color: isTM ? Colors.orange : Colors.deepPurple,
                              ),
                              title: Text(event.title),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(event.location),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: (isTM ? Colors.orange : Colors.deepPurple).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      isTM ? 'Ticketmaster' : 'Community Favourite',
                                      style: TextStyle(
                                        color: isTM ? Colors.orange[800] : Colors.deepPurple[800],
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              dense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            ),
                          );
                        }),
                        if (firestoreEvents.where((e) => isSameDay(e.date, selectedDate!)).isEmpty && 
                            favEvents.where((e) => isSameDay(e.date, selectedDate!) && !firestoreEvents.any((fe) => fe.id == e.id)).isEmpty)
                           Padding(
                             padding: const EdgeInsets.all(8.0),
                             child: Text('No events scheduled.', style: TextStyle(color: Colors.grey)),
                           ),
                      ],
                    ],
                  );
                });
              },
            ),
            
            const SizedBox(height: 32),

            // Quick Actions
            Text(
              'Quick Actions',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Action Cards
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildActionCard(
                  context,
                  icon: Icons.explore,
                  title: 'Browse Events',
                  subtitle: 'Community & Ticketmaster',
                  color: AppColors.primary,
                  onTap: () {
                    Get.to(() => const BrowseEventsTabScreen());
                  },
                ),
                _buildActionCard(
                  context,
                  icon: Icons.list,
                  title: 'My Events',
                  subtitle: 'Events you created',
                  color: Colors.purple,
                  onTap: () {
                    Get.to(() => const EventListScreen());
                  },
                ),
                _buildActionCard(
                  context,
                  icon: Icons.favorite,
                  title: 'Favourites',
                  subtitle: 'Your saved events',
                  color: Colors.red,
                  onTap: () {
                    Get.to(() => const FavouritesScreen());
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
