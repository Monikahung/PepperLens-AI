class HasilDeteksiModel {
  final int? idHasilDeteksi;
  final String waktuDeteksi;
  final double waktuProses;
  final String pathGambarPotret;
  final String pathGambarDeteksi;

  // Constructor utama untuk membuat objek Hasil Deteksi
  HasilDeteksiModel({
    this.idHasilDeteksi,
    required this.waktuDeteksi,
    required this.waktuProses,
    required this.pathGambarPotret,
    required this.pathGambarDeteksi,
  });

  // Constructor khusus untuk mengubah data dari SQLite (Map) menjadi objek yang bisa diproses oleh Flutter
  factory HasilDeteksiModel.fromMap(Map<String, dynamic> map) {
    return HasilDeteksiModel(
      idHasilDeteksi: map['id_hasil_deteksi'],
      waktuDeteksi: map['waktu_deteksi'],
      waktuProses: (map['waktu_proses'] as num).toDouble(),
      pathGambarPotret: map['path_gambar_potret'],
      pathGambarDeteksi: map['path_gambar_deteksi'],
    );
  }

  // Ubah objek menjadi Map agar bisa disimpan kembali ke dalam SQLite
  Map<String, dynamic> toMap() {
    return {
      'id_hasil_deteksi': idHasilDeteksi,
      'waktu_deteksi': waktuDeteksi,
      'waktu_proses': waktuProses,
      'path_gambar_potret': pathGambarPotret,
      'path_gambar_deteksi': pathGambarDeteksi,
    };
  }
}
