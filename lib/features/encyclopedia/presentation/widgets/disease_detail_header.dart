import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pepperlens_ai/core/constants/colors.dart';
import 'package:pepperlens_ai/core/constants/text_style.dart';

// Widget untuk menampilkan gambar header di halaman detail penyakit
class DiseaseDetailHeader extends StatelessWidget {
  // Atribut yang digunakan untuk menampilkan gambar header di halaman detail penyakit
  final String? originalImagePath;
  final List<Map<String, dynamic>>? detectionResults;
  final int diseaseId;
  final String mainImagePath;
  final bool hasNoImage;
  final String Function(String?) getShortLabel;

  // Instance dari DiseaseDetailHeader dengan parameter wajib diisi
  const DiseaseDetailHeader({
    super.key,
    this.originalImagePath,
    this.detectionResults,
    required this.diseaseId,
    required this.mainImagePath,
    required this.hasNoImage,
    required this.getShortLabel,
  });

  // Dapatkan ukuran gambar berdasarkan path gambar
  Future<Size> _getImageSize(String imagePath) async {
    final File file = File(imagePath);
    final data = await file.readAsBytes();
    final decodedImage = await decodeImageFromList(data);
    return Size(decodedImage.width.toDouble(), decodedImage.height.toDouble());
  }

  // Bangun tampilan gambar header di halaman detail penyakit
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.mysticJade, width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: originalImagePath != null && detectionResults != null
            ? _buildDetectionStack()
            : _buildNormalImage(),
      ),
    );
  }

  // Jika tidak ada gambar potret dan hasil deteksinya, tampilkan gambar penyakit dari tabel penyakit
  Widget _buildNormalImage() {
    return AspectRatio(
      aspectRatio: 1 / 1,
      child: hasNoImage || mainImagePath.isEmpty
          ? Container(
              color: AppColors.frostedMint,
              child: const Icon(
                Icons.broken_image,
                color: AppColors.honeydew,
                size: 40,
              ),
            )
          : Image.asset(
              mainImagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, e, s) => Container(
                color: AppColors.frostedMint,
                child: const Icon(
                  Icons.broken_image,
                  color: AppColors.honeydew,
                ),
              ),
            ),
    );
  }

  // Jika ditemukan gambar potret dan hasil deteksinya, tampilkan gambar hasil deteksi beserta bounding box dan labelnya
  Widget _buildDetectionStack() {
    return FutureBuilder<Size>(
      future: _getImageSize(originalImagePath!),
      builder: (context, sizeSnapshot) {
        if (!sizeSnapshot.hasData) return const SizedBox();

        double originalWidth = sizeSnapshot.data!.width;

        return LayoutBuilder(
          builder: (context, constraints) {
            double scale = constraints.maxWidth / originalWidth;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  children: [
                    // Gambar potret asli
                    Image.file(
                      File(originalImagePath!),
                      width: constraints.maxWidth,
                      fit: BoxFit.fitWidth,
                    ),

                    // Loop bounding box dan label
                    ...detectionResults!
                        .where((res) => res['id_penyakit'] == diseaseId)
                        .expand((res) {
                          // Konversi data koordinat dari database ke double
                          double x = (res['x'] as num).toDouble() * scale;
                          double y = (res['y'] as num).toDouble() * scale;
                          double w = (res['width'] as num).toDouble() * scale;
                          double h = (res['height'] as num).toDouble() * scale;

                          // Ambil warna sesuai id penyakit
                          Color diseaseColor = AppColors.getDiseaseColor(
                            diseaseId,
                          );

                          return [
                            // Gambar kotak bounding box
                            Positioned(
                              left: x,
                              top: y,
                              child: Container(
                                width: w,
                                height: h,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: diseaseColor,
                                    width: 4,
                                  ),
                                ),
                              ),
                            ),

                            // Label penyakit
                            Positioned(
                              left: x,
                              top: y,
                              child: FractionalTranslation(
                                translation: Offset(0.0, -1.0),
                                child: Text(
                                  "${getShortLabel(res['nama_penyakit'])} ${(res['confidence'] as num).round()}%",
                                  style: AppTextStyles.poppinsFour.copyWith(
                                    color: diseaseColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ];
                        }),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }
}
