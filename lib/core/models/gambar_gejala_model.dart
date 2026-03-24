class GambarGejalaModel {
  final int? idGambarGejala;
  final int idPenyakit;
  final String pathGambar;
  final String keterangan;

  // Constructor utama untuk membuat objek Gambar Gejala
  GambarGejalaModel({
    this.idGambarGejala,
    required this.idPenyakit,
    required this.pathGambar,
    required this.keterangan,
  });

  // Constructor khusus untuk mengubah data dari SQLite (Map) menjadi objek yang bisa diproses oleh Flutter
  factory GambarGejalaModel.fromMap(Map<String, dynamic> map) {
    return GambarGejalaModel(
      idGambarGejala: map['id_gambar_gejala'],
      idPenyakit: map['id_penyakit'],
      pathGambar: map['path_gambar'],
      keterangan: map['keterangan'],
    );
  }

  // Ubah objek menjadi Map agar bisa disimpan kembali ke dalam SQLite
  Map<String, dynamic> toMap() {
    return {
      'id_gambar_gejala': idGambarGejala,
      'id_penyakit': idPenyakit,
      'path_gambar': pathGambar,
      'keterangan': keterangan,
    };
  }
}
