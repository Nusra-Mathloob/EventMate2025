import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  String? id;
  String title;
  String description;
  DateTime date;
  String location;
  String userId;
  String userName;

  EventModel({
    this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.location,
    required this.userId,
    this.userName = '',
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    final rawDate = json['date'];
    final parsedDate = rawDate is Timestamp
        ? rawDate.toDate()
        : rawDate is DateTime
        ? rawDate
        : rawDate is String
        ? DateTime.tryParse(rawDate) ?? DateTime.now()
        : DateTime.now();
    return EventModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      date: parsedDate,
      location: json['location'],
      userId: json['userId'] ?? json['organizerId'],
      userName: json['userName'] ?? json['organizerName'] ?? '',
    );
  }

  factory EventModel.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? {};
    final rawDate = data['date'];
    final parsedDate = rawDate is Timestamp
        ? rawDate.toDate()
        : rawDate is DateTime
        ? rawDate
        : rawDate is String
        ? DateTime.tryParse(rawDate) ?? DateTime.now()
        : DateTime.now();
    return EventModel(
      id: document.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      date: parsedDate,
      location: data['location'] ?? '',
      userId: data['userId'] ?? data['organizerId'] ?? '',
      userName: data['userName'] ?? data['organizerName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'date': Timestamp.fromDate(date),
      'location': location,
      'userId': userId,
      'userName': userName,
    };
  }
}
