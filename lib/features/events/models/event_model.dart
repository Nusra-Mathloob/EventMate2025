import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  String? id;
  String title;
  String description;
  DateTime date;
  String location;
  String userId;
  String userName;
  DateTime? createdAt;
  DateTime? updatedAt;

  EventModel({
    this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.location,
    required this.userId,
    this.userName = '',
    this.createdAt,
    this.updatedAt,
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
    final created = _parseDate(json['createdAt']);
    final updated = _parseDate(json['updatedAt']);
    return EventModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      date: parsedDate,
      location: json['location'],
      userId: json['userId'] ?? json['organizerId'],
      userName: json['userName'] ?? json['organizerName'] ?? '',
      createdAt: created,
      updatedAt: updated,
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
    final created = _parseDate(data['createdAt']);
    final updated = _parseDate(data['updatedAt']);
    return EventModel(
      id: document.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      date: parsedDate,
      location: data['location'] ?? '',
      userId: data['userId'] ?? data['organizerId'] ?? '',
      userName: data['userName'] ?? data['organizerName'] ?? '',
      createdAt: created,
      updatedAt: updated,
    );
  }

  factory EventModel.fromDbMap(Map<String, dynamic> data) {
    return EventModel(
      id: data['id']?.toString(),
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      date: DateTime.tryParse(data['date']?.toString() ?? '') ?? DateTime.now(),
      location: data['location'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      createdAt: DateTime.tryParse(data['createdAt']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(data['updatedAt']?.toString() ?? ''),
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
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
    };
  }

  Map<String, dynamic> toDbMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'location': location,
      'userId': userId,
      'userName': userName,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
