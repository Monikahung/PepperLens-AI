import 'dart:io';
import 'package:flutter/foundation.dart';

// Logic untuk menghapus file dari penyimpanan internal
class FileHelper {
  static Future<void> deleteLocalFile(String path) async {
    // Mengecek apakah path kosong
    if (path.isEmpty) return;

    try {
      // Mengambil file dari path yang diberikan
      final file = File(path);

      // Mengecek apakah file ada
      if (await file.exists()) {
        // Menghapus file
        await file.delete();
        debugPrint("Berhasil hapus: $path");
      } else {
        debugPrint("File tidak ditemukan: $path");
      }
    } catch (e) {
      debugPrint("Gagal menghapus file: $e");
    }
  }
}
