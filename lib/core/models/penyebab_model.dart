class PenyebabModel {
  final int? idPenyebab;
  final int idPenyakit;
  final String descPenyebab;

  // Constructor utama untuk membuat objek Penyebab
  PenyebabModel({
    this.idPenyebab,
    required this.idPenyakit,
    required this.descPenyebab,
  });

  // Constructor khusus untuk mengubah data dari SQLite (Map) menjadi objek yang bisa diproses oleh Flutter
  factory PenyebabModel.fromMap(Map<String, dynamic> map) {
    return PenyebabModel(
      idPenyebab: map['id_penyebab'],
      idPenyakit: map['id_penyakit'],
      descPenyebab: map['desc_penyebab'],
    );
  }

  // Ubah objek menjadi Map agar bisa disimpan kembali ke dalam SQLite
  Map<String, dynamic> toMap() {
    return {
      'id_penyebab': idPenyebab,
      'id_penyakit': idPenyakit,
      'desc_penyebab': descPenyebab,
    };
  }
}
