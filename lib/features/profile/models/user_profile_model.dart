import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfileModel {
  String? id;
  String fullName;
  String email;
  String phoneNo;
  String? profileImage;
  String? createdAt;

  UserProfileModel({
    this.id,
    required this.fullName,
    required this.email,
    required this.phoneNo,
    this.profileImage,
    this.createdAt,
  });

  factory UserProfileModel.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data()!;
    return UserProfileModel(
      id: document.id,
      fullName: data['fullName'],
      email: data['email'],
      phoneNo: data['phoneNo'],
      profileImage: data['profileImage'],
      createdAt: (data['createdAt'] is Timestamp)
          ? (data['createdAt'] as Timestamp).toDate().toIso8601String()
          : data['createdAt']?.toString(),
    );
  }

  factory UserProfileModel.fromMap(Map<String, dynamic> data, {String? id}) {
    return UserProfileModel(
      id: id ?? data['id']?.toString(),
      fullName: data['fullName'] ?? '',
      email: data['email'] ?? '',
      phoneNo: data['phoneNo'] ?? '',
      profileImage: data['profileImage'],
      createdAt: data['createdAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'phoneNo': phoneNo,
      'profileImage': profileImage,
      'createdAt': createdAt,
    };
  }

  Map<String, dynamic> toDbMap() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phoneNo': phoneNo,
      'profileImage': profileImage,
      'createdAt': createdAt,
    };
  }
}
