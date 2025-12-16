import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfileModel {
  String? id;
  String fullName;
  String email;
  String phoneNo;
  String? profileImage;

  UserProfileModel({
    this.id,
    required this.fullName,
    required this.email,
    required this.phoneNo,
    this.profileImage,
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'phoneNo': phoneNo,
      'profileImage': profileImage,
    };
  }
}
