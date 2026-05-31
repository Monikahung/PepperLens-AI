import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:photo_manager/photo_manager.dart';

// Logic untuk menghapus file dari penyimpanan internal
class DeleteFileHelper {
  // Menghapus file dari penyimpanan internal
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

  // Menghapus file dari galeri
  static Future<bool> deleteGalleryFile(String assetId) async {
    // Mengecek apakah assetId kosong
    if (assetId.isEmpty) return false;

    try {
      // PhotoManager akan meminta izin sistem
      final List<String> result = await PhotoManager.editor.deleteWithIds([
        assetId,
      ]);
      if (result.isNotEmpty) {
        debugPrint("Berhasil hapus gambar: $assetId");
        return true;
      } else {
        debugPrint("Pengguna menolak untuk menghapus gambar: $assetId");
        return false;
      }
    } catch (e) {
      debugPrint("Gagal menghapus gambar: $e");
      return false;
    }
  }
}
