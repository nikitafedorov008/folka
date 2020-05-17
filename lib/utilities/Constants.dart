import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

final _firestore = Firestore.instance;
final storageRef = FirebaseStorage.instance.ref();
final usersRef = _firestore.collection('users');
final postsRef = _firestore.collection('posts');
final feedRef = _firestore.collection('feed');
final followersRef = _firestore.collection('followers');
final followingRef = _firestore.collection('following');
final feedsRef = _firestore.collection('feeds');
final likesRef = _firestore.collection('likes');
final favouriteRef = _firestore.collection('favourite');
final commentsRef = _firestore.collection('comments');
final activitiesRef = _firestore.collection('activities');
final ratingRef = _firestore.collection('rating');