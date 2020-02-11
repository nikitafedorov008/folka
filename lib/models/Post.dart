import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String imageUrl;
  final String caption;
  final String category;
  final String price;
  final String name;
  final String time;
  final int likeCount;
  final String authorId;
  final Timestamp timestamp;

  Post({
    this.id,
    this.imageUrl,
    this.caption,
    this.category,
    this.price,
    this.name,
    this.time,
    this.likeCount,
    this.authorId,
    this.timestamp,
  });

  factory Post.fromDoc(DocumentSnapshot doc) {
    return Post(
      id: doc.documentID,
      imageUrl: doc['imageUrl'],
      caption: doc['caption'],
      category: doc['category'],
      price: doc['price'],
      name: doc['name'],
      time: doc['time'],
      likeCount: doc['likeCount'],
      authorId: doc['authorId'],
      timestamp: doc['timestamp'],
    );
  }
}
