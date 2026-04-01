import 'package:pepperlens_ai/core/database/database_helper.dart';

// Kelola akses data terkait fitur ensiklopedia dari database lokal SQLite
class EncyclopediaRepository {
  // Instance dari DatabaseHelper untuk melakukan operasi database
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<List<Map<String, dynamic>>> getDiseasesWithImages() async {
    final db = await _dbHelper.database;

    // Query ini menggunakan logika:
    // 1. Mengambil data id_penyakit, nama_penyakit, dan preview_penyakit dari tabel Penyakit
    // 2. Menggunakan COALESCE untuk mencari gambar dengan prioritas:
    // - Gambar terbaru dengan keterangan 'kondisi lada penyakit%'
    // - Jika tidak ada, ambil gambar terbaru dengan keterangan 'kondisi daun penyakit%'
    return await db.rawQuery('''
      SELECT 
        p.id_penyakit, 
        p.nama_penyakit, 
        p.preview_penyakit,
        COALESCE(
          (SELECT path_gambar 
          FROM Gambar_Gejala 
          WHERE id_penyakit = p.id_penyakit 
          AND LOWER(keterangan) 
          LIKE 'kondisi lada penyakit%' 
          ORDER BY id_gambar_gejala DESC
          LIMIT 1),
          (SELECT path_gambar 
          FROM Gambar_Gejala 
          WHERE id_penyakit = p.id_penyakit 
          AND LOWER(keterangan) 
          LIKE 'kondisi daun penyakit%' 
          ORDER BY id_gambar_gejala DESC
          LIMIT 1)
      ) as path_gambar
    FROM Penyakit p
    ''');
  }
}
