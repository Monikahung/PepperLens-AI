import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pepperlens_ai/core/constants/colors.dart';

// Widget untuk menampilkan preview gambar
class ImagePreviewDialog extends StatelessWidget {
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
                    panEnabled: true,
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: isAsset
                        ? Image.asset(
                            imagePath,
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
                            File(imagePath),
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
            ],
          ),
        ],
      ),
    );
  }
}
