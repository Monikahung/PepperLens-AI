class DetailDeteksiModel {
  final int? idDetailDeteksi;
  final int idHasilDeteksi;
  final int idPenyakit;
  final double x;
  final double y;
  final double width;
  final double height;
  final double confidence;

  // Constructor utama untuk membuat objek Detail Deteksi
  DetailDeteksiModel({
    this.idDetailDeteksi,
    required this.idHasilDeteksi,
    required this.idPenyakit,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.confidence,
  });

  // Constructor khusus untuk mengubah data dari SQLite (Map) menjadi objek yang bisa diproses oleh Flutter
  factory DetailDeteksiModel.fromMap(Map<String, dynamic> map) {
    return DetailDeteksiModel(
      idDetailDeteksi: map['id_detail_deteksi'],
      idHasilDeteksi: map['id_hasil_deteksi'],
      idPenyakit: map['id_penyakit'],
      x: (map['x'] as num).toDouble(),
      y: (map['y'] as num).toDouble(),
      width: (map['width'] as num).toDouble(),
      height: (map['height'] as num).toDouble(),
      confidence: (map['confidence'] as num).toDouble(),
    );
  }

  // Ubah objek menjadi Map agar bisa disimpan kembali ke dalam SQLite
  Map<String, dynamic> toMap() {
    return {
      'id_detail_deteksi': idDetailDeteksi,
      'id_hasil_deteksi': idHasilDeteksi,
      'id_penyakit': idPenyakit,
      'x': x,
      'y': y,
      'width': width,
      'height': height,
      'confidence': confidence,
    };
  }
}
