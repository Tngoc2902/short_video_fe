import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/media_model.dart';
import '../widgets/media_card.dart';
import 'edit_post_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CollectionReference postsRef = FirebaseFirestore.instance.collection('posts');

  Future<List<MediaModel>> fetchPosts() async {
    final snapshot = await postsRef.orderBy('createdAt', descending: true).get();
    return snapshot.docs.map((doc) => MediaModel.fromJson(doc.data() as Map<String, dynamic>, doc.id)).toList();
  }

  Future<void> deletePost(String id) async {
    await postsRef.doc(id).delete();
    setState(() {}); // refresh
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text('Home')),
      body: FutureBuilder<List<MediaModel>>(
        future: fetchPosts(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Colors.white));
          final posts = snapshot.data!;
          if (posts.isEmpty) return const Center(child: Text('No posts yet', style: TextStyle(color: Colors.white)));
          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final media = posts[index];
              return MediaCard(
                media: media,
                onEdit: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => EditPostScreen(media: media)),
                  );
                  if (result == true) setState(() {});
                },
                onDelete: () => deletePost(media.id),
              );
            },
          );
        },
      ),
    );
  }
}
