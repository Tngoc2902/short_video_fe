import 'dart:io';
import 'package:flutter/material.dart';
import '../models/media_model.dart';

class MediaTile extends StatelessWidget {
  final MediaModel media;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;
  const MediaTile({super.key, required this.media, this.onDelete, this.onTap});
  @override
  Widget build(BuildContext context) {
    final isImage = media.type == 'image';
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: const Color(0xFF161616),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: isImage ? Image.file(File(media.path), width: double.infinity, fit: BoxFit.cover) : Container(color: Colors.black26, child: const Center(child: Icon(Icons.videocam, color: Colors.white70, size: 40))),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(children: [
              Expanded(child: Text(media.path.split('/').last, style: const TextStyle(color: Colors.white, fontSize: 13), overflow: TextOverflow.ellipsis)),
              IconButton(icon: const Icon(Icons.delete, color: Colors.redAccent), onPressed: onDelete)
            ]),
          ),
        ]),
      ),
    );
  }
}
