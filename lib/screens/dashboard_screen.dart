import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:diacritic/diacritic.dart';

import '../models/giangvien.dart';
import '../services/giangvien_service.dart';
import 'giangvien_form_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GiangVienService _service = GiangVienService();
  final TextEditingController _searchController = TextEditingController();

  late Stream<List<GiangVien>> _giangVienStream;

  String _keyword = '';

  static const Color primary = Color(0xFF2563EB);
  static const Color background = Color(0xFFF5F7FB);
  static const Color textDark = Color(0xFF172033);
  static const Color textGrey = Color(0xFF64748B);

  @override
  void initState() {
    super.initState();
    _giangVienStream = _service.getAll();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Chuẩn hóa văn bản: bỏ dấu, chuyển chữ thường.
  // Xử lý riêng chữ đ và Đ.
  String _normalizeSearchText(String text) {
    return removeDiacritics(text)
        .replaceAll('đ', 'd')
        .replaceAll('Đ', 'D')
        .toLowerCase()
        .trim();
  }

  // Mở màn hình thêm hoặc chỉnh sửa
  void _openForm([GiangVien? gv]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GiangVienFormScreen(giangVien: gv),
      ),
    );
  }

  // Xác nhận trước khi xóa
  Future<void> _confirmDelete(GiangVien gv) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Xóa giảng viên'),
        content: Text(
          'Bạn có chắc chắn muốn xóa giảng viên '
          '${gv.fullname} (${gv.idgv}) không?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        await _service.delete(gv.idgv);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã xóa giảng viên thành công!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi khi xóa: $e')),
          );
        }
      }
    }
  }

  // Hiển thị ảnh giảng viên
  Widget _avatar(String image, {double radius = 22}) {
    Widget fallback = CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFFE8EEFF),
      child: Icon(
        Icons.person,
        color: primary,
        size: radius,
      ),
    );

    if (image.isEmpty) return fallback;

    try {
      return CircleAvatar(
        radius: radius,
        backgroundColor: const Color(0xFFE8EEFF),
        backgroundImage: MemoryImage(base64Decode(image)),
      );
    } catch (_) {
      return fallback;
    }
  }

  // Thẻ thống kê
  Widget _statCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDF0F5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: textGrey,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: textDark,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            description,
            style: const TextStyle(
              fontSize: 12,
              color: textGrey,
            ),
          ),
        ],
      ),
    );
  }

  // Sidebar
  Widget _buildSidebar() {
    return Container(
      width: 245,
      color: const Color(0xFF172554),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 30, 16, 32),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.school_rounded,
                    color: Colors.white,
                    size: 27,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'QLHocPhan',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'ADMIN SYSTEM',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 10,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 22),
            child: Text(
              'MENU CHÍNH',
              style: TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const ListTile(
              leading: Icon(
                Icons.people_alt_rounded,
                color: Colors.white,
              ),
              title: Text(
                'Quản lý giảng viên',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 14),
              dense: true,
            ),
          ),
          const Spacer(),
          const Divider(color: Color(0xFF334155)),
          ListTile(
            leading: const Icon(
              Icons.logout_rounded,
              color: Color(0xFFFCA5A5),
            ),
            title: const Text(
              'Đăng xuất',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // Header
  Widget _buildHeader(bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 18 : 30,
        vertical: 18,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFEDF0F5)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quản lý giảng viên',
                  style: TextStyle(
                    fontSize: isMobile ? 19 : 22,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Quản lý thông tin giảng viên trong hệ thống',
                  style: TextStyle(
                    fontSize: 12,
                    color: textGrey,
                  ),
                ),
              ],
            ),
          ),
          if (!isMobile) ...[
            const Icon(
              Icons.account_circle_rounded,
              color: primary,
              size: 36,
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Administrator',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: textDark,
                    fontSize: 13,
                  ),
                ),
                Text(
                  'Quản trị viên',
                  style: TextStyle(
                    color: textGrey,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ] else
            IconButton(
              tooltip: 'Đăng xuất',
              onPressed: () => FirebaseAuth.instance.signOut(),
              icon: const Icon(Icons.logout, color: textGrey),
            ),
        ],
      ),
    );
  }

  // Bảng giảng viên trên màn hình lớn
  Widget _buildTable(List<GiangVien> list) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(
          const Color(0xFFF8FAFC),
        ),
        columnSpacing: 30,
        horizontalMargin: 20,
        headingTextStyle: const TextStyle(
          color: textGrey,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        columns: const [
          DataColumn(label: Text('GIẢNG VIÊN')),
          DataColumn(label: Text('MÃ GIẢNG VIÊN')),
          DataColumn(label: Text('TỔNG SỐ LỚP')),
          DataColumn(label: Text('THAO TÁC')),
        ],
        rows: list.map((gv) {
          return DataRow(
            cells: [
              DataCell(
                SizedBox(
                  width: 190,
                  child: Row(
                    children: [
                      _avatar(gv.image, radius: 19),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          gv.fullname,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: textDark,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              DataCell(
                Text(
                  gv.idgv,
                  style: const TextStyle(
                    color: textGrey,
                    fontSize: 13,
                  ),
                ),
              ),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${gv.sumClass} lớp',
                    style: const TextStyle(
                      color: primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              DataCell(
                Row(
                  children: [
                    IconButton(
                      tooltip: 'Chỉnh sửa',
                      onPressed: () => _openForm(gv),
                      icon: const Icon(
                        Icons.edit_outlined,
                        color: primary,
                        size: 20,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Xóa',
                      onPressed: () => _confirmDelete(gv),
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.redAccent,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  // Thẻ giảng viên trên điện thoại
  Widget _buildMobileCard(GiangVien gv) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEDF0F5)),
      ),
      child: Row(
        children: [
          _avatar(gv.image, radius: 25),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gv.fullname,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Mã: ${gv.idgv}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: textGrey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tổng số lớp: ${gv.sumClass}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') _openForm(gv);
              if (value == 'delete') _confirmDelete(gv);
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'edit',
                child: Text('Chỉnh sửa'),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Text(
                  'Xóa giảng viên',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 700;
        final isTablet =
            constraints.maxWidth >= 700 && constraints.maxWidth < 1100;

        return Scaffold(
          backgroundColor: background,

          // Nút thêm giảng viên trên điện thoại (nhỏ gọn, bo góc 12)
          floatingActionButton: isMobile
              ? Padding(
                  padding: const EdgeInsets.only(right: 4, bottom: 4),
                  child: FloatingActionButton.small(
                    tooltip: 'Thêm giảng viên',
                    onPressed: () => _openForm(),
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.add, size: 22),
                  ),
                )
              : null,

          body: Row(
            children: [
              if (!isMobile) _buildSidebar(),
              Expanded(
                child: Column(
                  children: [
                    _buildHeader(isMobile),
                    Expanded(
                      child: StreamBuilder<List<GiangVien>>(
                        stream: _giangVienStream,
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Center(
                              child: Text(
                                'Đã xảy ra lỗi: ${snapshot.error}',
                              ),
                            );
                          }

                          if (!snapshot.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: primary,
                              ),
                            );
                          }

                          final allList = snapshot.data!;

                          // Chuẩn hóa dữ liệu và từ khóa trước khi tìm kiếm.
                          final list = allList.where((gv) {
                            final id = _normalizeSearchText(gv.idgv);
                            final fullname = _normalizeSearchText(gv.fullname);

                            return id.contains(_keyword) ||
                                fullname.contains(_keyword);
                          }).toList();

                          final totalClasses = allList.fold<int>(
                            0,
                            (sum, gv) => sum + gv.sumClass,
                          );

                          return SingleChildScrollView(
                            // Chừa khoảng trống dưới cùng trên điện thoại
                            // để nút thêm không che danh sách.
                            padding: EdgeInsets.fromLTRB(
                              isMobile ? 16 : 30,
                              isMobile ? 16 : 30,
                              isMobile ? 16 : 30,
                              isMobile ? 80 : 30,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Các thẻ thống kê
                                GridView.count(
                                  crossAxisCount: isMobile
                                      ? 1
                                      : isTablet
                                          ? 2
                                          : 3,
                                  shrinkWrap: true,
                                  physics:
                                      const NeverScrollableScrollPhysics(),
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: isMobile ? 1.7 : 1.65,
                                  children: [
                                    _statCard(
                                      title: 'Tổng giảng viên',
                                      value: '${allList.length}',
                                      icon: Icons.people_alt_rounded,
                                      color: primary,
                                      description:
                                          'Tổng số giảng viên trong hệ thống',
                                    ),
                                    _statCard(
                                      title: 'Tổng số lớp',
                                      value: '$totalClasses',
                                      icon: Icons.menu_book_rounded,
                                      color: const Color(0xFF0D9488),
                                      description:
                                          'Tổng lớp do giảng viên phụ trách',
                                    ),
                                    _statCard(
                                      title: 'Kết quả tìm kiếm',
                                      value: '${list.length}',
                                      icon: Icons.search_rounded,
                                      color: const Color(0xFFEA8B24),
                                      description:
                                          'Số giảng viên phù hợp với từ khóa',
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 30),

                                // Tiêu đề danh sách
                                Row(
                                  children: [
                                    const Expanded(
                                      child: Text(
                                        'Danh sách giảng viên',
                                        style: TextStyle(
                                          fontSize: 19,
                                          fontWeight: FontWeight.bold,
                                          color: textDark,
                                        ),
                                      ),
                                    ),
                                    if (!isMobile)
                                      FilledButton.icon(
                                        onPressed: () => _openForm(),
                                        icon: const Icon(
                                          Icons.add,
                                          size: 19,
                                        ),
                                        label: const Text(
                                          'Thêm giảng viên',
                                        ),
                                        style: FilledButton.styleFrom(
                                          backgroundColor: primary,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 18,
                                            vertical: 16,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),

                                const SizedBox(height: 16),

                                // Khu vực danh sách
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(18),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: const Color(0xFFEDF0F5),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      TextField(
                                        controller: _searchController,
                                        onChanged: (value) {
                                          setState(() {
                                            _keyword =
                                                _normalizeSearchText(value);
                                          });
                                        },
                                        decoration: InputDecoration(
                                          hintText:
                                              'Tìm kiếm theo mã hoặc họ tên...',
                                          hintStyle: const TextStyle(
                                            fontSize: 13,
                                            color: textGrey,
                                          ),
                                          prefixIcon: const Icon(
                                            Icons.search,
                                            color: textGrey,
                                          ),
                                          suffixIcon: _keyword.isNotEmpty
                                              ? IconButton(
                                                  onPressed: () {
                                                    _searchController.clear();
                                                    setState(() {
                                                      _keyword = '';
                                                    });
                                                  },
                                                  icon: const Icon(
                                                    Icons.close,
                                                  ),
                                                )
                                              : null,
                                          filled: true,
                                          fillColor: const Color(0xFFF8FAFC),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: BorderSide.none,
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                            vertical: 14,
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 18),

                                      if (list.isEmpty)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 40,
                                          ),
                                          child: Column(
                                            children: [
                                              Icon(
                                                Icons.person_search_rounded,
                                                size: 48,
                                                color: Colors.grey.shade400,
                                              ),
                                              const SizedBox(height: 12),
                                              Text(
                                                allList.isEmpty
                                                    ? 'Chưa có giảng viên nào'
                                                    : 'Không tìm thấy giảng viên',
                                                style: const TextStyle(
                                                  color: textGrey,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      else if (isMobile)
                                        Column(
                                          children: list
                                              .map(_buildMobileCard)
                                              .toList(),
                                        )
                                      else
                                        _buildTable(list),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 25),

                                const Center(
                                  child: Text(
                                    'QLHocPhan © 2026 - Hệ thống quản lý giảng viên',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: textGrey,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}