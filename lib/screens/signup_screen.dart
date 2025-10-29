import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:short_video_fe/providers/auth_provider.dart';
import 'package:short_video_fe/screens/login_screen.dart';
import 'dart:async';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // Xóa lỗi cũ khi màn hình được khởi tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<AuthProvider>(context, listen: false).clearError();
      }
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    _confirmPasswordController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // == LOGIC KIỂM TRA USERNAME TỨC THÌ ==
  void _onUsernameChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (value.length >= 3) {
        // Chỉ gọi check khi người dùng dừng gõ
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        authProvider.checkUsernameAvailability(value.trim());
      }
    });
  }

  Future<void> _submit() async {
    // Đóng bàn phím
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Kiểm tra mật khẩu trùng khớp
    if (_passwordController.text != _confirmPasswordController.text) {
      authProvider.setError("Passwords do not match");
      return;
    }

    // Kiểm tra username có sẵn không (từ AuthProvider)
    if (!authProvider.isUsernameAvailable) {
      authProvider.setError("Username is already taken");
      return;
    }

    // Gọi hàm register của AuthProvider (đã kết nối Firebase)
    final bool success = await authProvider.register(
      _emailController.text.trim(),
      _passwordController.text.trim(),
      _usernameController.text.trim(),
    );

    // === SỬA ĐỔI LOGIC TẠI ĐÂY ===
    if (success) {
      print('SignUpScreen: Registration successful. Logging out and navigating to Login.');

      // 1. Đăng xuất người dùng ngay sau khi đăng ký
      //    (Để AuthWrapper biết user == null)
      await authProvider.logout();

      // 2. Hiển thị thông báo thành công và điều hướng
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration successful! Please log in.'),
            backgroundColor: Colors.green,
          ),
        );

        // 3. Điều hướng thủ công sang LoginScreen
        //    (AuthWrapper sẽ không cản trở vì user đã là null)
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginScreen())
        );
      }
    } else {
      // Lỗi đã được AuthProvider xử lý và sẽ hiển thị trên UI
      print('SignUpScreen: Registration failed.');
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Lắng nghe AuthProvider để lấy trạng thái loading, error, và username
    final authProvider = Provider.of<AuthProvider>(context);
    final isLoading = authProvider.isLoading;
    final error = authProvider.error;
    final isUsernameAvailable = authProvider.isUsernameAvailable;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),

                  // Hiển thị lỗi (nếu có)
                  if (error != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border:
                        Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline,
                              color: Colors.red, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              error,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Trường Username
                  TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.person),
                      // Hiển thị icon check/cancel cho username
                      suffixIcon: _usernameController.text.length >= 3
                          ? Icon(
                        isUsernameAvailable
                            ? Icons.check_circle
                            : Icons.cancel,
                        color: isUsernameAvailable
                            ? Colors.green
                            : Colors.red,
                      )
                          : null,
                    ),
                    onChanged: _onUsernameChanged,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your username';
                      }
                      if (value.length < 3) {
                        return 'Username must be at least 3 characters';
                      }
                      // Validator sẽ được kích hoạt lại khi build
                      if (!isUsernameAvailable) {
                        return 'Username is already taken';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Trường Email
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Trường Password
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: _togglePasswordVisibility,
                      ),
                    ),
                    obscureText: _obscurePassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Trường Confirm Password
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: _toggleConfirmPasswordVisibility,
                      ),
                    ),
                    obscureText: _obscureConfirmPassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Nút Sign Up
                  if (isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    ElevatedButton(
                      onPressed: _submit,
                      child: const Text('Sign Up'),
                    ),
                  const SizedBox(height: 16),

                  // Nút chuyển sang Login
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => const LoginScreen())
                      );
                    },
                    child: const Text(
                      'Already have an account? Login',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

