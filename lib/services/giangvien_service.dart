import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/giangvien.dart';

class GiangVienService {
  final _col = FirebaseFirestore.instance.collection('GiangVien');

  Stream<List<GiangVien>> getAll() => _col.snapshots().map(
        (s) => s.docs.map((d) => GiangVien.fromMap(d.data())).toList()
          ..sort((a, b) => a.idgv.compareTo(b.idgv)),
      );

  Future<bool> exists(String id) async => (await _col.doc(id).get()).exists;

  Future<void> save(GiangVien gv) => _col.doc(gv.idgv).set(gv.toMap());

  Future<void> delete(String id) => _col.doc(id).delete();
}