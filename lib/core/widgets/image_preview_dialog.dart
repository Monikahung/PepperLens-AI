import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pepperlens_ai/core/constants/colors.dart';

// Widget untuk menampilkan preview gambar
class ImagePreviewDialog extends StatefulWidget {
  // Atribut yang diperlukan untuk menampilkan preview gambar
  final String imagePath;
  final bool isAsset;

  // Instance dari ImagePreviewDialog dengan parameter wajib diisi
  const ImagePreviewDialog({
    super.key,
    required this.imagePath,
    required this.isAsset,
  });

  // Metode statis untuk menampilkan dialog preview gambar
  static void show(BuildContext context, String path, {required bool isAsset}) {
    showDialog(
      context: context,
      builder: (context) =>
          ImagePreviewDialog(imagePath: path, isAsset: isAsset),
    );
  }

  @override
  State<ImagePreviewDialog> createState() => _ImagePreviewDialogState();
}

class _ImagePreviewDialogState extends State<ImagePreviewDialog> {
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

  // Bangun tampilan dialog preview gambar
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.honeydew, width: 2),
                  color: AppColors.honeydew,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: InteractiveViewer(
                    transformationController: _transformationController,
                    panEnabled: true,
                    scaleEnabled: true,
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: widget.isAsset
                        ? Image.asset(
                            widget.imagePath,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Container(
                              color: AppColors.frostedMint,
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.broken_image,
                                color: AppColors.honeydew,
                                size: 40,
                              ),
                            ),
                          )
                        : Image.file(
                            File(widget.imagePath),
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Container(
                              color: AppColors.frostedMint,
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.broken_image,
                                color: AppColors.honeydew,
                                size: 40,
                              ),
                            ),
                          ),
                  ),
                ),
              ),

              // Tombol close
              Positioned(
                right: 10,
                top: 10,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                      color: AppColors.honeydew,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: AppColors.darkCyan,
                      size: 20,
                    ),
                  ),
                ),
              ),

              // Ikon zoom untuk menandakan bahwa gambar sedang di zoom atau tidak
              if (_showZoomIcon)
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: AppColors.honeydew,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(
                      Icons.zoom_out_map_rounded,
                      color: AppColors.darkCyan,
                      size: 20,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
