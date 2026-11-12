import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;
  bool _obscurePassword = true;

  static const Color primary = Color(0xFF2563EB);
  static const Color navy = Color(0xFF172554);
  static const Color textDark = Color(0xFF172033);
  static const Color textGrey = Color(0xFF64748B);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Chuyển mã lỗi Firebase thành thông báo dễ hiểu
  String _getErrorMessage(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Địa chỉ Email không hợp lệ.';

      case 'user-not-found':
        return 'Không tìm thấy tài khoản này.';

      case 'wrong-password':
        return 'Mật khẩu không chính xác.';

      case 'invalid-credential':
        return 'Email hoặc mật khẩu không chính xác.';

      case 'user-disabled':
        return 'Tài khoản này đã bị vô hiệu hóa.';

      case 'too-many-requests':
        return 'Bạn đã thử quá nhiều lần. Vui lòng thử lại sau.';

      case 'network-request-failed':
        return 'Không có kết nối mạng. Vui lòng kiểm tra Internet.';

      default:
        return 'Đăng nhập thất bại. Vui lòng thử lại.';
    }
  }

  // Đăng nhập Firebase
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    setState(() {
      _loading = true;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Không cần Navigator ở đây.
      // main.dart tự động chuyển sang Dashboard
      // thông qua authStateChanges().
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_getErrorMessage(e.code)),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã xảy ra lỗi. Vui lòng thử lại.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  // Khôi phục mật khẩu qua Email
  Future<void> _forgotPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập Email hợp lệ trước.'),
        ),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: email,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Nếu tài khoản tồn tại, hướng dẫn đặt lại mật khẩu sẽ được gửi đến Email.',
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 5),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_getErrorMessage(e.code)),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  // Ô nhập liệu
  Widget _buildInput({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    bool password = false,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: textDark,
          ),
        ),
        const SizedBox(height: 9),
        TextFormField(
          controller: controller,
          obscureText: password && _obscurePassword,
          keyboardType: password
              ? TextInputType.visiblePassword
              : TextInputType.emailAddress,
          validator: validator,
          enabled: !_loading,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 13,
            ),
            prefixIcon: Icon(
              icon,
              color: textGrey,
              size: 20,
            ),
            suffixIcon: password
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: textGrey,
                      size: 20,
                    ),
                  )
                : null,
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 17,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFFE2E8F0),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFFE2E8F0),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: primary,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Colors.redAccent,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Colors.redAccent,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Phần thương hiệu bên trái
  Widget _buildBrandPanel() {
    return Container(
      color: navy,
      padding: const EdgeInsets.all(45),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.school_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 13),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'QLHocPhan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'ADMIN MANAGEMENT SYSTEM',
                    style: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 9,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const Spacer(),

          const Text(
            'Quản lý thông minh.\nVận hành hiệu quả.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.bold,
              height: 1.35,
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'Hệ thống hỗ trợ quản lý thông tin giảng viên '
            'một cách thuận tiện, nhanh chóng và hiệu quả.',
            style: TextStyle(
              color: Color(0xFFCBD5E1),
              fontSize: 15,
              height: 1.8,
            ),
          ),

          const SizedBox(height: 35),

          // Các điểm nổi bật
          _buildFeature(
            Icons.people_alt_outlined,
            'Quản lý thông tin giảng viên',
          ),
          const SizedBox(height: 18),
          _buildFeature(
            Icons.cloud_sync_outlined,
            'Đồng bộ dữ liệu với Firebase',
          ),
          const SizedBox(height: 18),
          _buildFeature(
            Icons.security_outlined,
            'Đăng nhập và xác thực an toàn',
          ),

          const Spacer(),

          const Text(
            'QLHocPhan © 2026',
            style: TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeature(IconData icon, String title) {
    return Row(
      children: [
        Icon(
          icon,
          color: const Color(0xFF60A5FA),
          size: 22,
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Color(0xFFE2E8F0),
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  // Biểu mẫu đăng nhập
  Widget _buildLoginForm() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 35,
        vertical: 30,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 400,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo dành cho mobile
                LayoutBuilder(
                  builder: (context, constraints) {
                    return const SizedBox.shrink();
                  },
                ),

                const Text(
                  'Chào mừng trở lại!',
                  style: TextStyle(
                    fontSize: 29,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  'Đăng nhập vào tài khoản quản trị để tiếp tục.',
                  style: TextStyle(
                    color: textGrey,
                    fontSize: 13,
                    height: 1.6,
                  ),
                ),

                const SizedBox(height: 35),

                _buildInput(
                  label: 'Địa chỉ Email',
                  hint: 'admin@example.com',
                  icon: Icons.email_outlined,
                  controller: _emailController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập Email';
                    }

                    final emailRegex =
                        RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

                    if (!emailRegex.hasMatch(value.trim())) {
                      return 'Email không đúng định dạng';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 23),

                _buildInput(
                  label: 'Mật khẩu',
                  hint: 'Nhập mật khẩu của bạn',
                  icon: Icons.lock_outline_rounded,
                  controller: _passwordController,
                  password: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập mật khẩu';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 12),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _loading ? null : _forgotPassword,
                    child: const Text(
                      'Quên mật khẩu?',
                      style: TextStyle(
                        color: primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 17),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: _loading ? null : _login,
                    style: FilledButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Đăng nhập',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: 10),
                              Icon(
                                Icons.arrow_forward_rounded,
                                size: 19,
                              ),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: 28),

                const Divider(color: Color(0xFFE2E8F0)),

                const SizedBox(height: 20),

                const Center(
                  child: Text(
                    'Hệ thống quản trị QLHocPhan',
                    style: TextStyle(
                      color: textGrey,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 850;

          if (isDesktop) {
            return Row(
              children: [
                Expanded(
                  flex: 5,
                  child: _buildBrandPanel(),
                ),
                Expanded(
                  flex: 6,
                  child: SingleChildScrollView(
                    child: SizedBox(
                      height: constraints.maxHeight,
                      child: _buildLoginForm(),
                    ),
                  ),
                ),
              ],
            );
          }

          // Giao diện dành cho tablet và điện thoại
          return SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    color: navy,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 25,
                      vertical: 24,
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.school_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'QLHocPhan',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildLoginForm(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
