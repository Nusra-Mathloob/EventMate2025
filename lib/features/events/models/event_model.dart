// import 'package:cloud_firestore/cloud_firestore.dart'; // DISABLED FOR DEVELOPMENT

class EventModel {
  String? id;
  String title;
  String description;
  DateTime date;
  String location;
  String organizerId;

  EventModel({
    this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.location,
    required this.organizerId,
  });

  // Factory for creating from JSON (mock data)
  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      date: json['date'] is DateTime ? json['date'] : DateTime.parse(json['date']),
      location: json['location'],
      organizerId: json['organizerId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'location': location,
      'organizerId': organizerId,
    };
  }
}
