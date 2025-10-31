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
  final CollectionReference postsRef =
  FirebaseFirestore.instance.collection('posts');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text('Home')),
      body: StreamBuilder<QuerySnapshot>(
        stream: postsRef.orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.white));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
                child: Text('No posts yet',
                    style: TextStyle(color: Colors.white)));
          }

          final posts = snapshot.data!.docs
              .map((doc) =>
              MediaModel.fromJson(doc.data() as Map<String, dynamic>, doc.id))
              .toList();

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final media = posts[index];
              return MediaCard(
                media: media,
                onEdit: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => EditPostScreen(media: media)),
                  );
                  if (result == true) setState(() {});
                },
                onDelete: () => postsRef.doc(media.id).delete(),
              );
            },
          );
        },
      ),
    );
  }
}
