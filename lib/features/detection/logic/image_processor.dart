import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:opencv_dart/opencv_dart.dart' as cv;
import 'package:photo_manager/photo_manager.dart';

// Logic untuk menangani pemrosesan gambar
class ImageProcessor {
  // Ambil warna berdasarkan label penyakit (format BGR)
  cv.Scalar _getColorByLabel(String label) {
    switch (label) {
      case "BPB":
        return cv.Scalar(0, 0, 255);
      case "Hawar":
        return cv.Scalar(255, 0, 255);
      case "Keriting":
        return cv.Scalar(255, 255, 0);
      case "Kuning":
        return cv.Scalar(255, 255, 255);
      default:
        return cv.Scalar(0, 255, 0);
    }
  }

  // Simpan gambar asli dan gambar hasil deteksi
  void saveImage(cv.Mat mat, String path, {int quality = 95}) {
    cv.imwrite(
      path,
      mat,
      params: cv.VecI32.fromList([cv.IMWRITE_JPEG_QUALITY, quality]),
    );
  }

  // Simpan gambar hasil deteksi ke galeri
  Future<String?> saveImageToGallery(
    String path, {
    String albumName = 'PepperLens AI',
  }) async {
    try {
      final file = File(path);
      if (!await file.exists()) return null;

      // Baca file menjadi bytes
      final Uint8List bytes = await file.readAsBytes();

      // Buat nama file unik
      final String fileName =
          'PepperLens_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Simpan ke galeri publik agar muncul di aplikasi Google Photos atau Gallery
      final AssetEntity entity = await PhotoManager.editor.saveImage(
        bytes,
        filename: fileName,
        title: fileName,
        relativePath: 'Pictures/$albumName',
      );

      // Mengembalikan assetId untuk disimpan ke SQLite
      return entity.id;
    } catch (e) {
      debugPrint("Gagal mendaftarkan ke galeri: $e");
      return null;
    }
  }

  // Gambar kotak di sekitar objek yang terdeteksi
  void drawBoundingBoxes(cv.Mat mat, List<Map<String, dynamic>> results) {
    debugPrint("Menggambar ${results.length} kotak ke matriks");
    if (results.isEmpty) return;

    // Ambil resolusi gambar asli
    final int imgW = mat.cols;
    final int imgH = mat.rows;
    final int maxDim = imgW > imgH ? imgW : imgH;

    // Hitung skala ketebalan garis
    final int lineThickness = (maxDim / 120).clamp(4, 35).toInt();

    // Hitung skala font
    final double fontScale = (maxDim / 720).clamp(1.0, 10.0);

    // Hitung ketebalan font
    final int fontThickness = (lineThickness * 0.8).clamp(2, 25).toInt();

    // Hitung offset teks
    final int textOffset = (lineThickness * 2.2).toInt();

    for (var res in results) {
      // Ambil warna sesuai label hasil deteksi
      final color = _getColorByLabel(res['label']);

      // Gambar kotak
      cv.rectangle(
        mat,
        cv.Rect(res['x'], res['y'], res['w'], res['h']),
        color,
        thickness: lineThickness,
      );

      // Siapkan teks label dan skor (%)
      String labelText = "${res['label']} ${res['score']}%";

      // Tulis teks di atas kotak
      cv.putText(
        mat,
        labelText,
        cv.Point(res['x'], res['y'] - textOffset),
        cv.FONT_HERSHEY_SIMPLEX,
        fontScale,
        color,
        thickness: fontThickness,
      );
    }
  }
}
