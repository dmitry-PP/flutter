import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String title;
  final String text;
  final String authorEmail;
  final DateTime? createdAt;
  final String? imageUrl;

  Post({
    required this.id,
    required this.title,
    required this.text,
    required this.authorEmail,
    this.createdAt,
    this.imageUrl,
  });

  factory Post.fromMap(Map<String, dynamic> map, String id) {
    return Post(
      id: id,
      title: map['title'] as String? ?? '',
      text: map['text'] as String? ?? '',
      authorEmail: map['authorEmail'] as String? ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      imageUrl: map['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'text': text,
      'authorEmail': authorEmail,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'imageUrl': imageUrl,
    };
  }
}
