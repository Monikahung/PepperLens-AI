import 'package:intl/intl.dart';
import 'package:pepperlens_ai/core/database/database_helper.dart';

class HistoryRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<List<Map<String, dynamic>>> getHistoryDetection({
    String filter = 'Semua',
  }) async {
    final db = await _dbHelper.database;
    String whereClause = '';

    if (filter == 'Hari ini') {
      whereClause = "WHERE date(waktu_deteksi) = date('now', 'localtime')";
    } else if (filter == 'Bulan ini') {
      whereClause =
          "WHERE strftime('%Y-%m', waktu_deteksi) = strftime('%Y-%m', 'now', 'localtime')";
    } else if (filter == 'Tahun ini') {
      whereClause =
          "WHERE strftime('%Y', waktu_deteksi) = strftime('%Y', 'now', 'localtime')";
    }

    final List<Map<String, dynamic>> masterData = await db.rawQuery('''
        SELECT * FROM Hasil_Deteksi $whereClause
        ORDER BY waktu_deteksi DESC
      ''');

    List<Map<String, dynamic>> results = [];

    for (var master in masterData) {
      int idMaster = master['id_hasil_deteksi'];

      final List<Map<String, dynamic>> details = await db.rawQuery(
        '''
          SELECT p.nama_penyakit, COUNT(d.id_penyakit) as jumlah
          FROM Detail_Deteksi d
          JOIN Penyakit p ON d.id_penyakit = p.id_penyakit
          WHERE d.id_hasil_deteksi = ?
          GROUP BY d.id_penyakit
        ''',
        [idMaster],
      );

      String rawIsoDate = master['waktu_deteksi'];
      DateTime dateTime = DateTime.parse(rawIsoDate);

      String date = DateFormat('dd MMMM yyyy', 'id_ID').format(dateTime);
      String time = DateFormat('HH:mm:ss').format(dateTime);

      results.add({
        'id_hasil': idMaster,
        'tanggal': date,
        'waktu': time,
        'path_potret': master['path_gambar_potret'],
        'path_deteksi': master['path_gambar_deteksi'],
        'penyakit_data': details
            .map(
              (d) => {
                'nama': d['nama_penyakit'],
                'jumlah': d['jumlah'].toString(),
              },
            )
            .toList(),
      });
    }

    return results;
  }

  Future<void> deleteHistory(int idResult) async {
    final db = await _dbHelper.database;

    await db.delete(
      'Hasil_Deteksi',
      where: 'id_hasil_deteksi = ?',
      whereArgs: [idResult],
    );
  }
}
