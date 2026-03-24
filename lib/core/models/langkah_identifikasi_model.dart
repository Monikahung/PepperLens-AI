class LangkahIdentifikasiModel {
  final int? idLangkah;
  final int idIdentifikasi;
  final int urutan;
  final String descLangkah;

  // Constructor utama untuk membuat objek Langkah Identifikasi
  LangkahIdentifikasiModel({
    this.idLangkah,
    required this.idIdentifikasi,
    required this.urutan,
    required this.descLangkah,
  });

  // Constructor khusus untuk mengubah data dari SQLite (Map) menjadi objek yang bisa diproses oleh Flutter
  factory LangkahIdentifikasiModel.fromMap(Map<String, dynamic> map) {
    return LangkahIdentifikasiModel(
      idLangkah: map['id_langkah'],
      idIdentifikasi: map['id_identifikasi'],
      urutan: map['urutan'],
      descLangkah: map['desc_langkah'],
    );
  }

  // Ubah objek menjadi Map agar bisa disimpan kembali ke dalam SQLite
  Map<String, dynamic> toMap() {
    return {
      'id_langkah': idLangkah,
      'id_identifikasi': idIdentifikasi,
      'urutan': urutan,
      'desc_langkah': descLangkah,
    };
  }
}
