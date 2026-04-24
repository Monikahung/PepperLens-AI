import 'dart:io';
import 'package:flutter/foundation.dart';

class FileHelper {
  static Future<void> deleteLocalFile(String path) async {
    if (path.isEmpty) return;

    try {
      final file = File(path);
      if (await file.exists()) {
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
