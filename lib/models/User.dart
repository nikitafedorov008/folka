import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String name;
  final String surname;
  final String birthdate;
  final String profileImageUrl;
  final String email;
  final String bio;

  User({
    this.id,
    this.name,
    this.surname,
    this.birthdate,
    this.profileImageUrl,
    this.email,
    this.bio,
  });

  factory User.fromDoc(DocumentSnapshot doc) {
    return User(
      id: doc.documentID,
      name: doc['name'],
      surname: doc['surname'],
      birthdate: doc['bithdate'],
      profileImageUrl: doc['profileImageUrl'],
      email: doc['email'],
      bio: doc['bio'] ?? '',
    );
  }
}
