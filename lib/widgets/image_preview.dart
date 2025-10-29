import 'dart:io';
import 'package:flutter/material.dart';

class ImagePreview extends StatelessWidget {
  final String path;
  const ImagePreview({super.key, required this.path});
  @override
  Widget build(BuildContext context) {
    return Image.file(File(path), fit: BoxFit.cover);
  }
}
