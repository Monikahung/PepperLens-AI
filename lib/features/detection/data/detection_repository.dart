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
}
