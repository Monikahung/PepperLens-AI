import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pepperlens_ai/core/constants/colors.dart';

// Widget untuk menampilkan preview gambar crop hasil deteksi
class CropPreview extends StatelessWidget {
  // Atribut untuk path gambar asli, data deteksi, dan ukuran preview
  final String originalPath;
  final Map<String, dynamic> detection;
  final double size;

  // Instance dari CropPreview yang wajib diisi
  const CropPreview({
    super.key,
    required this.originalPath,
    required this.detection,
    required this.size,
  });

  // Bangun tampilan preview gambar crop hasil deteksi
  @override
  Widget build(BuildContext context) {
    // Konversi data koordinat dari database ke double
    double x = (detection['x'] as num).toDouble();
    double y = (detection['y'] as num).toDouble();
    double w = (detection['width'] as num).toDouble();
    double h = (detection['height'] as num).toDouble();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.honeydew, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(9),
        child: FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(
            width: w,
            height: h,
            child: Stack(
              children: [
                // Geser gambar ke koordinat negatif untuk mensimulasikan efek crop gambar
                Positioned(
                  left: -x,
                  top: -y,
                  child: Image.file(
                    File(originalPath),
                    fit: BoxFit.none,
                    alignment: Alignment.topLeft,
                    filterQuality: FilterQuality.low,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
