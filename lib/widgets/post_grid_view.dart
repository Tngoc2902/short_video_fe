import 'package:flutter/material.dart';
import '../models/post.dart';

class PostGridView extends StatelessWidget {
  final List<PostModel> posts;
  final void Function(PostModel)? onTap;

  const PostGridView({super.key, required this.posts, this.onTap});

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 40),
          child: Text(
            'Chưa có bài đăng nào',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ),
      );
    }

    return GridView.builder(
      key: ValueKey(posts.length),
      padding: const EdgeInsets.all(2),
      itemCount: posts.length,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        if (index < 0 || index >= posts.length) return const SizedBox.shrink();

        final post = posts[index];
        final mediaUrl = post.imageUrl; // dùng imageUrl từ model
        final isVideo = post.isVideo;

        return GestureDetector(
          onTap: () => onTap?.call(post),
          child: Container(
            color: Colors.grey[900],
            child: mediaUrl.isNotEmpty
                ? _buildMediaPreview(mediaUrl, isVideo)
                : Container(
              color: Colors.grey[850],
              child: const Icon(Icons.image_not_supported, color: Colors.white30),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMediaPreview(String url, bool isVideo) {
    if (isVideo) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            url,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: Colors.grey[800],
              child: const Icon(Icons.broken_image, color: Colors.white30),
            ),
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: Colors.grey[900],
                child: const Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
              );
            },
          ),
          const Center(
            child: Icon(Icons.play_circle_fill, color: Colors.white70, size: 40),
          ),
        ],
      );
    }

    // ảnh
    return Image.network(
      url,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: Colors.grey[900],
          child: const Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
        );
      },
      errorBuilder: (context, error, stackTrace) => Container(
        color: Colors.grey[800],
        child: const Icon(Icons.broken_image, color: Colors.white30),
      ),
    );
  }
}
