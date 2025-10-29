import 'package:flutter/material.dart';
import '../models/audio.dart';

class SelectAudioScreen extends StatelessWidget {
  final Audio? selected;
  final Function(Audio)? onSelected;
  const SelectAudioScreen({super.key, this.selected, this.onSelected});
  @override
  Widget build(BuildContext context) {
    final audios = List.generate(8, (i) => Audio(name: 'Song ${i+1}', url: 'https://example.com/${i+1}.mp3'));
    return Scaffold(
      appBar: AppBar(title: const Text('Select audio')),
      body: ListView.builder(
        itemCount: audios.length,
        itemBuilder: (context, i) => ListTile(title: Text(audios[i].name), onTap: () => Navigator.of(context).pop(audios[i])),
      ),
    );
  }
}
