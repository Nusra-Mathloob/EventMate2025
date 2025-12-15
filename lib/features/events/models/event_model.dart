import 'package:cloud_firestore/cloud_firestore.dart';

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

  factory EventModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;
    return EventModel(
      id: document.id,
      title: data['title'],
      description: data['description'],
      date: (data['date'] as Timestamp).toDate(),
      location: data['location'],
      organizerId: data['organizerId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'date': Timestamp.fromDate(date),
      'location': location,
      'organizerId': organizerId,
    };
  }
}
