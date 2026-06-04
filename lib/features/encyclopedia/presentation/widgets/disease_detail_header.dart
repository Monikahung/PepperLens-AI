import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pepperlens_ai/core/constants/colors.dart';
import 'package:pepperlens_ai/core/constants/text_style.dart';

// Widget untuk menampilkan gambar header di halaman detail penyakit
class DiseaseDetailHeader extends StatefulWidget {
  // Atribut yang digunakan untuk menampilkan gambar header di halaman detail penyakit
  final String? originalImagePath;
  final List<Map<String, dynamic>>? detectionResults;
  final int diseaseId;
  final String mainImagePath;
  final bool hasNoImage;
  final String Function(String?) getShortLabel;
  final Function(bool) onZoomChanged;

  // Instance dari DiseaseDetailHeader dengan parameter wajib diisi
  const DiseaseDetailHeader({
    super.key,
    this.originalImagePath,
    this.detectionResults,
    required this.diseaseId,
    required this.mainImagePath,
    required this.hasNoImage,
    required this.getShortLabel,
    required this.onZoomChanged,
  });

  @override
  State<DiseaseDetailHeader> createState() => _DiseaseDetailHeaderState();
}

class _DiseaseDetailHeaderState extends State<DiseaseDetailHeader> {
  // Controller untuk memantau perubahan zoom gambar
  final TransformationController _transformationController =
      TransformationController();
  bool _showZoomIcon = true;

  @override
  void initState() {
    super.initState();
    // Listener untuk mendeteksi saat pengguna melakukan zoom
    _transformationController.addListener(_handleTransformationChanged);
  }

  @override
  void dispose() {
    // Bersihkan listener dan controller saat widget dihancurkan
    _transformationController.removeListener(_handleTransformationChanged);
    _transformationController.dispose();
    super.dispose();
  }

  // Function untuk mengecek tingkat zoom gambar secara real-time
  void _handleTransformationChanged() {
    final double currentScale = _transformationController.value
        .getMaxScaleOnAxis();

    // Jika skala mendekati 1.0, tampilkan ikon zoom
    // Jika skala melebihi 1.0, sembunyikan ikon zoom
    final bool shouldShow = currentScale <= 1.01;

    if (_showZoomIcon != shouldShow) {
      setState(() {
        _showZoomIcon = shouldShow;
      });
    }
  }

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
        child: Stack(
          children: [
            // Gambar header penyakit
            InteractiveViewer(
              transformationController: _transformationController,
              panEnabled: true,
              scaleEnabled: true,
              minScale: 0.5,
              maxScale: 4.0,
              clipBehavior: Clip.hardEdge,
              interactionEndFrictionCoefficient: 0.00001,
              // Matikan scroll jika terdapat minimal 2 jari (cubit zoom)
              onInteractionStart: (ScaleStartDetails details) {
                if (details.pointerCount >= 2) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    widget.onZoomChanged(false);
                  });
                }
              },
              // Ketika interaksi selesai, aktifkan scroll halaman
              onInteractionEnd: (ScaleEndDetails details) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  widget.onZoomChanged(true);
                });
              },
              child:
                  widget.originalImagePath != null &&
                      widget.detectionResults != null
                  ? _buildDetectionStack()
                  : _buildNormalImage(),
            ),

            // Ikon zoom
            if (_showZoomIcon &&
                !widget.hasNoImage &&
                widget.mainImagePath.isNotEmpty)
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.darkCyan.withAlpha((0.75 * 255).toInt()),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(
                    Icons.zoom_out_map_rounded,
                    color: AppColors.honeydew,
                    size: 20,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Jika tidak ada gambar potret dan hasil deteksinya, tampilkan gambar penyakit dari tabel penyakit
  Widget _buildNormalImage() {
    return AspectRatio(
      aspectRatio: 1 / 1,
      child: widget.hasNoImage || widget.mainImagePath.isEmpty
          ? Container(
              color: AppColors.frostedMint,
              child: const Icon(
                Icons.broken_image,
                color: AppColors.honeydew,
                size: 40,
              ),
            )
          : Image.asset(
              widget.mainImagePath,
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
      future: _getImageSize(widget.originalImagePath!),
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
                      File(widget.originalImagePath!),
                      width: constraints.maxWidth,
                      fit: BoxFit.fitWidth,
                    ),

                    // Loop bounding box dan label
                    ...widget.detectionResults!
                        .where((res) => res['id_penyakit'] == widget.diseaseId)
                        .expand((res) {
                          // Konversi data koordinat dari database ke double
                          double x = (res['x'] as num).toDouble() * scale;
                          double y = (res['y'] as num).toDouble() * scale;
                          double w = (res['width'] as num).toDouble() * scale;
                          double h = (res['height'] as num).toDouble() * scale;

                          // Ambil warna sesuai id penyakit
                          Color diseaseColor = AppColors.getDiseaseColor(
                            widget.diseaseId,
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
                                  "${widget.getShortLabel(res['nama_penyakit'])} ${(res['confidence'] as num).round()}%",
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
