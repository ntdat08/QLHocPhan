import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/giangvien.dart';
import '../services/giangvien_service.dart';
import 'giangvien_form_screen.dart';

class GiangVienListScreen extends StatefulWidget {
  const GiangVienListScreen({super.key});
  @override
  State<GiangVienListScreen> createState() => _GiangVienListScreenState();
}

class _GiangVienListScreenState extends State<GiangVienListScreen> {
  final _service = GiangVienService();
  String _keyword = '';

  Future<void> _confirmDelete(GiangVien gv) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xóa giảng viên'),
        content: Text('Bạn có chắc muốn xóa ${gv.fullname} (${gv.idgv})?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Xóa')),
        ],
      ),
    );
    if (ok == true) await _service.delete(gv.idgv);
  }

  void _openForm([GiangVien? gv]) => Navigator.push(
      context, MaterialPageRoute(builder: (_) => GiangVienFormScreen(giangVien: gv)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Giảng viên'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Đăng xuất',
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: const Text('Thêm'),
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            decoration: const InputDecoration(
                hintText: 'Tìm theo mã hoặc tên...', prefixIcon: Icon(Icons.search), border: OutlineInputBorder()),
            onChanged: (v) => setState(() => _keyword = v.toLowerCase()),
          ),
        ),
        Expanded(
          child: StreamBuilder<List<GiangVien>>(
            stream: _service.getAll(),
            builder: (context, snap) {
              if (snap.hasError) return Center(child: Text('Lỗi: ${snap.error}'));
              if (!snap.hasData) return const Center(child: CircularProgressIndicator());
              final list = snap.data!
                  .where((g) => g.idgv.toLowerCase().contains(_keyword) || g.fullname.toLowerCase().contains(_keyword))
                  .toList();
              if (list.isEmpty) return const Center(child: Text('Chưa có giảng viên'));
              return ListView.separated(
                itemCount: list.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final gv = list[i];
                  return ListTile(
                    leading: CircleAvatar(
                      radius: 26,
                      backgroundImage: gv.image.isNotEmpty ? MemoryImage(base64Decode(gv.image)) : null,
                      child: gv.image.isEmpty ? const Icon(Icons.person) : null,
                    ),
                    title: Text(gv.fullname),
                    subtitle: Text('Mã: ${gv.idgv}  •  Số lớp: ${gv.sumClass}'),
                    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                      IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _openForm(gv)),
                      IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _confirmDelete(gv)),
                    ]),
                  );
                },
              );
            },
          ),
        ),
      ]),
    );
  }
}