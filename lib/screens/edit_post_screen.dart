import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/media_model.dart';

class EditPostScreen extends StatefulWidget {
  final MediaModel media;
  const EditPostScreen({super.key, required this.media});

  @override
  State<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _captionController;
  late TextEditingController _hashtagsController;
  late TextEditingController _tagsController;
  late TextEditingController _locationController;
  late TextEditingController _audioNameController;
  late TextEditingController _audioUrlController;

  final CollectionReference postsRef = FirebaseFirestore.instance.collection('posts');

  @override
  void initState() {
    super.initState();
    _captionController = TextEditingController(text: widget.media.caption);
    _hashtagsController = TextEditingController(text: widget.media.hashtags.join(', '));
    _tagsController = TextEditingController(text: widget.media.tags.join(', '));
    _locationController = TextEditingController(text: widget.media.location);
    _audioNameController = TextEditingController(text: widget.media.audioName);
    _audioUrlController = TextEditingController(text: widget.media.audioUrl);
  }

  Future<void> _savePost() async {
    if (_formKey.currentState?.validate() ?? false) {
      await postsRef.doc(widget.media.id).update({
        'caption': _captionController.text,
        'hashtags': _hashtagsController.text.split(',').map((e) => e.trim()).toList(),
        'tags': _tagsController.text.split(',').map((e) => e.trim()).toList(),
        'location': _locationController.text,
        'audioName': _audioNameController.text,
        'audioUrl': _audioUrlController.text,
      });
      Navigator.pop(context, true); // return true để HomeScreen refresh
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Edit Post'),
        actions: [IconButton(icon: const Icon(Icons.save), onPressed: _savePost)],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(controller: _captionController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Caption', labelStyle: TextStyle(color: Colors.white))),
              TextFormField(controller: _hashtagsController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Hashtags (comma separated)', labelStyle: TextStyle(color: Colors.white))),
              TextFormField(controller: _tagsController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Tags (comma separated)', labelStyle: TextStyle(color: Colors.white))),
              TextFormField(controller: _locationController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Location', labelStyle: TextStyle(color: Colors.white))),
              TextFormField(controller: _audioNameController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Audio Name', labelStyle: TextStyle(color: Colors.white))),
              TextFormField(controller: _audioUrlController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Audio URL', labelStyle: TextStyle(color: Colors.white))),
            ],
          ),
        ),
      ),
    );
  }
}
