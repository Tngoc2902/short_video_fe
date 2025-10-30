import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as FirebaseAuth;
import 'package:short_video_fe/models/user.dart';
import 'package:short_video_fe/services/user_service.dart';

class TagFriendsScreen extends StatefulWidget {
  final List<User> initiallySelected;
  final void Function(List<User>) onSelected;

  const TagFriendsScreen({
    super.key,
    required this.initiallySelected,
    required this.onSelected,
  });

  @override
  State<TagFriendsScreen> createState() => _TagFriendsScreenState();
}

class _TagFriendsScreenState extends State<TagFriendsScreen> {
  final UserService _userService = UserService();
  List<User> _results = [];
  List<User> _selected = [];
  String _search = '';
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _selected = List.from(widget.initiallySelected);
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() => _loading = true);
    final currentUserId = FirebaseAuth.FirebaseAuth.instance.currentUser?.uid ?? '';
    final users = await _userService.searchFollowing(currentUserId, _search);
    setState(() {
      _results = users;
      _loading = false;
    });
  }

  void _onSearchChanged(String value) {
    setState(() => _search = value);
    _fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tag bạn bè'),
        actions: [
          TextButton(
            onPressed: () {
              widget.onSelected(_selected);
              Navigator.pop(context, _selected);
            },
            child: const Text('Xong', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Tìm kiếm bạn bè...',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: _onSearchChanged,
              ),
            ),
            if (_loading)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _results.length,
                  itemBuilder: (context, index) {
                    final user = _results[index];
                    final isSelected = _selected.any((u) => u.id == user.id);

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                            ? NetworkImage(user.avatarUrl!)
                            : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
                      ),
                      title: Text(user.username),
                      subtitle: user.nickname != null ? Text(user.nickname!) : null,
                      trailing: isSelected
                          ? const Icon(Icons.check_circle, color: Colors.blue)
                          : const Icon(Icons.radio_button_unchecked),
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selected.removeWhere((u) => u.id == user.id);
                          } else {
                            _selected.add(user);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
