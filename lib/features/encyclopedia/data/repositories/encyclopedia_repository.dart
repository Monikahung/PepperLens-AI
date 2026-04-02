import 'package:pepperlens_ai/core/database/database_helper.dart';

// Kelola akses data terkait fitur ensiklopedia dari database lokal SQLite
class EncyclopediaRepository {
  // Instance dari DatabaseHelper untuk melakukan operasi database
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // 1. Ambil daftar ringkas penyakit untuk halaman utama ensiklopedia
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

  // 2. Ambil data lengkap satu penyakit untuk halaman detail
  Future<Map<String, dynamic>?> getDiseaseDetail(int idPenyakit) async {
    final db = await _dbHelper.database;

    // a. Ambil data utama dari tabel Penyakit
    final penyakit = await db.query(
      'Penyakit',
      where: 'id_penyakit = ?',
      whereArgs: [idPenyakit],
    );

    if (penyakit.isEmpty) return null;

    // b. Ambil data dari tabel Gejala
    final gejala = await db.query(
      'Gejala',
      where: 'id_penyakit = ?',
      whereArgs: [idPenyakit],
      orderBy: 'id_gejala ASC',
    );

    // c. Ambil data dari tabel Gambar Gejala
    final gambar = await db.rawQuery(
      '''
      SELECT path_gambar, keterangan
      FROM Gambar_Gejala
      WHERE id_penyakit = ?
      ORDER BY
        CASE
          WHEN LOWER(keterangan) LIKE 'kondisi lada penyakit%' THEN 1
          WHEN LOWER(keterangan) LIKE 'kondisi daun penyakit%' THEN 2
          ELSE 3
        END ASC, id_gambar_gejala DESC
      ''',
      [idPenyakit],
    );

    // d. Ambil data dari tabel Penyebab
    final penyebab = await db.query(
      'Penyebab',
      where: 'id_penyakit = ?',
      whereArgs: [idPenyakit],
      orderBy: 'id_penyebab ASC',
    );

    // e. Ambil data dari tabel Pengendalian
    final pengendalian = await db.query(
      'Pengendalian',
      where: 'id_penyakit = ?',
      whereArgs: [idPenyakit],
      orderBy: 'id_pengendalian ASC',
    );

    // f. Ambil data dari tabel Identifikasi Lanjutan
    final identifikasiLanjutan = await db.query(
      'Identifikasi_Lanjutan',
      where: 'id_penyakit = ?',
      whereArgs: [idPenyakit],
      orderBy: 'urutan ASC',
    );

    // g. Gabungkan semua data ke dalam satu map besar
    return {
      'info': penyakit.first,
      'gejala': gejala,
      'gambar': gambar,
      'penyebab': penyebab,
      'pengendalian': pengendalian,
      'identifikasi_lanjutan': identifikasiLanjutan,
    };
  }
}
