import 'package:intl/intl.dart';
import 'package:pepperlens_ai/core/database/database_helper.dart';
import 'package:pepperlens_ai/features/history/logic/delete_file_helper.dart';

// Kelola pengambilan data hasil dan detail deteksi serta penghapusan data hasil deteksi dari database lokal SQLite
class HistoryRepository {
  // Instance dari DatabaseHelper untuk melakukan operasi database
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Ambil data hasil deteksi berdasarkan filter yang dipilih
  Future<List<Map<String, dynamic>>> getHistoryDetection({
    String filter = 'Semua',
  }) async {
    final db = await _dbHelper.database;
    String whereClause = '';

    // Jika filter 'Hari ini'
    if (filter == 'Hari ini') {
      whereClause = "WHERE date(waktu_deteksi) = date('now', 'localtime')";
    }
    // Jika filter 'Bulan ini'
    else if (filter == 'Bulan ini') {
      whereClause =
          "WHERE strftime('%Y-%m', waktu_deteksi) = strftime('%Y-%m', 'now', 'localtime')";
    }
    // Jika filter 'Tahun ini'
    else if (filter == 'Tahun ini') {
      whereClause =
          "WHERE strftime('%Y', waktu_deteksi) = strftime('%Y', 'now', 'localtime')";
    }

    // Ambil data hasil deteksi
    final List<Map<String, dynamic>> masterData = await db.rawQuery('''
        SELECT * FROM Hasil_Deteksi $whereClause
        ORDER BY waktu_deteksi DESC
      ''');

    // Variabel untuk menyimpan data yang diambil dari database
    List<Map<String, dynamic>> results = [];

    // Iterasi melalui data hasil deteksi
    for (var master in masterData) {
      int idMaster = master['id_hasil_deteksi'];

      // Ambil data detail deteksi berdasarkan id hasil deteksi
      final List<Map<String, dynamic>> details = await db.rawQuery(
        '''
          SELECT p.id_penyakit, p.nama_penyakit, COUNT(d.id_penyakit) as jumlah
          FROM Detail_Deteksi d
          JOIN Penyakit p ON d.id_penyakit = p.id_penyakit
          WHERE d.id_hasil_deteksi = ?
          GROUP BY d.id_penyakit
        ''',
        [idMaster],
      );

      // Format tanggal dan waktu
      String rawIsoDate = master['waktu_deteksi'];
      DateTime dateTime = DateTime.parse(rawIsoDate);

      String date = DateFormat('dd MMMM yyyy', 'id_ID').format(dateTime);
      String time = DateFormat('HH:mm:ss').format(dateTime);

      // Tambahkan data yang diambil tersebut ke dalam variabel results
      results.add({
        'id_hasil': idMaster,
        'tanggal': date,
        'waktu': time,
        'asset_id': master['galeri_id'],
        'path_potret': master['path_gambar_potret'],
        'path_deteksi': master['path_gambar_deteksi'],
        'penyakit_data': details
            .map(
              (d) => {
                'id': d['id_penyakit'],
                'nama': d['nama_penyakit'],
                'jumlah': d['jumlah'].toString(),
              },
            )
            .toList(),
      });
    }

    return results;
  }

  // Hapus data hasil deteksi berdasarkan id hasil deteksi
  Future<void> deleteHistory(int idResult) async {
    final db = await _dbHelper.database;

    // Ambil path internal sebelum penghapusan data
    final List<Map<String, dynamic>> dataQuery = await db.query(
      'Hasil_Deteksi',
      where: 'id_hasil_deteksi = ?',
      whereArgs: [idResult],
    );

    // Hapus data gambar dari penyimpanan internal
    if (dataQuery.isNotEmpty) {
      final data = dataQuery.first;

      // Gunakan FileHelper untuk menghapus gambar
      await DeleteFileHelper.deleteLocalFile(data['path_gambar_potret']);
      await DeleteFileHelper.deleteLocalFile(data['path_gambar_deteksi']);
    }

    // Hapus baris data di SQLite
    await db.delete(
      'Hasil_Deteksi',
      where: 'id_hasil_deteksi = ?',
      whereArgs: [idResult],
    );
  }
}
