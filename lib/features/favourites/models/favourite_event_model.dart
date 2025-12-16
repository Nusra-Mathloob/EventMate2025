class FavouriteEventModel {
  String id;
  String title;
  String description;
  DateTime date;
  String location;
  bool isTicketmasterEvent;
  String? ticketmasterUrl; 
  String? imageUrl;
  String? organizerId;

  FavouriteEventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.location,
    this.isTicketmasterEvent = false,
    this.ticketmasterUrl,
    this.imageUrl,
    this.organizerId,
  });

  // Community events
  factory FavouriteEventModel.fromCommunityEvent(Map<String, dynamic> event) {
    return FavouriteEventModel(
      id: event['id'] ?? '',
      title: event['title'] ?? '',
      description: event['description'] ?? '',
      date: event['date'] is DateTime
          ? event['date']
          : DateTime.parse(event['date']),
      location: event['location'] ?? '',
      organizerId: event['organizerId'],
      isTicketmasterEvent: false,
    );
  }

  // Ticketmaster events
  factory FavouriteEventModel.fromTicketmasterEvent(
    Map<String, dynamic> event,
  ) {
    String location = 'Unknown Location';
    if (event['_embedded']?['venues'] != null &&
        (event['_embedded']['venues'] as List).isNotEmpty) {
      final venue = event['_embedded']['venues'][0];
      location = '${venue['name'] ?? ''}, ${venue['city']?['name'] ?? ''}';
    }

    String imageUrl = '';
    if (event['images'] != null && (event['images'] as List).isNotEmpty) {
      imageUrl = event['images'][0]['url'] ?? '';
    }

    return FavouriteEventModel(
      id: event['id'] ?? '',
      title: event['name'] ?? '',
      description:
          event['info'] ?? event['pleaseNote'] ?? 'No description available',
      date: event['dates']?['start']?['dateTime'] != null
          ? DateTime.parse(event['dates']['start']['dateTime'])
          : DateTime.now(),
      location: location,
      isTicketmasterEvent: true,
      ticketmasterUrl: event['url'],
      imageUrl: imageUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'location': location,
      'isTicketmasterEvent': isTicketmasterEvent,
      'ticketmasterUrl': ticketmasterUrl,
      'imageUrl': imageUrl,
      'organizerId': organizerId,
    };
  }

  factory FavouriteEventModel.fromJson(Map<String, dynamic> json) {
    return FavouriteEventModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      date: DateTime.parse(json['date']),
      location: json['location'],
      isTicketmasterEvent: json['isTicketmasterEvent'] ?? false,
      ticketmasterUrl: json['ticketmasterUrl'],
      imageUrl: json['imageUrl'],
      organizerId: json['organizerId'],
    );
  }
}
