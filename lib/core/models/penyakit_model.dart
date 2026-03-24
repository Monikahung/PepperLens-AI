class PenyakitModel {
  final int? idPenyakit;
  final String namaPenyakit;
  final String descPenyakit;

  // Constructor utama untuk membuat objek Penyakit
  PenyakitModel({
    this.idPenyakit,
    required this.namaPenyakit,
    required this.descPenyakit,
  });

  // Constructor khusus untuk mengubah data dari SQLite (Map) menjadi objek yang bisa diproses oleh Flutter
  factory PenyakitModel.fromMap(Map<String, dynamic> map) {
    return PenyakitModel(
      idPenyakit: map['id_penyakit'],
      namaPenyakit: map['nama_penyakit'],
      descPenyakit: map['desc_penyakit'],
    );
  }

  // Ubah objek menjadi Map agar bisa disimpan kembali ke dalam SQLite
  Map<String, dynamic> toMap() {
    return {
      'id_penyakit': idPenyakit,
      'nama_penyakit': namaPenyakit,
      'desc_penyakit': descPenyakit,
    };
  }
}
