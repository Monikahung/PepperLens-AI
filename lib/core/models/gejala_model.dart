class GejalaModel {
  final int? idGejala;
  final int idPenyakit;
  final String descGejala;

  // Constructor utama untuk membuat objek Gejala
  GejalaModel({
    this.idGejala,
    required this.idPenyakit,
    required this.descGejala,
  });

  // Constructor khusus untuk mengubah data dari SQLite (Map) menjadi objek yang bisa diproses oleh Flutter
  factory GejalaModel.fromMap(Map<String, dynamic> map) {
    return GejalaModel(
      idGejala: map['id_gejala'],
      idPenyakit: map['id_penyakit'],
      descGejala: map['desc_gejala'],
    );
  }

  // Ubah objek menjadi Map agar bisa disimpan kembali ke dalam SQLite
  Map<String, dynamic> toMap() {
    return {
      'id_gejala': idGejala,
      'id_penyakit': idPenyakit,
      'desc_gejala': descGejala,
    };
  }
}
