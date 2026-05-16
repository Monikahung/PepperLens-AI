import 'package:pepperlens_ai/core/database/database_helper.dart';
import 'package:sqflite/sqflite.dart';

// Kelola konversi id penyakit serta penyimpanan hasil serta detail deteksi ke database lokal SQLite
class DetectionRepository {
  // Instance dari DatabaseHelper untuk melakukan operasi database
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Cari id penyakit berdasarkan label
  Future<int> _getDiseaseIdByLabel(Transaction txn, String label) async {
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
    List<Map<String, dynamic>> results = await txn.query(
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
    required String galleryId,
    required double timeProcess,
    required List<Map<String, dynamic>> yoloResults,
  }) async {
    // Buka database
    final db = await _dbHelper.database;

    return await db.transaction((txn) async {
      // Data untuk tabel Hasil Deteksi
      final resultMap = {
        'waktu_deteksi': DateTime.now().toIso8601String(),
        'waktu_proses': timeProcess,
        'path_gambar_potret': pathOriginal,
        'path_gambar_deteksi': pathResult,
        'galeri_id': galleryId,
      };

      // Simpan dan dapatkan id hasil deteksi
      final idResult = await txn.insert('Hasil_Deteksi', resultMap);

      // Data untuk tabel Detail Deteksi
      for (var res in yoloResults) {
        // Cari id penyakit berdasarkan label
        int id = await _getDiseaseIdByLabel(txn, res['label']);

        await txn.insert('Detail_Deteksi', {
          'id_hasil_deteksi': idResult,
          'id_penyakit': id,
          'x': res['x'].toDouble(),
          'y': res['y'].toDouble(),
          'width': res['w'].toDouble(),
          'height': res['h'].toDouble(),
          'confidence': res['score'],
        });
      }

      // Kembalikan id hasil deteksi
      return idResult;
    });
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
