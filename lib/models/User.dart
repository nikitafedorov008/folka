import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String name;
  final String surname;
  final String birthdate;
  final String address;
  final String rating;
  final String profileImageUrl;
  final String email;
  final String phone;
  final String bio;

  User({
    this.id,
    this.name,
    this.surname,
    this.birthdate,
    this.address,
    this.rating,
    this.profileImageUrl,
    this.email,
    this.phone,
    this.bio,
  });

  factory User.fromDoc(DocumentSnapshot doc) {
    return User(
      id: doc.documentID,
      name: doc['name'],
      surname: doc['surname'],
      birthdate: doc['bithdate'],
      address: doc['address'],
      rating: doc['rating'],
      profileImageUrl: doc['profileImageUrl'],
      email: doc['email'],
      phone: doc['phone'],
      bio: doc['bio'] ?? '',
    );
  }
}
