class IdentifikasiLanjutanModel {
  final int? idIdentifikasi;
  final int idPenyakit;
  final String pathGambar;

  // Constructor utama untuk membuat objek Identifikasi Lanjutan
  IdentifikasiLanjutanModel({
    this.idIdentifikasi,
    required this.idPenyakit,
    required this.pathGambar,
  });

  // Constructor khusus untuk mengubah data dari SQLite (Map) menjadi objek yang bisa diproses oleh Flutter
  factory IdentifikasiLanjutanModel.fromMap(Map<String, dynamic> map) {
    return IdentifikasiLanjutanModel(
      idIdentifikasi: map['id_identifikasi'],
      idPenyakit: map['id_penyakit'],
      pathGambar: map['path_gambar'],
    );
  }

  // Ubah objek menjadi Map agar bisa disimpan kembali ke dalam SQLite
  Map<String, dynamic> toMap() {
    return {
      'id_identifikasi': idIdentifikasi,
      'id_penyakit': idPenyakit,
      'path_gambar': pathGambar,
    };
  }
}
