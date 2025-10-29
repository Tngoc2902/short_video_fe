import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class PhotoEditorScreen extends StatelessWidget {
  final AssetEntity asset;
  const PhotoEditorScreen({super.key, required this.asset});
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: asset.file,
      builder: (context, snap) {
        if (!snap.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator()));
        final file = snap.data!;
        return Scaffold(
          appBar: AppBar(title: const Text('Edit Photo')),
          body: Column(children: [
            Expanded(child: Image.file(file)),
            ElevatedButton(onPressed: () => Navigator.of(context).pop(file.path), child: const Text('Use this photo')),
          ]),
        );
      },
    );
  }
}
