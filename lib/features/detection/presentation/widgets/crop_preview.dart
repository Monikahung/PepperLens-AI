import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pepperlens_ai/core/constants/colors.dart';

// Widget untuk menampilkan preview gambar crop hasil deteksi
class CropPreview extends StatelessWidget {
  // Atribut untuk path gambar asli, data deteksi, ukuran preview, dan kontrol ikon zoom
  final String originalPath;
  final Map<String, dynamic> detection;
  final double size;
  final bool showZoomIcon;

  // Instance dari CropPreview yang wajib diisi
  const CropPreview({
    super.key,
    required this.originalPath,
    required this.detection,
    required this.size,
    this.showZoomIcon = true,
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
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Gambar hasil crop bounding box
            Positioned.fill(
              child: FittedBox(
                fit: BoxFit.contain,
                clipBehavior: Clip.antiAlias,
                child: SizedBox(
                  width: w,
                  height: h,
                  child: ClipRRect(
                    clipBehavior: Clip.antiAlias,
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
                            filterQuality: FilterQuality.high,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Ikon zoom pada gambar hasil crop bounding box
            if (showZoomIcon)
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: AppColors.darkCyan.withAlpha((0.75 * 255).toInt()),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(
                    Icons.zoom_out_map_rounded,
                    color: AppColors.honeydew,
                    size: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
