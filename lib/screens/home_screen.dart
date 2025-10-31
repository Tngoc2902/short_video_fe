import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/media_provider.dart';
import '../components/media_tile.dart';
import '../models/media_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MediaProvider>(context, listen: false).fetchMedia();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MediaProvider>(context);
    final items = provider.mediaList;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('ShortVideo', style: TextStyle(color: Colors.white)),
        automaticallyImplyLeading: false,
      ),
      body: provider.loading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : items.isEmpty
          ? const Center(child: Text('Chưa có bài viết nào', style: TextStyle(color: Colors.white70)))
          : Padding(
        padding: const EdgeInsets.all(12),
        child: ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, i) {
            final media = items[i];
            return Card(
              color: Colors.grey[900],
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                      height: 250,
                      width: double.infinity,
                      child: MediaTile(
                        media: media,
                        onDelete: () => provider.deleteMedia(media.id),
                      )),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (media.caption.isNotEmpty)
                          Text(media.caption, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        if (media.hashtags.isNotEmpty)
                          Text(media.hashtags.join(' '), style: const TextStyle(color: Colors.blueAccent)),
                        if (media.tags.isNotEmpty)
                          Text('Tags: ${media.tags.join(', ')}', style: const TextStyle(color: Colors.white70)),
                        if (media.location.isNotEmpty)
                          Text('Location: ${media.location}', style: const TextStyle(color: Colors.white70)),
                        if (media.audioName.isNotEmpty)
                          Text('Music: ${media.audioName}', style: const TextStyle(color: Colors.white70)),
                        Text('Created at: ${media.createdAt}', style: const TextStyle(color: Colors.white54)),
                      ],
                    ),
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
