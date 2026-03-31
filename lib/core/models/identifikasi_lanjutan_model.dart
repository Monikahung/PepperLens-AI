class IdentifikasiLanjutanModel {
  final int? idIdentifikasi;
  final int idPenyakit;
  final int urutan;
  final String descLangkah;

  // Constructor utama untuk membuat objek Identifikasi Lanjutan
  IdentifikasiLanjutanModel({
    this.idIdentifikasi,
    required this.idPenyakit,
    required this.urutan,
    required this.descLangkah,
  });

  // Constructor khusus untuk mengubah data dari SQLite (Map) menjadi objek yang bisa diproses oleh Flutter
  factory IdentifikasiLanjutanModel.fromMap(Map<String, dynamic> map) {
    return IdentifikasiLanjutanModel(
      idIdentifikasi: map['id_identifikasi'],
      idPenyakit: map['id_penyakit'],
      urutan: map['urutan'],
      descLangkah: map['desc_langkah'],
    );
  }

  // Ubah objek menjadi Map agar bisa disimpan kembali ke dalam SQLite
  Map<String, dynamic> toMap() {
    return {
      'id_identifikasi': idIdentifikasi,
      'id_penyakit': idPenyakit,
      'urutan': urutan,
      'desc_langkah': descLangkah,
    };
  }
}
