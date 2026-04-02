import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post.dart';

class PostsService {
  final _collection = FirebaseFirestore.instance.collection('posts');

  Stream<List<Post>> getPosts() {
    return _collection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => Post.fromMap(d.data(), d.id)).toList());
  }

  Future<void> addPost(Post post) => _collection.add(post.toMap());

  Future<void> updatePost(Post post) {
    final data = <String, dynamic>{
      'title': post.title,
      'text': post.text,
      'imageUrl': post.imageUrl,
    };
    return _collection.doc(post.id).update(data);
  }

  Future<void> deletePost(String id) => _collection.doc(id).delete();
}
