
import 'package:flutter/material.dart';

import '../models/post_model.dart';
import '../services/post_service.dart';
import 'favorites_screen.dart';

class PostsScreen extends StatefulWidget {
  const PostsScreen({super.key});

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  final PostService postService = PostService();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController bodyController = TextEditingController();

  List<Post> posts = [];

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadPosts();
  }

  @override
  void dispose() {
    titleController.dispose();
    bodyController.dispose();
    super.dispose();
  }

  Future<void> loadPosts() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await postService.getPosts();

      if (!mounted) return;

      setState(() {
        posts = result;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> addPost(BuildContext dialogContext) async {
    final title = titleController.text.trim();
    final body = bodyController.text.trim();
    final messenger = ScaffoldMessenger.of(context);

    if (title.isEmpty || body.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Please enter title and body'),
        ),
      );
      return;
    }

    try {
      final post = Post(
        id: DateTime.now().millisecondsSinceEpoch,
        title: title,
        body: body,
        userId: 1,
      );

      await postService.addPost(post);

      if (!mounted || !dialogContext.mounted) return;

      titleController.clear();
      bodyController.clear();

      Navigator.pop(dialogContext);

      await loadPosts();

      if (!mounted) return;

      messenger.showSnackBar(
        const SnackBar(
          content: Text('Post added successfully!'),
        ),
      );
    } catch (e) {
      debugPrint('Add post error: $e');
    }
  }

  Future<void> deletePost(int index) async {
    try {
      await postService.deletePost(index);
      await loadPosts();
    } catch (e) {
      debugPrint('Delete error: $e');
    }
  }

  Future<void> toggleFavorite(Post post) async {
    try {
      await postService.toggleFavorite(post);

      if (!mounted) return;

      setState(() {});
    } catch (e) {
      debugPrint('Favorite error: $e');
    }
  }

  void showAddPostDialog() {
    titleController.clear();
    bodyController.clear();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add New Post'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: bodyController,
                  decoration: const InputDecoration(
                    labelText: 'Body',
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => addPost(dialogContext),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> openFavorites() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FavoritesScreen(),
      ),
    );

    if (!mounted) return;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            tooltip: 'Favorites',
            onPressed: openFavorites,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: loadPosts,
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 45),
                      const SizedBox(height: 10),
                      Text(errorMessage!),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: loadPosts,
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                )
              : posts.isEmpty
                  ? const Center(
                      child: Text('No posts available'),
                    )
                  : RefreshIndicator(
                      onRefresh: loadPosts,
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          final post = posts[index];
                          final favorite =
                              postService.isFavorite(post);

                          return Card(
                            margin: const EdgeInsets.all(8),
                            child: ListTile(
                              title: Text(post.title),
                              subtitle: Text(post.body),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      favorite
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: favorite
                                          ? Colors.red
                                          : Colors.grey,
                                    ),
                                    onPressed: () =>
                                        toggleFavorite(post),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () =>
                                        deletePost(index),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddPostDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
