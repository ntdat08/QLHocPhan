class GiangVien {
  final String idgv;
  final String fullname;
  final String image; // base64
  final int sumClass;

  GiangVien({required this.idgv, required this.fullname, required this.image, required this.sumClass});

  Map<String, dynamic> toMap() => {
        'IDGV': idgv,
        'Fullname': fullname,
        'Image': image,
        'SumClass': sumClass,
      };

  factory GiangVien.fromMap(Map<String, dynamic> m) => GiangVien(
        idgv: m['IDGV'] ?? '',
        fullname: m['Fullname'] ?? '',
        image: m['Image'] ?? '',
        sumClass: (m['SumClass'] ?? 0) as int,
      );
}