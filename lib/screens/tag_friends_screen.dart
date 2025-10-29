import 'package:flutter/material.dart';
import '../models/user.dart';

class TagFriendsScreen extends StatelessWidget {
  final List<User> initiallySelected;
  final Function(List<User>)? onSelected;
  const TagFriendsScreen({super.key, this.initiallySelected = const [], this.onSelected});
  @override
  Widget build(BuildContext context) {
    final friends = List.generate(12, (i) => User(id: '${i+1}', username: 'friend${i+1}', nickname: 'Friend ${i+1}'));
    return Scaffold(
      appBar: AppBar(title: const Text('Tag friends')),
      body: ListView.builder(
        itemCount: friends.length,
        itemBuilder: (context, i) => ListTile(title: Text(friends[i].username), onTap: () => Navigator.of(context).pop([friends[i]])),
      ),
    );
  }
}
