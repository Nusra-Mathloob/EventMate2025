class TicketmasterEvent {
  final String id;
  final String name;
  final String? imageUrl;
  final DateTime? startDate;
  final String? venueName;
  final String? city;
  final String? state;
  final String? url;
  final String? priceRange;

  TicketmasterEvent({
    required this.id,
    required this.name,
    this.imageUrl,
    this.startDate,
    this.venueName,
    this.city,
    this.state,
    this.url,
    this.priceRange,
  });

  factory TicketmasterEvent.fromJson(Map<String, dynamic> json) {
    String? imageUrl;
    if (json['images'] != null && (json['images'] as List).isNotEmpty) {
      imageUrl = json['images'][0]['url'];
    }

    DateTime? startDate;
    if (json['dates']?['start']?['localDate'] != null) {
      try {
        startDate = DateTime.parse(json['dates']['start']['localDate']);
      } catch (e) {
        startDate = null;
      }
    }

    String? venueName;
    String? city;
    String? state;
    if (json['_embedded']?['venues'] != null && 
        (json['_embedded']['venues'] as List).isNotEmpty) {
      final venue = json['_embedded']['venues'][0];
      venueName = venue['name'];
      city = venue['city']?['name'];
      state = venue['state']?['name'];
    }

    String? priceRange;
    if (json['priceRanges'] != null && (json['priceRanges'] as List).isNotEmpty) {
      final price = json['priceRanges'][0];
      priceRange = '\$${price['min']} - \$${price['max']}';
    }

    return TicketmasterEvent(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unnamed Event',
      imageUrl: imageUrl,
      startDate: startDate,
      venueName: venueName,
      city: city,
      state: state,
      url: json['url'],
      priceRange: priceRange,
    );
  }
}
