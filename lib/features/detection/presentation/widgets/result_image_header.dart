import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pepperlens_ai/core/constants/colors.dart';
import 'package:pepperlens_ai/core/constants/text_style.dart';

// Widget untuk menampilkan gambar header hasil deteksi
class ResultImageHeader extends StatefulWidget {
  // Atribut untuk path gambar hasil deteksi, apakah ada gambar atau tidak, tanggal deteksi, waktu proses deteksi, dan status perubahan zoom
  final String path;
  final bool noImage;
  final String date;
  final String processTime;
  final Function(bool) onZoomChanged;

  // Instance dari ResultImageHeader yang wajib diisi
  const ResultImageHeader({
    super.key,
    required this.path,
    required this.noImage,
    required this.date,
    required this.processTime,
    required this.onZoomChanged,
  });

  @override
  State<ResultImageHeader> createState() => _ResultImageHeaderState();
}

class _ResultImageHeaderState extends State<ResultImageHeader> {
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

  // Bangun tampilan gambar header hasil deteksi
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.mysticJade, width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
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
                  // Jika tidak ada gambar, tampilkan icon broken image
                  child: widget.noImage
                      ? AspectRatio(
                          aspectRatio: 1 / 1,
                          child: Container(
                            color: AppColors.frostedMint,
                            child: const Icon(
                              Icons.broken_image,
                              color: AppColors.honeydew,
                              size: 40,
                            ),
                          ),
                        )
                      // Jika ada gambar, tampilkan gambar tersebut
                      : Image.file(
                          File(widget.path),
                          width: double.infinity,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              AspectRatio(
                                aspectRatio: 1 / 1,
                                child: Container(
                                  color: AppColors.frostedMint,
                                  child: const Icon(
                                    Icons.broken_image,
                                    color: AppColors.honeydew,
                                  ),
                                ),
                              ),
                        ),
                ),

                // Ikon zoom
                if (_showZoomIcon && !widget.noImage)
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.darkCyan.withAlpha(
                          (0.75 * 255).toInt(),
                        ),
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

            // Konten tanggal, jam, dan waktu proses deteksi penyakit
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              color: AppColors.mysticJade,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    // Tanggal dan jam deteksi penyakit
                    child: Text(
                      widget.date,
                      style: AppTextStyles.manropeTwelve,
                    ),
                  ),
                  // Waktu proses deteksi penyakit
                  Text(
                    "${widget.processTime} Detik",
                    style: AppTextStyles.manropeTwelve,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
