import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pepperlens_ai/core/constants/colors.dart';
import 'package:pepperlens_ai/core/constants/text_style.dart';

// Widget untuk menampilkan gambar header hasil deteksi
class ResultImageHeader extends StatelessWidget {
  // Atribut untuk path gambar hasil deteksi, apakah ada gambar atau tidak, tanggal deteksi, dan waktu proses deteksi
  final String path;
  final bool noImage;
  final String date;
  final String processTime;

  // Instance dari ResultImageHeader yang wajib diisi
  const ResultImageHeader({
    super.key,
    required this.path,
    required this.noImage,
    required this.date,
    required this.processTime,
  });

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
            // Jika tidak ada gambar, tampilkan icon broken image
            if (noImage)
              AspectRatio(
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
            else
              // Jika ada gambar, tampilkan gambar tersebut
              Image.file(
                File(path),
                width: double.infinity,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => AspectRatio(
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
                    child: Text(date, style: AppTextStyles.manropeTwelve),
                  ),
                  // Waktu proses deteksi penyakit
                  Text(
                    "$processTime Detik",
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
