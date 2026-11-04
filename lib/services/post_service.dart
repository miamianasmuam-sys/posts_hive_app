
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

import '../models/post_model.dart';

class PostService {
  static const String apiUrl =
      'https://jsonplaceholder.typicode.com/posts';

  final Box<Post> postsBox = Hive.box<Post>('postsBox');
  final Box<Post> favoritesBox = Hive.box<Post>('favoritesBox');

  Future<List<Post>> getPosts() async {
    try {
      final response = await http
          .get(Uri.parse(apiUrl))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        final onlinePosts = data
            .map((item) => Post.fromJson(item))
            .toList();

        // Update API posts without deleting manually added posts.
        for (final post in onlinePosts) {
          await postsBox.put(post.id, post);
        }

        debugPrint('Loaded ${onlinePosts.length} posts from API');

        return postsBox.values.toList();
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('API failed: $e');

      if (postsBox.isNotEmpty) {
        debugPrint('Loading posts from Hive offline');
        return postsBox.values.toList();
      }

      throw Exception('No internet connection and no cached posts');
    }
  }

  List<Post> getAllPosts() {
    return postsBox.values.toList();
  }

  Future<void> addPost(Post post) async {
    await postsBox.add(post);
  }

  Future<void> updatePost(int index, Post post) async {
    await postsBox.putAt(index, post);
  }

  Future<void> deletePost(int index) async {
    await postsBox.deleteAt(index);
  }

  bool isFavorite(Post post) {
    return favoritesBox.values.any((p) => p.id == post.id);
  }

  Future<void> toggleFavorite(Post post) async {
    final existingKey = favoritesBox.keys.firstWhere(
      (key) => favoritesBox.get(key)?.id == post.id,
      orElse: () => null,
    );

    if (existingKey != null) {
      await favoritesBox.delete(existingKey);
    } else {
      final favoriteCopy = Post(
        id: post.id,
        title: post.title,
        body: post.body,
        userId: post.userId,
      );

      await favoritesBox.add(favoriteCopy);
    }
  }

  List<Post> getFavorites() {
    return favoritesBox.values.toList();
  }
}
