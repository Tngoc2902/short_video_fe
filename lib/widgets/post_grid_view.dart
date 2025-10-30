import 'package:flutter/material.dart';
import '../models/post.dart';

class PostGridView extends StatelessWidget {
  final List<PostModel> posts;
  final void Function(PostModel post)? onTap;

  const PostGridView({Key? key, required this.posts, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double itemSize = MediaQuery.of(context).size.width / 3 - 2;
    if (posts.isEmpty) {
      return const Center(
        child: Text('No posts yet', style: TextStyle(color: Colors.white54)),
      );
    }
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];

        final imageUrl = post.imageUrl;

        return GestureDetector(
          onTap: () => onTap?.call(post),
          child: SizedBox.square(
            dimension: itemSize,
            child: imageUrl.isNotEmpty
                ? Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      color: Colors.grey[800],
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[800],
                      child: const Icon(Icons.error, color: Colors.red),
                    );
                  },
                ),
                if (post.isVideo)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
              ],
            )
                : Container(
              color: Colors.grey[800],
              child: const Center(
                child: Icon(
                  Icons.text_fields,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

