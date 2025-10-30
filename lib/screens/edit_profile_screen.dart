import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../services/user_service.dart';
import '../providers/auth_provider.dart';
import '../models/user.dart'; // Model User chi tiết

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _customGenderController = TextEditingController();

  // Dùng UserService từ Provider
  late UserService _userService;
  User? _currentUser;
  File? _selectedImage;
  bool _isLoading = true; // Bắt đầu là true để tải dữ liệu
  bool _isSaving = false; // Biến riêng cho việc lưu
  String? _error;
  String _selectedGender = '';
  String _currentAvatarUrl = ''; // Lưu URL avatar hiện tại

  final List<String> _genderOptions = [
    'Nam',
    'Nữ',
    'Tùy chỉnh',
    'Không muốn tiết lộ'
  ];

  @override
  void initState() {
    super.initState();
    // Lấy service từ Provider, không khởi tạo mới
    _userService = Provider.of<UserService>(context, listen: false);
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      if (!mounted) return;
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Lấy uid từ AuthProvider
      final uid = Provider.of<AuthProvider>(context, listen: false).user?.uid;
      if (uid == null) {
        throw Exception("User not logged in");
      }

      // Lấy thông tin chi tiết từ UserService (Firestore)
      final user = await _userService.getUserProfile(uid);

      if (!mounted) return;
      setState(() {
        _currentUser = user;
        _nicknameController.text = user.nickname ?? '';
        _usernameController.text = user.username;
        _bioController.text = user.bio ?? '';
        _linkController.text = user.link ?? '';
        _emailController.text = user.email;
        _genderController.text = user.gender ?? '';
        _selectedGender = user.gender ?? '';
        _currentAvatarUrl = user.avatarUrl; // Lưu avatar url
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _showImagePickerBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Chọn ảnh',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildImageOption(
                    icon: Icons.camera_alt,
                    label: 'Chụp ảnh',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                  ),
                  _buildImageOption(
                    icon: Icons.photo_library,
                    label: 'Thư viện',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }


  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  void _showGenderBottomSheet() {
    final originalGender = _selectedGender;
    final originalCustomText = _customGenderController.text;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Chọn giới tính',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ..._genderOptions
                      .where((gender) => gender != 'Tùy chỉnh')
                      .map((gender) => ListTile(
                    title: Text(
                      gender,
                      style: const TextStyle(color: Colors.white),
                    ),
                    trailing: _selectedGender == gender
                        ? const Icon(Icons.check, color: Colors.blue)
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedGender = gender;
                        _genderController.text = gender;
                      });
                      Navigator.pop(context);
                    },
                  ))
                      .toList(),
                  // Custom gender option
                  ListTile(
                    title: Text(
                      'Tùy chỉnh',
                      style: const TextStyle(color: Colors.white),
                    ),
                    trailing: _selectedGender == 'Tùy chỉnh'
                        ? const Icon(Icons.check, color: Colors.blue)
                        : null,
                    onTap: () {
                      setModalState(() {
                        _selectedGender = 'Tùy chỉnh';
                      });
                    },
                  ),
                  if (_selectedGender == 'Tùy chỉnh') ...[
                    const SizedBox(height: 16),
                    TextField(
                      controller: _customGenderController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Nhập giới tính tùy chỉnh',
                        hintStyle: TextStyle(color: Colors.white54),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white24),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                      ),
                      onChanged: (value) {
                        setModalState(() {
                          // Update the modal state to enable/disable confirm button
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: () {
                            // Restore original values
                            setState(() {
                              _selectedGender = originalGender;
                              _genderController.text = originalGender;
                            });
                            _customGenderController.text = originalCustomText;
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Hủy',
                            style: TextStyle(color: Colors.white54),
                          ),
                        ),
                        ElevatedButton(
                          onPressed:
                          _customGenderController.text.trim().isNotEmpty
                              ? () {
                            setState(() {
                              _genderController.text =
                                  _customGenderController.text.trim();
                            });
                            Navigator.pop(context);
                          }
                              : null,
                          child: const Text('Xác nhận'),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _saveProfile() async {
    final uid = Provider.of<AuthProvider>(context, listen: false).user?.uid;
    if (uid == null) {
      setState(() => _error = "User not logged in. Cannot save.");
      return;
    }

    try {
      setState(() {
        _isSaving = true;
        _error = null;
      });

      String finalAvatarUrl = _currentAvatarUrl;

      // 1. Tải ảnh mới lên (nếu có)
      if (_selectedImage != null) {
        finalAvatarUrl = await _userService.uploadAvatar(_selectedImage!, uid);
      }

      // 2. Chuẩn bị dữ liệu để cập nhật
      Map<String, dynamic> profileData = {
        'nickname': _nicknameController.text.trim(),
        'bio': _bioController.text.trim(),
        'link': _linkController.text.trim(),
        'gender': _genderController.text.trim(),
        'avatarUrl': finalAvatarUrl, // Cập nhật avatar url
      };

      // 3. Cập nhật Firestore
      await _userService.updateUserProfile(uid, profileData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        // Trả về true để báo ProfileScreen load lại
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(backgroundColor: Colors.black, iconTheme: const IconThemeData(color: Colors.white)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Error: $_error', style: const TextStyle(color: Colors.red)),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title:
        const Text('Edit Profile', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveProfile, // Vô hiệu hóa khi đang lưu
            child: _isSaving
                ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                  color: Colors.blue, strokeWidth: 2),
            )
                : const Text(
              'Save',
              style: TextStyle(color: Colors.blue, fontSize: 16),
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile image section
              Center(
                child: Stack(
                  children: [
                    // SỬA: Dùng CircleAvatar chuẩn
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[800],
                      // Hiển thị ảnh đã chọn (FileImage)
                      // Hoặc ảnh hiện tại (NetworkImage)
                      // Hoặc ảnh placeholder (Icon)
                      backgroundImage: _selectedImage != null
                          ? FileImage(_selectedImage!)
                          : (_currentAvatarUrl.isNotEmpty
                          ? NetworkImage(_currentAvatarUrl)
                          : null) as ImageProvider?,
                      child: (_selectedImage == null && _currentAvatarUrl.isEmpty)
                          ? const Icon(Icons.person, size: 50, color: Colors.white)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _showImagePickerBottomSheet,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.black, width: 2),
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.black,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildTextField('Nickname (Biệt danh)', _nicknameController),
              _buildTextField('Username', _usernameController, enabled: false), // Không cho sửa username
              _buildTextField('Bio (Tiểu sử)', _bioController, maxLines: 3),
              _buildTextField('Link (Liên kết)', _linkController),
              const SizedBox(height: 16),
              const Text('Private Information',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildTextField('Email', _emailController, enabled: false), // Không cho sửa email
              _buildGenderField(),
            ],
          ),
        ),
      ),
    );
  }

  // Widget _buildGenderField (Giữ nguyên)
  Widget _buildGenderField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: GestureDetector(
        onTap: _showGenderBottomSheet,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.white24),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gender',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _genderController.text.isNotEmpty
                          ? _genderController.text
                          : 'Chọn giới tính',
                      style: TextStyle(
                        color: _genderController.text.isNotEmpty
                            ? Colors.white
                            : Colors.white54,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_drop_down,
                color: Colors.white54,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget _buildTextField (Giữ nguyên)
  Widget _buildTextField(String label, TextEditingController controller,
      {int maxLines = 1, bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        enabled: enabled,
        style: TextStyle(
          color: enabled ? Colors.white : Colors.white54,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: enabled ? Colors.white70 : Colors.white38,
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: enabled ? Colors.white24 : Colors.white12,
            ),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.blue),
          ),
          disabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white12),
          ),
        ),
      ),
    );
  }
}