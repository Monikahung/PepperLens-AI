import 'package:pepperlens_ai/core/database/database_helper.dart';

// Kelola konversi id penyakit serta penyimpanan hasil serta detail deteksi ke database lokal SQLite
class DetectionRepository {
  // Instance dari DatabaseHelper untuk melakukan operasi database
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Cari id penyakit berdasarkan label
  Future<int> getDiseaseIdByLabel(String label) async {
    final db = await _dbHelper.database;

    // Key adalah label YOLO dan value adalah nama penyakit di database
    final Map<String, String> diseaseDictionary = {
      'BPB': 'Busuk Pangkal Batang',
      'Kuning': 'Kuning',
      'Keriting': 'Keriting/Kerdil',
      'Hawar': 'Hawar Daun',
    };

    // Ambil nama asli dari kamus
    String diseaseName = diseaseDictionary[label] ?? label;

    // Query ke database berdasarkan nama asli
    List<Map<String, dynamic>> results = await db.query(
      'Penyakit',
      columns: ['id_penyakit'],
      where: 'nama_penyakit = ?',
      whereArgs: [diseaseName],
    );

    if (results.isNotEmpty) {
      return results.first['id_penyakit'] as int;
    }

    return 0;
  }

  // Simpan hasil deteksi ke database
  Future<int> insertResultDetectionToDatabase({
    required String pathOriginal,
    required String pathResult,
    required double timeProcess,
    required List<Map<String, dynamic>> yoloResults,
  }) async {
    // Siapkan List Detail secara Manual (karena butuh await)
    final List<Map<String, dynamic>> detailsList = [];

    for (var res in yoloResults) {
      // Tunggu sampai id didapatkan dari database
      int id = await getDiseaseIdByLabel(res['label']);

      detailsList.add({
        'id_penyakit': id,
        'x': res['x'].toDouble(),
        'y': res['y'].toDouble(),
        'width': res['w'].toDouble(),
        'height': res['h'].toDouble(),
        'confidence': res['score'],
      });
    }

    // Data untuk tabel Hasil Deteksi
    final resultMap = {
      'waktu_deteksi': DateTime.now().toIso8601String(),
      'waktu_proses': timeProcess,
      'path_gambar_potret': pathOriginal,
      'path_gambar_deteksi': pathResult,
    };

    // Eksekusi simpan lewat helper
    return await _dbHelper.insertResultDetectionComplete(
      resultMap,
      detailsList,
    );
  }

  // Ambil data hasil dan detail deteksi berdasarkan id hasil deteksi
  Future<Map<String, dynamic>> getCompleteDetectionResult(int idResult) async {
    final db = await _dbHelper.database;

    // Ambil header
    final headerResult = await db.query(
      'Hasil_Deteksi',
      where: 'id_hasil_deteksi = ?',
      whereArgs: [idResult],
    );

    // Jika tidak ditemukan
    if (headerResult.isEmpty) throw Exception("Data tidak ditemukan");

    // Ambil data detail deteksi
    final detailsResult = await db.rawQuery(
      '''
      SELECT d.*, p.nama_penyakit
      FROM Detail_Deteksi d
      JOIN Penyakit p ON d.id_penyakit = p.id_penyakit
      WHERE d.id_hasil_deteksi = ?
      ''',
      [idResult],
    );

    return {'header': headerResult.first, 'details': detailsResult};
  }
}
