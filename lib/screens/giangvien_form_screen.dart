import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../models/giangvien.dart';
import '../services/giangvien_service.dart';

class GiangVienFormScreen extends StatefulWidget {
  final GiangVien? giangVien;

  const GiangVienFormScreen({
    super.key,
    this.giangVien,
  });

  @override
  State<GiangVienFormScreen> createState() =>
      _GiangVienFormScreenState();
}

class _GiangVienFormScreenState extends State<GiangVienFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = GiangVienService();

  final _idController = TextEditingController();
  final _nameController = TextEditingController();
  final _sumController = TextEditingController();

  String _image = '';
  bool _saving = false;

  static const Color primary = Color(0xFF2563EB);
  static const Color textDark = Color(0xFF172033);
  static const Color textGrey = Color(0xFF64748B);

  bool get _isEdit => widget.giangVien != null;

  @override
  void initState() {
    super.initState();

    final gv = widget.giangVien;

    if (gv != null) {
      _idController.text = gv.idgv;
      _nameController.text = gv.fullname;
      _sumController.text = gv.sumClass.toString();
      _image = gv.image;
    }
  }

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _sumController.dispose();
    super.dispose();
  }
 // Chọn ảnh từ thiết bị 
Future<void> _pickImage() async {
  try {
    // Mở trình chọn một hình ảnh
    final PlatformFile? file = await FilePicker.pickFile(
      type: FileType.image,
    );

    if (file == null) return;

    // Đọc dữ liệu ảnh
    final bytes = await file.readAsBytes();

    // Giới hạn ảnh 300 KB
    if (bytes.length > 300 * 1024) {
      if (!mounted) return;

      _showMessage(
        'Ảnh quá lớn! Vui lòng chọn ảnh nhỏ hơn 300 KB.',
        error: true,
      );
      return;
    }

    setState(() {
      _image = base64Encode(bytes);
    });
  } catch (e) {
    if (!mounted) return;

    _showMessage(
      'Không thể chọn ảnh: $e',
      error: true,
    );
  }
}

  // Hiển thị ảnh đại diện
  Widget _buildImagePreview() {
    Widget imageWidget;

    if (_image.isNotEmpty) {
      try {
        imageWidget = Image.memory(
          base64Decode(_image),
          width: 130,
          height: 130,
          fit: BoxFit.cover,
        );
      } catch (_) {
        imageWidget = const Icon(
          Icons.person,
          size: 65,
          color: primary,
        );
      }
    } else {
      imageWidget = const Icon(
        Icons.add_a_photo_outlined,
        size: 48,
        color: primary,
      );
    }

    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFBFDBFE),
                  width: 1.5,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Center(child: imageWidget),
            ),
            Positioned(
              right: 7,
              bottom: 7,
              child: Container(
                decoration: const BoxDecoration(
                  color: primary,
                  shape: BoxShape.circle,
                ),
                child: const Padding(
                  padding: EdgeInsets.all(7),
                  child: Icon(
                    Icons.camera_alt,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        OutlinedButton.icon(
          onPressed: _saving ? null : _pickImage,
          icon: const Icon(Icons.upload_file, size: 18),
          label: Text(
            _image.isEmpty ? 'Chọn hình ảnh' : 'Thay đổi hình ảnh',
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: primary,
            side: const BorderSide(color: primary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(9),
            ),
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'Định dạng ảnh được hỗ trợ tùy thiết bị',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: textGrey,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  // Ô nhập liệu dùng chung
  Widget _buildTextField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    bool enabled = true,
    String? helperText,
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
          enabled: enabled && !_saving,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            helperText: helperText,
            prefixIcon: Icon(
              icon,
              color: textGrey,
              size: 20,
            ),
            filled: true,
            fillColor: enabled
                ? const Color(0xFFF8FAFC)
                : const Color(0xFFF1F5F9),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
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
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFFE2E8F0),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Thông báo
  void _showMessage(String message, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? Colors.red : Colors.green,
      ),
    );
  }

  // Lưu thông tin giảng viên
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _saving = true;
    });

    try {
      final id = _idController.text.trim();
      final name = _nameController.text.trim();
      final sumClass = int.parse(_sumController.text.trim());

      // Kiểm tra mã giảng viên bị trùng khi thêm mới
      if (!_isEdit && await _service.exists(id)) {
        if (!mounted) return;

        _showMessage(
          'Mã giảng viên đã tồn tại!',
          error: true,
        );

        setState(() {
          _saving = false;
        });
        return;
      }

      // Lưu đúng 4 trường theo yêu cầu đề thi
      final gv = GiangVien(
        idgv: id,
        fullname: name,
        image: _image,
        sumClass: sumClass,
      );

      await _service.save(gv);

      if (!mounted) return;

      _showMessage(
        _isEdit
            ? 'Cập nhật giảng viên thành công!'
            : 'Thêm giảng viên thành công!',
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _saving = false;
      });

      _showMessage(
        'Không thể lưu dữ liệu: $e',
        error: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        title: Text(
          _isEdit ? 'Chỉnh sửa giảng viên' : 'Thêm giảng viên',
          style: const TextStyle(
            color: textDark,
            fontWeight: FontWeight.bold,
            fontSize: 19,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: textDark,
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 850),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tiêu đề
                  Text(
                    _isEdit
                        ? 'Cập nhật thông tin giảng viên'
                        : 'Tạo hồ sơ giảng viên mới',
                    style: const TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    _isEdit
                        ? 'Chỉnh sửa các thông tin cần thiết bên dưới.'
                        : 'Vui lòng nhập đầy đủ thông tin để thêm giảng viên vào hệ thống.',
                    style: const TextStyle(
                      color: textGrey,
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Card hình ảnh
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFEDF0F5),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.image_outlined,
                              color: primary,
                            ),
                            SizedBox(width: 9),
                            Text(
                              'Ảnh đại diện',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: textDark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        Center(
                          child: _buildImagePreview(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Card thông tin
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFEDF0F5),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.person_outline_rounded,
                              color: primary,
                            ),
                            SizedBox(width: 9),
                            Text(
                              'Thông tin giảng viên',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: textDark,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 25),

                        _buildTextField(
                          label: 'Mã giảng viên (IDGV)',
                          hint: 'Ví dụ: GV001',
                          icon: Icons.badge_outlined,
                          controller: _idController,
                          enabled: !_isEdit,
                          helperText: _isEdit
                              ? 'Mã giảng viên không thể thay đổi.'
                              : null,
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return 'Vui lòng nhập mã giảng viên';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 22),

                        _buildTextField(
                          label: 'Họ và tên (Fullname)',
                          hint: 'Nhập họ và tên giảng viên',
                          icon: Icons.person_outline,
                          controller: _nameController,
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return 'Vui lòng nhập họ và tên';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 22),

                        _buildTextField(
                          label: 'Tổng số lớp (SumClass)',
                          hint: 'Nhập tổng số lớp phụ trách',
                          icon: Icons.menu_book_outlined,
                          controller: _sumController,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            final number =
                                int.tryParse(value?.trim() ?? '');

                            if (number == null) {
                              return 'Vui lòng nhập một số nguyên hợp lệ';
                            }

                            if (number < 0) {
                              return 'Số lớp không được nhỏ hơn 0';
                            }

                            return null;
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Các nút chức năng
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _saving
                              ? null
                              : () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: textGrey,
                            padding: const EdgeInsets.symmetric(
                              vertical: 17,
                            ),
                            side: const BorderSide(
                              color: Color(0xFFCBD5E1),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Hủy bỏ'),
                        ),
                      ),

                      const SizedBox(width: 14),

                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _saving ? null : _save,
                          icon: _saving
                              ? const SizedBox(
                                  width: 17,
                                  height: 17,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(
                                  Icons.save_outlined,
                                  size: 19,
                                ),
                          label: Text(
                            _saving
                                ? 'Đang lưu...'
                                : _isEdit
                                    ? 'Cập nhật'
                                    : 'Lưu giảng viên',
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: 17,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
