

import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../services/post_service.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final PostService postService = PostService();

  List<Post> favorites = [];

  @override
  void initState() {
    super.initState();
    favorites = postService.getFavorites();
  }

  Future<void> removeFavorite(Post post) async {
    await postService.toggleFavorite(post);

    if (!mounted) return;

    setState(() {
      favorites = postService.getFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
      ),
      body: favorites.isEmpty
          ? const Center(
              child: Text(
                'No favorite posts yet',
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final post = favorites[index];

                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(post.title),
                    subtitle: Text(post.body),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.favorite,
                        color: Colors.red,
                      ),
                      onPressed: () => removeFavorite(post),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
