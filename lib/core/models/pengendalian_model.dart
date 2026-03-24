class PengendalianModel {
  final int? idPengendalian;
  final int idPenyakit;
  final String descPengendalian;

  // Constructor utama untuk membuat objek Pengendalian
  PengendalianModel({
    this.idPengendalian,
    required this.idPenyakit,
    required this.descPengendalian,
  });

  // Constructor khusus untuk mengubah data dari SQLite (Map) menjadi objek yang bisa diproses oleh Flutter
  factory PengendalianModel.fromMap(Map<String, dynamic> map) {
    return PengendalianModel(
      idPengendalian: map['id_pengendalian'],
      idPenyakit: map['id_penyakit'],
      descPengendalian: map['desc_pengendalian'],
    );
  }

  // Ubah objek menjadi Map agar bisa disimpan kembali ke dalam SQLite
  Map<String, dynamic> toMap() {
    return {
      'id_pengendalian': idPengendalian,
      'id_penyakit': idPenyakit,
      'desc_pengendalian': descPengendalian,
    };
  }
}
